// lib/presentation/viewmodels/admin_item_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:koopon/data/models/item_model.dart';
import 'package:koopon/data/services/item_services.dart';

class AdminItemViewModel extends ChangeNotifier {
  final ItemService _itemService = ItemService();
  
  List<ItemModel> _allItems = [];
  List<ItemModel> _filteredItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = '';
  String _searchQuery = '';
  bool _disposed = false;

  // Getters
  List<ItemModel> get items => _filteredItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Statistics getters
  int get totalItems => _allItems.length;
  int get availableItems => _allItems.where((item) => item.status != 'sold').length;
  int get soldItems => _allItems.where((item) => item.status == 'sold').length;
  
  Map<String, int> get itemsByCategory {
    final Map<String, int> categoryCount = {};
    for (final item in _allItems) {
      categoryCount[item.category] = (categoryCount[item.category] ?? 0) + 1;
    }
    return categoryCount;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Initialize and fetch all items (including sold items for admin view)
  Future<void> initialize() async {
    await fetchAllItemsForAdmin();
  }

  // ADMIN: Get ALL items including sold ones
  Future<void> fetchAllItemsForAdmin() async {
    if (_disposed) return;
    
    _setLoading(true);
    _clearError();
    _selectedCategory = '';
    _searchQuery = '';
    
    try {
      print('🔧 AdminItemViewModel: Fetching ALL items (including sold)...');
      
      // Get all items without filtering (admin needs to see everything)
      _allItems = await _itemService.getAllItemsForAdmin(); // Use admin method to get all items
      
      if (!_disposed) {
        _filteredItems = List.from(_allItems);
        print('✅ AdminItemViewModel: Loaded ${_allItems.length} total items');
        _safeNotifyListeners();
      }
    } catch (e) {
      if (!_disposed) {
        print('❌ AdminItemViewModel: Error loading items: $e');
        _setError('Failed to load items: ${e.toString()}');
      }
    } finally {
      if (!_disposed) {
        _setLoading(false);
      }
    }
  }

  // Filter items by category
  Future<void> filterByCategory(String category) async {
    if (_disposed) return;
    
    _setLoading(true);
    _selectedCategory = category;
    
    try {
      print('📂 AdminItemViewModel: Filtering by category: $category');
      
      if (category.isEmpty || category == 'All') {
        _filteredItems = List.from(_allItems);
      } else {
        _filteredItems = _allItems.where((item) => 
          item.category.toLowerCase() == category.toLowerCase()).toList();
      }

      // Apply search filter if there's an active search
      if (_searchQuery.isNotEmpty) {
        _applySearchFilter();
      }
      
      if (!_disposed) {
        print('✅ AdminItemViewModel: Filtered to ${_filteredItems.length} items');
        _safeNotifyListeners();
      }
    } catch (e) {
      if (!_disposed) {
        _setError('Failed to filter items: ${e.toString()}');
      }
    } finally {
      if (!_disposed) {
        _setLoading(false);
      }
    }
  }

  // Search items by name or seller
  Future<void> searchItems(String query) async {
    if (_disposed) return;
    
    _searchQuery = query;
    
    try {
      print('🔍 AdminItemViewModel: Searching for: "$query"');
      
      // Start with category-filtered items or all items
      List<ItemModel> baseItems;
      if (_selectedCategory.isNotEmpty && _selectedCategory != 'All') {
        baseItems = _allItems.where((item) => 
          item.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
      } else {
        baseItems = List.from(_allItems);
      }

      if (query.trim().isEmpty) {
        _filteredItems = baseItems;
      } else {
        _filteredItems = baseItems.where((item) => 
          item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.sellerName.toLowerCase().contains(query.toLowerCase()) ||
          item.category.toLowerCase().contains(query.toLowerCase())).toList();
      }
      
      if (!_disposed) {
        print('✅ AdminItemViewModel: Found ${_filteredItems.length} items matching "$query"');
        _safeNotifyListeners();
      }
    } catch (e) {
      if (!_disposed) {
        _setError('Failed to search items: ${e.toString()}');
      }
    }
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) return;
    
    _filteredItems = _filteredItems.where((item) => 
      item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item.sellerName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  // Filter by status
  Future<void> filterByStatus(String status) async {
    if (_disposed) return;
    
    _setLoading(true);
    
    try {
      print('📊 AdminItemViewModel: Filtering by status: $status');
      
      List<ItemModel> baseItems = List.from(_allItems);
      
      // Apply category filter first if active
      if (_selectedCategory.isNotEmpty && _selectedCategory != 'All') {
        baseItems = baseItems.where((item) => 
          item.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
      }

      // Apply status filter
      if (status == 'All' || status.isEmpty) {
        _filteredItems = baseItems;
      } else if (status == 'Available') {
        _filteredItems = baseItems.where((item) => item.status != 'sold').toList();
      } else if (status == 'Sold') {
        _filteredItems = baseItems.where((item) => item.status == 'sold').toList();
      } else {
        _filteredItems = baseItems.where((item) => 
          item.status.toLowerCase() == status.toLowerCase()).toList();
      }

      // Apply search filter if active
      if (_searchQuery.isNotEmpty) {
        _applySearchFilter();
      }
      
      if (!_disposed) {
        print('✅ AdminItemViewModel: Filtered to ${_filteredItems.length} items with status "$status"');
        _safeNotifyListeners();
      }
    } catch (e) {
      if (!_disposed) {
        _setError('Failed to filter by status: ${e.toString()}');
      }
    } finally {
      if (!_disposed) {
        _setLoading(false);
      }
    }
  }

  // Refresh items
  Future<void> refreshItems() async {
    print('🔄 AdminItemViewModel: Refreshing all items...');
    await fetchAllItemsForAdmin();
  }

  // Admin action: Delete item
  Future<bool> deleteItem(String itemId) async {
    if (_disposed) return false;
    
    try {
      await _itemService.deleteItem(itemId);
      
      if (!_disposed) {
        // Remove from local lists
        _allItems.removeWhere((item) => item.id == itemId);
        _filteredItems.removeWhere((item) => item.id == itemId);
        _safeNotifyListeners();
      }
      return true;
    } catch (e) {
      if (!_disposed) {
        _setError('Failed to delete item: ${e.toString()}');
      }
      return false;
    }
  }

  // Admin action: Update item status
  Future<bool> updateItemStatus(String itemId, String newStatus) async {
    if (_disposed) return false;
    
    try {
      await _itemService.updateItem(itemId, {'status': newStatus});
      
      if (!_disposed) {
        // Update local item
        final itemIndex = _allItems.indexWhere((item) => item.id == itemId);
        if (itemIndex != -1) {
          _allItems[itemIndex] = _allItems[itemIndex].copyWith(status: newStatus);
        }
        
        final filteredIndex = _filteredItems.indexWhere((item) => item.id == itemId);
        if (filteredIndex != -1) {
          _filteredItems[filteredIndex] = _filteredItems[filteredIndex].copyWith(status: newStatus);
        }
        
        _safeNotifyListeners();
      }
      return true;
    } catch (e) {
      if (!_disposed) {
        _setError('Failed to update item status: ${e.toString()}');
      }
      return false;
    }
  }

  // Get items by seller (for admin review)
  List<ItemModel> getItemsBySeller(String sellerId) {
    return _allItems.where((item) => item.sellerId == sellerId).toList();
  }

  // Clear all filters
  void clearFilters() {
    _selectedCategory = '';
    _searchQuery = '';
    _filteredItems = List.from(_allItems);
    _safeNotifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (_disposed) return;
    _isLoading = loading;
    _safeNotifyListeners();
  }

  void _setError(String error) {
    if (_disposed) return;
    _errorMessage = error;
    _safeNotifyListeners();
  }

  void _clearError() {
    if (_disposed) return;
    _errorMessage = null;
  }

  // Get available categories from items
  List<String> get availableCategories {
    final categories = _allItems.map((item) => item.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  // Get seller statistics
  Map<String, int> get sellerStats {
    final Map<String, int> sellerCount = {};
    for (final item in _allItems) {
      sellerCount[item.sellerId] = (sellerCount[item.sellerId] ?? 0) + 1;
    }
    return sellerCount;
  }
}