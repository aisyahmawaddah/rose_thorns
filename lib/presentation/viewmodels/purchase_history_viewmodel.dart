// lib/presentation/viewmodels/purchase_history_viewmodel.dart
// This ViewModel is for BUYERS to see their purchase history
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/order_model.dart';
import '../../data/services/order_service.dart';

class PurchaseHistoryViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<OrderRequest> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<OrderRequest> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get orders by status for tabs
  List<OrderRequest> getOrdersByStatus(List<OrderStatus> statuses) {
    return _orders.where((order) => statuses.contains(order.status)).toList();
  }

  // Load order history for current user (buyer perspective)
  Future<void> loadOrderHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      _setError('Please login to view your purchase history');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      print('🛒 Loading purchase history for user: ${user.uid}');
      _orders = await _orderService.getOrdersForUser(user.uid);
      print('✅ Loaded ${_orders.length} orders for user');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading purchase history: $e');
      _setError('Failed to load purchase history: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // ENHANCED: Cancel an order (buyer can cancel placed orders)
  // This will update the status in Firestore, which automatically updates seller's view too
  Future<bool> cancelOrder(String orderId) async {
    try {
      print('🚫 Buyer cancelling order: $orderId');
      
      // Update status in Firestore - this affects both buyer and seller views
      final success = await _orderService.updateOrderStatus(orderId, OrderStatus.cancelled);
      
      if (success) {
        // Update local state for immediate UI feedback
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = OrderRequest(
            id: _orders[orderIndex].id,
            userId: _orders[orderIndex].userId,
            sellerId: _orders[orderIndex].sellerId,
            items: _orders[orderIndex].items,
            dealMethod: _orders[orderIndex].dealMethod,
            meetupLocation: _orders[orderIndex].meetupLocation,
            selectedDate: _orders[orderIndex].selectedDate,
            selectedTimeSlot: _orders[orderIndex].selectedTimeSlot,
            subtotal: _orders[orderIndex].subtotal,
            deliveryFee: _orders[orderIndex].deliveryFee,
            total: _orders[orderIndex].total,
            status: OrderStatus.cancelled, // UPDATED: Status changed to cancelled
            createdAt: _orders[orderIndex].createdAt,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
        
        print('✅ Order cancelled successfully - status updated in Firestore');
        print('📡 Seller will automatically see this cancellation in their order history');
        return true;
      } else {
        print('❌ Failed to cancel order');
        return false;
      }
    } catch (e) {
      print('❌ Error cancelling order: $e');
      return false;
    }
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadOrderHistory();
  }

  // Get purchase statistics
  Map<String, int> getPurchaseStats() {
    final stats = <String, int>{
      'total': _orders.length,
      'placed': 0,
      'confirmed': 0,
      'completed': 0,
      'cancelled': 0,
    };

    for (final order in _orders) {
      switch (order.status) {
        case OrderStatus.placed:
          stats['placed'] = (stats['placed'] ?? 0) + 1;
          break;
        case OrderStatus.confirmed:
          stats['confirmed'] = (stats['confirmed'] ?? 0) + 1;
          break;
        case OrderStatus.completed:
          stats['completed'] = (stats['completed'] ?? 0) + 1;
          break;
        case OrderStatus.cancelled:
          stats['cancelled'] = (stats['cancelled'] ?? 0) + 1;
          break;
      }
    }

    return stats;
  }

  // Get total spent
  double getTotalSpent() {
    return _orders
        .where((order) => order.status == OrderStatus.completed)
        .fold(0.0, (sum, order) => sum + order.total);
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