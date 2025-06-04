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

  // Initialize and fetch user's items
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await refreshUserItems();
  }

  // Fetch user's items from Firebase
  Future<void> refreshUserItems() async {
    _setLoading(true);
    _clearError();
    
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      _userItems = await _itemService.getItemsBySeller(currentUser!.uid);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load your products: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    // Refresh user authentication data
    await currentUser?.reload();
    await refreshUserItems();
    notifyListeners();
  }

  // Delete an item
  Future<bool> deleteItem(String itemId) async {
    try {
      await _itemService.deleteItem(itemId);
      
      // Remove from local list
      _userItems.removeWhere((item) => item.id == itemId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete product: ${e.toString()}');
      return false;
    }
  }

  // Update user profile (for future use)
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
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
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
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

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
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
    try {
      await _authService.signOut();
      _userItems.clear();
      _isInitialized = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
    }
  }
}