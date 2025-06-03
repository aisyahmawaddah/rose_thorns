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

  // Getters
  List<ItemModel> get items => _filteredItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  // Initialize and fetch all items
  Future<void> initialize() async {
    await fetchAllItems();
  }

  // Fetch all items from Firebase
  Future<void> fetchAllItems() async {
    _setLoading(true);
    _clearError();
    _selectedCategory = '';
    
    try {
      _items = await _itemService.getAllItems();
      _filteredItems = List.from(_items);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load items: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Filter items by category
  Future<void> fetchItemsByCategory(String category) async {
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
      notifyListeners();
    } catch (e) {
      _setError('Failed to filter items: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Search items by name
  Future<void> searchItems(String query) async {
    _setLoading(true);
    _clearError();
    
    try {
      if (query.trim().isEmpty) {
        _filteredItems = List.from(_items);
      } else {
        _filteredItems = _items.where((item) => 
          item.name.toLowerCase().contains(query.toLowerCase())).toList();
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to search items: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Delete an item
  Future<bool> deleteItem(String itemId) async {
    try {
      await _itemService.deleteItem(itemId);
      
      // Remove from local lists
      _items.removeWhere((item) => item.id == itemId);
      _filteredItems.removeWhere((item) => item.id == itemId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete item: ${e.toString()}');
      return false;
    }
  }

  // Refresh items (for pull-to-refresh)
  Future<void> refreshItems() async {
    await fetchAllItems();
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