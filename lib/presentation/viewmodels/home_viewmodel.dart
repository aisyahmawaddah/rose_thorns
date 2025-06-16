// lib/presentation/viewmodels/home_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/models/item_model.dart';
import 'package:koopon/data/services/item_services.dart';
import 'package:koopon/data/services/auth_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ItemService _itemService = ItemService();
  final AuthService _authService = AuthService();
  
  List<ItemModel> _items = [];
  List<ItemModel> _filteredItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = '';
  bool _isInitialized = false;
  bool _disposed = false; // Track if disposed

  // Getters
  List<ItemModel> get items => _filteredItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  bool get isInitialized => _isInitialized;

  // Override dispose to track disposal
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Safe notifyListeners that checks disposal
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Initialize and fetch all items
  Future<void> initialize() async {
    if (_isInitialized || _disposed) return;
    _isInitialized = true;
    await fetchAllItems();
  }

  // ENHANCED: Fetch all items from Firebase (now automatically filters sold items)
  Future<void> fetchAllItems() async {
    if (_disposed) return; // Early return if disposed
    
    _setLoading(true);
    _clearError();
    _selectedCategory = '';
    
    try {
      print('🏠 HomeViewModel: Fetching all available items...');
      
      // The ItemService.getAllItems() now automatically filters out sold items
      _items = await _itemService.getAllItems();
      
      if (!_disposed) { // Before updating state
        _filteredItems = List.from(_items);
        print('✅ HomeViewModel: Loaded ${_items.length} available items');
        _safeNotifyListeners();
      }
    } catch (e) {
      if (!_disposed) { // Before setting error
        print('❌ HomeViewModel: Error loading items: $e');
        _setError('Failed to load items: ${e.toString()}');
      }
    } finally {
      if (!_disposed) { // Before setting loading false
        _setLoading(false);
      }
    }
  }

  // ENHANCED: Filter items by category (now works with pre-filtered available items)
  Future<void> fetchItemsByCategory(String category) async {
    if (_disposed) return; // Early return if disposed
    
    _setLoading(true);
    _clearError();
    _selectedCategory = category;
    
    try {
      print('📂 HomeViewModel: Filtering by category: $category');
      
      if (category.isEmpty || category == 'All') {
        // Show all available items (already filtered by ItemService)
        _filteredItems = List.from(_items);
      } else {
        // Filter the already-available items by category
        _filteredItems = _items.where((item) => 
          item.category.toLowerCase() == category.toLowerCase()).toList();
      }
      
      if (!_disposed) { // Before notifying
        print('✅ HomeViewModel: Filtered to ${_filteredItems.length} items in category "$category"');
        _safeNotifyListeners();
      }
    } catch (e) {
      if (!_disposed) { // Before setting error
        _setError('Failed to filter items: ${e.toString()}');
      }
    } finally {
      if (!_disposed) { // Before setting loading false
        _setLoading(false);
      }
    }
  }

  // ENHANCED: Search items by name (now works with pre-filtered available items)
  Future<void> searchItems(String query) async {
    if (_disposed) return; // Early return if disposed
    
    _setLoading(true);
    _clearError();
    
    try {
      print('🔍 HomeViewModel: Searching for: "$query"');
      
      if (query.trim().isEmpty) {
        // Show all available items
        _filteredItems = List.from(_items);
      } else {
        // Search within the already-available items
        _filteredItems = _items.where((item) => 
            item.name.toLowerCase().contains(query.toLowerCase())).toList();
      }
      
      if (!_disposed) { // Before notifying
        print('✅ HomeViewModel: Found ${_filteredItems.length} items matching "$query"');
        _safeNotifyListeners();
      }
    } catch (e) {
      if (!_disposed) { // Before setting error
        _setError('Failed to search items: ${e.toString()}');
      }
    } finally {
      if (!_disposed) { // Before setting loading false
        _setLoading(false);
      }
    }
  }

  // Delete an item
  Future<bool> deleteItem(String itemId) async {
    if (_disposed) return false; // Early return if disposed
    
    try {
      await _itemService.deleteItem(itemId);
      
      if (!_disposed) { // Before updating lists
        // Remove from local lists
        _items.removeWhere((item) => item.id == itemId);
        _filteredItems.removeWhere((item) => item.id == itemId);
        
        _safeNotifyListeners();
      }
      return true;
    } catch (e) {
      if (!_disposed) { // Before setting error
        _setError('Failed to delete item: ${e.toString()}');
      }
      return false;
    }
  }

  // ENHANCED: Refresh items (for pull-to-refresh and after orders)
  Future<void> refreshItems() async {
    if (_disposed) return; // Early return if disposed
    
    print('🔄 HomeViewModel: Refreshing items (will filter out newly sold items)...');
    await fetchAllItems();
  }

  // NEW: Force refresh after an order is placed (call this from order completion)
  Future<void> refreshAfterOrder() async {
    print('🛒 HomeViewModel: Refreshing after order placed...');
    await refreshItems();
  }

  // Helper methods with disposal checks
  void _setLoading(bool loading) {
    if (_disposed) return; // Before setting state
    _isLoading = loading;
    _safeNotifyListeners();
  }

  void _setError(String error) {
    if (_disposed) return; // Before setting state
    _errorMessage = error;
    _safeNotifyListeners();
  }

  void _clearError() {
    if (_disposed) return; // Before setting state
    _errorMessage = null;
  }

  // Check if current user is the seller of an item
  bool isCurrentUserSeller(String sellerId) {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;
    return currentUser.uid == sellerId;
  }

  // Get current user info
  User? get currentUser => _authService.currentUser;

  // Get current user display name
  String get currentUserDisplayName => _authService.currentUserDisplayName;

  // NEW: Check if an item is still available (helper method)
  Future<bool> isItemStillAvailable(String itemId) async {
    try {
      return await _itemService.isItemAvailable(itemId);
    } catch (e) {
      print('Error checking item availability: $e');
      return false;
    }
  }

  // NEW: Get fresh item count (useful for debugging)
  Future<int> getFreshItemCount() async {
    try {
      final freshItems = await _itemService.getAllItems();
      return freshItems.length;
    } catch (e) {
      print('Error getting fresh item count: $e');
      return 0;
    }
  }
}