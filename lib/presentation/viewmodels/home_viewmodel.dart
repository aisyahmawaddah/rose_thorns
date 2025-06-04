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
  bool _disposed = false; // ADD: Track if disposed

  // Getters
  List<ItemModel> get items => _filteredItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  bool get isInitialized => _isInitialized;

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

  // Initialize and fetch all items
  Future<void> initialize() async {
    if (_isInitialized || _disposed) return;
    _isInitialized = true;
    await fetchAllItems();
  }

  // Fetch all items from Firebase
  Future<void> fetchAllItems() async {
    if (_disposed) return; // CHECK: Early return if disposed
    
    _setLoading(true);
    _clearError();
    _selectedCategory = '';
    
    try {
      _items = await _itemService.getAllItems();
      if (!_disposed) { // CHECK: Before updating state
        _filteredItems = List.from(_items);
        _safeNotifyListeners();
      }
    } catch (e) {
      if (!_disposed) { // CHECK: Before setting error
        _setError('Failed to load items: ${e.toString()}');
      }
    } finally {
      if (!_disposed) { // CHECK: Before setting loading false
        _setLoading(false);
      }
    }
  }

  // Filter items by category
  Future<void> fetchItemsByCategory(String category) async {
    if (_disposed) return; // CHECK: Early return if disposed
    
    _setLoading(true);
    _clearError();
    _selectedCategory = category;
    
    try {
      if (category.isEmpty || category == 'All') {
        _filteredItems = List.from(_items);
      } else {
        _filteredItems = _items.where((item) => 
          item.category.toLowerCase() == category.toLowerCase()).toList();
      }
      if (!_disposed) { // CHECK: Before notifying
        _safeNotifyListeners();
      }
    } catch (e) {
      if (!_disposed) { // CHECK: Before setting error
        _setError('Failed to filter items: ${e.toString()}');
      }
    } finally {
      if (!_disposed) { // CHECK: Before setting loading false
        _setLoading(false);
      }
    }
  }

  // Search items by name
  Future<void> searchItems(String query) async {
    if (_disposed) return; // CHECK: Early return if disposed
    
    _setLoading(true);
    _clearError();
    
    try {
      if (query.trim().isEmpty) {
        _filteredItems = List.from(_items);
      } else {
        _filteredItems = _items.where((item) => 
          item.name.toLowerCase().contains(query.toLowerCase())).toList();
      }
      if (!_disposed) { // CHECK: Before notifying
        _safeNotifyListeners();
      }
    } catch (e) {
      if (!_disposed) { // CHECK: Before setting error
        _setError('Failed to search items: ${e.toString()}');
      }
    } finally {
      if (!_disposed) { // CHECK: Before setting loading false
        _setLoading(false);
      }
    }
  }

  // Delete an item
  Future<bool> deleteItem(String itemId) async {
    if (_disposed) return false; // CHECK: Early return if disposed
    
    try {
      await _itemService.deleteItem(itemId);
      
      if (!_disposed) { // CHECK: Before updating lists
        // Remove from local lists
        _items.removeWhere((item) => item.id == itemId);
        _filteredItems.removeWhere((item) => item.id == itemId);
        
        _safeNotifyListeners();
      }
      return true;
    } catch (e) {
      if (!_disposed) { // CHECK: Before setting error
        _setError('Failed to delete item: ${e.toString()}');
      }
      return false;
    }
  }

  // Refresh items (for pull-to-refresh)
  Future<void> refreshItems() async {
    if (_disposed) return; // CHECK: Early return if disposed
    await fetchAllItems();
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
}