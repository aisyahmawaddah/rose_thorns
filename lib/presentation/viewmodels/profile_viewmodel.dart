// lib/presentation/viewmodels/profile_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/order_service.dart';
import '../../data/models/item_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/order_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final ItemRepository _itemRepository = ItemRepository();
  final UserRepository _userRepository = UserRepository();
  final OrderService _orderService = OrderService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State variables
  List<ItemModel> _userItems = [];
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  
  // Order statistics
  List<OrderRequest> _sellerOrders = [];
  int _totalSoldItems = 0;
  double _totalRevenue = 0.0;
  double _averageRating = 5.0;

  // Getters
  List<ItemModel> get userItems => _userItems;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  List<OrderRequest> get sellerOrders => _sellerOrders;
  int get totalSoldItems => _totalSoldItems;
  double get totalRevenue => _totalRevenue;
  double get averageRating => _averageRating;

  // User info getters
  String get currentUserDisplayName {
    return _currentUser?.displayName ?? 
           _auth.currentUser?.displayName ?? 
           _auth.currentUser?.email?.split('@').first ?? 
           'User';
  }

  String get currentUserEmail {
    return _currentUser?.email ?? 
           _auth.currentUser?.email ?? 
           'No email';
  }

  String? get currentUserPhotoUrl {
    return _currentUser?.profileImageUrl ?? 
           _auth.currentUser?.photoURL;
  }

  // Initialize the view model
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('🚀 ProfileViewModel: Initializing...');
    _setLoading(true);
    
    try {
      await _loadCurrentUser();
      await Future.wait([
        _loadUserItems(),
        _loadSellerOrders(),
      ]);
      _calculateStatistics();
      _isInitialized = true;
      print('✅ ProfileViewModel: Initialization completed');
    } catch (e) {
      print('❌ ProfileViewModel: Initialization error: $e');
      _setError('Failed to load profile data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load current user data
  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _userRepository.getCurrentUserData();
      print('📱 ProfileViewModel: Current user loaded: ${_currentUser?.displayName}');
    } catch (e) {
      print('❌ ProfileViewModel: Error loading current user: $e');
    }
  }

  // Load user's items
  Future<void> _loadUserItems() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('🔍 ProfileViewModel: Loading items for user: ${user.uid}');
      _userItems = await _itemRepository.getItemsBySeller(user.uid);
      print('✅ ProfileViewModel: Loaded ${_userItems.length} items');
    } catch (e) {
      print('❌ ProfileViewModel: Error loading user items: $e');
      _userItems = [];
    }
  }

  // Load seller orders (orders for this user's items)
  Future<void> _loadSellerOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('🔍 ProfileViewModel: Loading seller orders for user: ${user.uid}');
      _sellerOrders = await _orderService.getOrdersForSeller(user.uid);
      print('✅ ProfileViewModel: Loaded ${_sellerOrders.length} seller orders');
    } catch (e) {
      print('❌ ProfileViewModel: Error loading seller orders: $e');
      _sellerOrders = [];
    }
  }

  // Calculate statistics from orders
  void _calculateStatistics() {
    print('📊 ProfileViewModel: Calculating statistics...');
    
    // Calculate total sold items
    _totalSoldItems = 0;
    _totalRevenue = 0.0;
    
    // Count completed orders only for revenue and sold items
    final completedOrders = _sellerOrders.where(
      (order) => order.status == OrderStatus.completed
    ).toList();
    
    for (final order in completedOrders) {
      _totalSoldItems += order.items.length;
      _totalRevenue += order.total;
    }
    
    // Calculate sold items from item status as well (backup calculation)
    final soldItemsFromStatus = _userItems.where(
      (item) => item.status == 'sold'
    ).length;
    
    // Use the higher count (more accurate)
    if (soldItemsFromStatus > _totalSoldItems) {
      _totalSoldItems = soldItemsFromStatus;
    }
    
    print('📈 ProfileViewModel: Statistics calculated:');
    print('   Total sold items: $_totalSoldItems');
    print('   Total revenue: RM${_totalRevenue.toStringAsFixed(2)}');
    print('   Average rating: $_averageRating');
  }

  // Refresh user items
  Future<void> refreshUserItems() async {
    print('🔄 ProfileViewModel: Refreshing user items...');
    _setLoading(true);
    
    try {
      await _loadUserItems();
      await _loadSellerOrders(); // Also refresh orders to update statistics
      _calculateStatistics();
      _clearError();
      print('✅ ProfileViewModel: User items refreshed');
    } catch (e) {
      print('❌ ProfileViewModel: Error refreshing user items: $e');
      _setError('Failed to refresh items: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh entire profile
  Future<void> refreshProfile() async {
    print('🔄 ProfileViewModel: Refreshing entire profile...');
    _setLoading(true);
    
    try {
      await _loadCurrentUser();
      await Future.wait([
        _loadUserItems(),
        _loadSellerOrders(),
      ]);
      _calculateStatistics();
      _clearError();
      print('✅ ProfileViewModel: Profile refreshed');
    } catch (e) {
      print('❌ ProfileViewModel: Error refreshing profile: $e');
      _setError('Failed to refresh profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete item
  Future<bool> deleteItem(String itemId) async {
  try {
    _setLoading(true);
    
    // Delete from service
    await _itemRepository.deleteItem(itemId);
    
    // IMMEDIATELY remove from local list for instant UI update
    _userItems.removeWhere((item) => item.id == itemId);
    notifyListeners(); // Update UI immediately
    
    // Recalculate statistics after deletion
    _calculateStatistics();
    
    _setLoading(false);
    return true;
  } catch (e) {
    print('Error deleting item: $e');
    _errorMessage = e.toString();
    _setLoading(false);
    notifyListeners();
    return false;
  }
}

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('📝 ProfileViewModel: Updating user profile...');
      await _userRepository.updateUserData(user.uid, updates);
      
      // Refresh current user data
      await _loadCurrentUser();
      
      print('✅ ProfileViewModel: Profile updated successfully');
      return true;
    } catch (e) {
      print('❌ ProfileViewModel: Error updating profile: $e');
      _setError('Failed to update profile: $e');
      return false;
    }
  }

  // Get order statistics for display
  Map<String, dynamic> getOrderStatistics() {
    final allOrders = _sellerOrders.length;
    final completedOrders = _sellerOrders.where(
      (order) => order.status == OrderStatus.completed
    ).length;
    final pendingOrders = _sellerOrders.where(
      (order) => [OrderStatus.placed, OrderStatus.confirmed, OrderStatus.shipped].contains(order.status)
    ).length;
    final cancelledOrders = _sellerOrders.where(
      (order) => order.status == OrderStatus.cancelled
    ).length;

    return {
      'totalOrders': allOrders,
      'completedOrders': completedOrders,
      'pendingOrders': pendingOrders,
      'cancelledOrders': cancelledOrders,
      'totalSoldItems': _totalSoldItems,
      'totalRevenue': _totalRevenue,
      'averageRating': _averageRating,
    };
  }

  // Listen to real-time order updates (optional enhancement)
  void startListeningToOrderUpdates() {
    final user = _auth.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      print('🔄 ProfileViewModel: Real-time order update received');
      _loadSellerOrders().then((_) {
        _calculateStatistics();
        notifyListeners();
      });
    });
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

  @override
  void dispose() {
    super.dispose();
  }
}