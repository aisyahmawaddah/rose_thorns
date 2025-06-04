import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/models/item_model.dart';
import 'package:koopon/data/services/item_services.dart';
import 'package:koopon/data/services/auth_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ItemService _itemService = ItemService();
  final AuthService _authService = AuthService();
  
  List<ItemModel> _userItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  bool _disposed = false; // ADD: Track if disposed

  // Getters
  List<ItemModel> get userItems => _userItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  // User information getters
  User? get currentUser => _authService.currentUser;
  String get currentUserDisplayName => _authService.currentUserDisplayName;
  String get currentUserEmail => currentUser?.email ?? 'No email';
  String? get currentUserPhotoUrl => currentUser?.photoURL;
  String get currentUserId => currentUser?.uid ?? '';

  // ADD: Override dispose to track disposal
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ADD: Safe notifyListeners that checks disposal
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Initialize and fetch user's items
  Future<void> initialize() async {
    if (_isInitialized || _disposed) return;
    _isInitialized = true;
    await refreshUserItems();
  }

Future<void> refreshUserItems() async {
  if (_disposed) return;
  
  print('🔄 ProfileViewModel: refreshUserItems called');
  
  _setLoading(true);
  _clearError();
  
  try {
    if (currentUser == null) {
      print('❌ ProfileViewModel: currentUser is null');
      throw Exception('User not authenticated');
    }

    print('✅ ProfileViewModel: User authenticated');
    print('   User ID: ${currentUser!.uid}');
    print('   User Email: ${currentUser!.email}');
    print('   Display Name: ${currentUser!.displayName}');

    // Test Firestore connection first
    await _itemService.testFirestoreConnection();

    // Use the fixed getItemsBySeller method (no composite index needed)
    print('🔍 ProfileViewModel: Fetching items for seller: ${currentUser!.uid}');
    _userItems = await _itemService.getItemsBySeller(currentUser!.uid);
    
    print('📊 ProfileViewModel: Received ${_userItems.length} items');
    
    // Log each item for debugging
    for (int i = 0; i < _userItems.length; i++) {
      final item = _userItems[i];
      print('   Item $i: ${item.name} (${item.id}) - ${item.category} - RM${item.price}');
    }

    if (!_disposed) {
      print('✅ ProfileViewModel: Notifying listeners');
      _safeNotifyListeners();
    }
  } catch (e) {
    print('💥 ProfileViewModel ERROR: $e');
    if (!_disposed) {
      _setError('Failed to load your products: ${e.toString()}');
    }
  } finally {
    if (!_disposed) {
      _setLoading(false);
    }
  }
}

  // Refresh profile data
  Future<void> refreshProfile() async {
    if (_disposed) return; // CHECK: Early return if disposed
    
    // Refresh user authentication data
    await currentUser?.reload();
    await refreshUserItems();
    if (!_disposed) { // CHECK: Before notifying
      _safeNotifyListeners();
    }
  }

  // Delete an item
  Future<bool> deleteItem(String itemId) async {
  if (_disposed) return false;
  
  try {
    print('🗑️ ProfileViewModel: Starting delete for item: $itemId');
    
    // OPTIMISTIC UI UPDATE: Remove item from UI immediately
    final itemToDelete = _userItems.firstWhere((item) => item.id == itemId);
    final originalIndex = _userItems.indexWhere((item) => item.id == itemId);
    
    if (originalIndex != -1) {
      _userItems.removeAt(originalIndex);
      if (!_disposed) {
        _safeNotifyListeners(); // Update UI immediately
      }
    }
    
    print('✅ ProfileViewModel: Item removed from UI, now deleting from database...');
    
    // Delete from database (this is now fast since image deletion is backgrounded)
    await _itemService.deleteItem(itemId);
    
    print('✅ ProfileViewModel: Database deletion completed');
    return true;
    
  } catch (e) {
    print('❌ ProfileViewModel: Delete failed: $e');
    
    // ROLLBACK: If deletion failed, add the item back to the UI
    if (!_disposed) {
      // Re-fetch items to get the correct state
      print('🔄 ProfileViewModel: Rolling back - refreshing items from database');
      await refreshUserItems();
      _setError('Failed to delete product: ${e.toString()}');
    }
    return false;
  }
}

  // Update user profile (for future use)
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (_disposed) return false; // CHECK: Early return if disposed
    
    try {
      final user = currentUser;
      if (user == null) return false;

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Reload user data
      await user.reload();
      if (!_disposed) { // CHECK: Before notifying
        _safeNotifyListeners();
      }
      
      return true;
    } catch (e) {
      if (!_disposed) { // CHECK: Before setting error
        _setError('Failed to update profile: ${e.toString()}');
      }
      return false;
    }
  }

  // Get statistics for profile
  Map<String, int> get profileStats {
    return {
      'totalProducts': _userItems.length,
      'activeProducts': _userItems.length, // All products are currently active
      'soldProducts': 0, // You can implement this later when you add order functionality
    };
  }

  // Get products by category for the current user
  List<ItemModel> getItemsByCategory(String category) {
    return _userItems.where((item) => 
      item.category.toLowerCase() == category.toLowerCase()).toList();
  }

  // Search user's products
  List<ItemModel> searchUserItems(String query) {
    if (query.trim().isEmpty) return _userItems;
    
    return _userItems.where((item) => 
      item.name.toLowerCase().contains(query.toLowerCase()) ||
      item.category.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // Helper methods with disposal checks
  void _setLoading(bool loading) {
    if (_disposed) return; // CHECK: Before setting state
    _isLoading = loading;
    _safeNotifyListeners();
  }

  void _setError(String error) {
    if (_disposed) return; // CHECK: Before setting state
    _errorMessage = error;
    _safeNotifyListeners();
  }

  void _clearError() {
    if (_disposed) return; // CHECK: Before setting state
    _errorMessage = null;
  }

  // Check if user has any products
  bool get hasProducts => _userItems.isNotEmpty;

  // Get recent products (last 5)
  List<ItemModel> get recentProducts {
    final sorted = List<ItemModel>.from(_userItems);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  // Sign out user
  Future<void> signOut() async {
    if (_disposed) return; // CHECK: Early return if disposed
    
    try {
      await _authService.signOut();
      if (!_disposed) { // CHECK: Before updating state
        _userItems.clear();
        _isInitialized = false;
        _safeNotifyListeners();
      }
    } catch (e) {
      if (!_disposed) { // CHECK: Before setting error
        _setError('Failed to sign out: ${e.toString()}');
      }
    }
  }
  // Add this new method to test with all items (for debugging)
  Future<void> debugLoadAllItems() async {
    if (_disposed) return;
    
    print('🧪 ProfileViewModel: debugLoadAllItems called');
    
    try {
      final allItems = await _itemService.getAllItemsDebug();
      print('📊 ProfileViewModel: Found ${allItems.length} total items in database');
      
      // Filter by current user
      final userItems = allItems.where((item) => item.sellerId == currentUser?.uid).toList();
      print('📊 ProfileViewModel: ${userItems.length} items belong to current user');
      
      _userItems = userItems;
      if (!_disposed) {
        _safeNotifyListeners();
      }
    } catch (e) {
      print('💥 ProfileViewModel debugLoadAllItems ERROR: $e');
    }
  }

  // Add this method to your ProfileViewModel class to test authentication
  void debugUserAuth() {
    print('🔍 ProfileViewModel: Debug User Authentication');
    print('   Current User: ${currentUser?.uid}');
    print('   Display Name: $currentUserDisplayName');
    print('   Email: $currentUserEmail');
    print('   Is Initialized: $_isInitialized');
    print('   Is Loading: $_isLoading');
    print('   Error Message: $_errorMessage');
    print('   User Items Count: ${_userItems.length}');
  }
}