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

  // Get all pending orders (placed, confirmed, shipped)
  List<OrderRequest> get pendingOrders {
    return _orders.where((order) => [
      OrderStatus.placed,
      OrderStatus.confirmed,
      OrderStatus.shipped,
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

  // Load seller orders (orders for current user's items)
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

  // ENHANCED: Update order status with validation
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus, {
    String? trackingNumber,
    String? cancelReason,
  }) async {
    try {
      print('📝 Seller updating order $orderId status to: $newStatus');
      
      // Find the order to validate current status
      final order = _orders.firstWhere((o) => o.id == orderId);
      
      // Validate transition
      if (!_isValidTransitionForSeller(order.status, newStatus)) {
        print('❌ Invalid status transition from ${order.status} to $newStatus');
        _setError('Invalid status transition');
        return false;
      }
      
      // Update status in Firestore
      final success = await _orderService.updateOrderStatus(
        orderId, 
        newStatus,
        trackingNumber: trackingNumber,
        cancelReason: cancelReason,
      );
      
      if (success) {
        // Update local state for immediate UI feedback
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
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
          
          // Recalculate statistics
          await _loadStatistics(_auth.currentUser!.uid);
          notifyListeners();
        }
        
        print('✅ Order status updated successfully');
        return true;
      } else {
        print('❌ Failed to update order status');
        _setError('Failed to update order status');
        return false;
      }
    } catch (e) {
      print('❌ Error updating order status: $e');
      _setError('Error updating order status: $e');
      return false;
    }
  }

  // Validate status transitions for sellers
  bool _isValidTransitionForSeller(OrderStatus currentStatus, OrderStatus newStatus) {
    const sellerAllowedTransitions = {
      OrderStatus.placed: [OrderStatus.confirmed, OrderStatus.cancelled],
      OrderStatus.pendingPayment: [OrderStatus.confirmed, OrderStatus.cancelled],
      OrderStatus.confirmed: [OrderStatus.shipped, OrderStatus.completed, OrderStatus.cancelled],
      OrderStatus.shipped: [OrderStatus.delivered, OrderStatus.cancelled],
      OrderStatus.delivered: [OrderStatus.completed],
      OrderStatus.completed: [], // Final state
      OrderStatus.cancelled: [], // Final state
    };
    
    return sellerAllowedTransitions[currentStatus]?.contains(newStatus) ?? false;
  }

  // Quick action methods for common status updates
  Future<bool> confirmOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.confirmed);
  }

  Future<bool> shipOrder(String orderId, {String? trackingNumber}) async {
    return await updateOrderStatus(orderId, OrderStatus.shipped, trackingNumber: trackingNumber);
  }

  Future<bool> markAsDelivered(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.delivered);
  }

  Future<bool> completeOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.completed);
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    return await updateOrderStatus(orderId, OrderStatus.cancelled, cancelReason: reason);
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadSellerOrders();
  }

  // Get order statistics for display
  Map<String, int> getOrderStats() {
    final stats = <String, int>{
      'total': _orders.length,
      'placed': _orders.where((o) => o.status == OrderStatus.placed).length,
      'pendingPayment': _orders.where((o) => o.status == OrderStatus.pendingPayment).length,
      'confirmed': _orders.where((o) => o.status == OrderStatus.confirmed).length,
      'shipped': _orders.where((o) => o.status == OrderStatus.shipped).length,
      'delivered': _orders.where((o) => o.status == OrderStatus.delivered).length,
      'completed': _orders.where((o) => o.status == OrderStatus.completed).length,
      'cancelled': _orders.where((o) => o.status == OrderStatus.cancelled).length,
    };

    return stats;
  }

  // Get total revenue from completed orders
  double getTotalRevenue() {
    return _orders
        .where((order) => order.status == OrderStatus.completed)
        .fold(0.0, (sum, order) => sum + order.total);
  }

  // Get total items sold
  int getTotalItemsSold() {
    return _orders
        .where((order) => order.status == OrderStatus.completed)
        .fold(0, (sum, order) => sum + order.items.length);
  }

  // Start listening to real-time updates
  void startListeningToOrders() {
    final user = _auth.currentUser;
    if (user == null) return;

    _orderService.getSellerOrdersStream(user.uid).listen((orders) {
      _orders = orders;
      _loadStatistics(user.uid);
      notifyListeners();
    });
  }

  // Stop listening to real-time updates
  void stopListeningToOrders() {
    // Stream subscriptions are automatically cancelled when the widget is disposed
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