// lib/presentation/viewmodels/order_history_viewmodel.dart
// This ViewModel is for SELLERS to see orders placed for their items
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/order_model.dart';
import '../../data/services/order_service.dart';

class OrderHistoryViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<OrderRequest> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _statistics = {};

  // Getters
  List<OrderRequest> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get statistics => _statistics;

  // Get orders by status for tabs
  List<OrderRequest> getOrdersByStatus(List<OrderStatus> statuses) {
    return _orders.where((order) => statuses.contains(order.status)).toList();
  }

  // Get orders by single status
  List<OrderRequest> getOrdersByStatus2(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get all pending orders (placed, confirmed)
  List<OrderRequest> get pendingOrders {
    return _orders.where((order) => [
      OrderStatus.placed,
      OrderStatus.confirmed,
      OrderStatus.pendingPayment,
    ].contains(order.status)).toList();
  }

  // Get completed orders
  List<OrderRequest> get completedOrders {
    return _orders.where((order) => order.status == OrderStatus.completed).toList();
  }

  // Get cancelled orders
  List<OrderRequest> get cancelledOrders {
    return _orders.where((order) => order.status == OrderStatus.cancelled).toList();
  }

  // CRITICAL: Load seller orders (orders for current user's items)
  Future<void> loadSellerOrders() async {
    final user = _auth.currentUser;
    if (user == null) {
      _setError('Please login to view your order history');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      print('🏪 Loading seller orders for user: ${user.uid}');
      _orders = await _orderService.getOrdersForSeller(user.uid);
      await _loadStatistics(user.uid);
      print('✅ Loaded ${_orders.length} orders for seller');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading seller orders: $e');
      _setError('Failed to load order history: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load statistics
  Future<void> _loadStatistics(String sellerId) async {
    try {
      _statistics = await _orderService.getSellerOrderStats(sellerId);
      print('📊 Statistics loaded: $_statistics');
    } catch (e) {
      print('❌ Error loading statistics: $e');
      _statistics = {};
    }
  }

  // CRITICAL: Update order status with validation and proper error handling
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus, {
    String? trackingNumber,
    String? cancelReason,
  }) async {
    try {
      print('📝 Seller updating order $orderId status to: $newStatus');
      _clearError(); // Clear previous errors
      
      // Find the order to validate current status
      final orderIndex = _orders.indexWhere((o) => o.id == orderId);
      if (orderIndex == -1) {
        print('❌ Order not found in local list: $orderId');
        _setError('Order not found');
        return false;
      }
      
      final order = _orders[orderIndex];
      
      // Validate transition
      if (!_isValidTransitionForSeller(order.status, newStatus)) {
        print('❌ Invalid status transition from ${order.status} to $newStatus');
        _setError('Invalid status transition from ${order.status} to $newStatus');
        return false;
      }
      
      // Update status in Firestore using enhanced OrderService method
      final success = await _orderService.updateOrderStatus(
        orderId, 
        newStatus,
        trackingNumber: trackingNumber,
        cancelReason: cancelReason,
      );
      
      if (success) {
        print('✅ Order status updated in Firestore, updating local state...');
        
        // Update local state immediately for UI responsiveness
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
          trackingNumber: trackingNumber ?? _orders[orderIndex].trackingNumber,
          cancelReason: cancelReason ?? _orders[orderIndex].cancelReason,
        );
        
        // Update timestamps based on status
        switch (newStatus) {
          case OrderStatus.shipped:
            _orders[orderIndex] = _orders[orderIndex].copyWith(
              shippedAt: DateTime.now(),
            );
            break;
          case OrderStatus.delivered:
            _orders[orderIndex] = _orders[orderIndex].copyWith(
              deliveredAt: DateTime.now(),
            );
            break;
          default:
            break;
        }
        
        // Reload statistics after successful update
        final user = _auth.currentUser;
        if (user != null) {
          await _loadStatistics(user.uid);
        }
        
        notifyListeners();
        print('✅ Order status updated successfully in UI');
        return true;
      } else {
        print('❌ Failed to update order status in Firestore');
        _setError('Failed to update order status in database');
        return false;
      }
    } catch (e) {
      print('❌ Error updating order status: $e');
      _setError('Error updating order status: ${e.toString()}');
      return false;
    }
  }

  // Validate status transitions for sellers (simplified without shipped states)
  bool _isValidTransitionForSeller(OrderStatus currentStatus, OrderStatus newStatus) {
    const sellerAllowedTransitions = {
      OrderStatus.placed: [OrderStatus.confirmed, OrderStatus.cancelled],
      OrderStatus.pendingPayment: [OrderStatus.confirmed, OrderStatus.cancelled],
      OrderStatus.confirmed: [OrderStatus.completed, OrderStatus.cancelled],
      OrderStatus.completed: [], // Final state
      OrderStatus.cancelled: [], // Final state
    };
    
    final allowedTransitions = sellerAllowedTransitions[currentStatus];
    if (allowedTransitions == null) {
      print('❌ No transitions defined for status: $currentStatus');
      return false;
    }
    
    final isValid = allowedTransitions.contains(newStatus);
    print('🔍 Transition validation: $currentStatus → $newStatus = $isValid');
    return isValid;
  }

  // CRITICAL: Quick action methods for common status updates
  Future<bool> confirmOrder(String orderId) async {
    print('🔄 Confirming order: $orderId');
    return await updateOrderStatus(orderId, OrderStatus.confirmed);
  }

  Future<bool> completeOrder(String orderId) async {
    print('🔄 Completing order: $orderId');
    return await updateOrderStatus(orderId, OrderStatus.completed);
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    print('🔄 Cancelling order: $orderId with reason: $reason');
    return await updateOrderStatus(orderId, OrderStatus.cancelled, cancelReason: reason);
  }

  // Refresh orders with error handling
  Future<void> refreshOrders() async {
    print('🔄 Refreshing orders...');
    await loadSellerOrders();
  }

  // Get order statistics for display
  Map<String, int> getOrderStats() {
    final stats = <String, int>{
      'total': _orders.length,
      'placed': _orders.where((o) => o.status == OrderStatus.placed).length,
      'pendingPayment': _orders.where((o) => o.status == OrderStatus.pendingPayment).length,
      'confirmed': _orders.where((o) => o.status == OrderStatus.confirmed).length,
      'completed': _orders.where((o) => o.status == OrderStatus.completed).length,
      'cancelled': _orders.where((o) => o.status == OrderStatus.cancelled).length,
    };

    print('📊 Order statistics: $stats');
    return stats;
  }

  // Get total revenue from completed orders
  double getTotalRevenue() {
    final revenue = _orders
        .where((order) => order.status == OrderStatus.completed)
        .fold(0.0, (sum, order) => sum + order.total);
    print('💰 Total revenue: RM${revenue.toStringAsFixed(2)}');
    return revenue;
  }

  // Get total items sold
  int getTotalItemsSold() {
    final itemsSold = _orders
        .where((order) => order.status == OrderStatus.completed)
        .fold(0, (sum, order) => sum + order.items.length);
    print('📦 Total items sold: $itemsSold');
    return itemsSold;
  }

  // Start listening to real-time updates
  void startListeningToOrders() {
    final user = _auth.currentUser;
    if (user == null) return;

    print('👂 Starting to listen to real-time order updates for seller: ${user.uid}');
    _orderService.getSellerOrdersStream(user.uid).listen((orders) {
      print('🔄 Real-time update received: ${orders.length} orders');
      _orders = orders;
      _loadStatistics(user.uid);
      notifyListeners();
    });
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    print('❌ ViewModel Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    print('🗑️ OrderHistoryViewModel disposed');
    super.dispose();
  }
}