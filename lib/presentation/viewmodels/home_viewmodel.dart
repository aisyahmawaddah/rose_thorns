// lib/viewmodels/home_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:koopon/presentation/views/home_screen.dart';
import '../../data/models/item_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ItemRepository _itemRepository = ItemRepository();
  final UserRepository _userRepository = UserRepository();
  final AuthService _authService = AuthService();
  
  List<ItemModel> _items = [];
  List<ItemModel> get items => _items;
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  
  String _selectedCategory = '';
  String get selectedCategory => _selectedCategory;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  HomeViewModel() {
    initialize();
  }
  
  // Initialize the view model
  Future<void> initialize() async {
    _setLoading(true);
    await _loadCurrentUser();
    await fetchAllItems();
    _setLoading(false);
  }
  
  // Load current user data
  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _userRepository.getCurrentUserData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user data: $e');
    }
  }
  
  // Fetch all available items
  Future<void> fetchAllItems() async {
    try {
      _setLoading(true);
      _items = await _itemRepository.getAllAvailableItems();
      _selectedCategory = '';
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch items: $e');
    }
  }
  
  // Fetch items by category
  Future<void> fetchItemsByCategory(String category) async {
    try {
      _setLoading(true);
      _items = await _itemRepository.getItemsByCategory(category);
      _selectedCategory = category;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch items: $e');
    }
  }
  
  // Search items
  Future<void> searchItems(String query) async {
    try {
      if (query.isEmpty) {
        await fetchAllItems();
        return;
      }
      
      _setLoading(true);
      _items = await _itemRepository.searchItems(query);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to search items: $e');
    }
  }
  
  // Delete item
  Future<bool> deleteItem(String itemId) async {
    try {
      bool success = await _itemRepository.deleteItem(itemId);
      if (success) {
        _items.removeWhere((item) => item.id == itemId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to delete item: $e');
      return false;
    }
  }
  
  // Get item seller data
  Future<UserModel?> getItemSeller(String sellerId) async {
    try {
      return await _userRepository.getUserById(sellerId);
    } catch (e) {
      _setError('Failed to get seller data: $e');
      return null;
    }
  }
  
  // Check if current user is seller of the item
  bool isCurrentUserSeller(String sellerId) {
    return _currentUser?.id == sellerId;
  }
  
  // Get categories
  List<CategoryModel> getCategories() {
    return CategoryModel.predefinedCategories;
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
    // Clear error after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _errorMessage = null;
      notifyListeners();
    });
  }
}

class ItemRepository {
  getAllAvailableItems() {}
  
  getItemsByCategory(String category) {}
  
  searchItems(String query) {}
  
  deleteItem(String itemId) {}
}