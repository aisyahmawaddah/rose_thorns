// lib/presentation/viewmodels/order_history_viewmodel.dart
import 'package:flutter/material.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/models/order_model.dart';

class OrderHistoryViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();
  
  bool _isLoading = false;
  String? _error;
  List<OrderRequest> _orders = [];
  OrderStatus? _selectedFilter;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<OrderRequest> get orders => _selectedFilter == null 
      ? _orders 
      : _orders.where((order) => order.status == _selectedFilter).toList();
  OrderStatus? get selectedFilter => _selectedFilter;

  // Load order history
  Future<void> loadOrderHistory() async {
    _setLoading(true);
    try {
      _orders = await _orderRepository.getOrderHistory();
      _clearError();
    } catch (e) {
      _setError('Failed to load order history: $e');
    }
    _setLoading(false);
  }

  // Set filter
  void setFilter(OrderStatus? status) {
    _selectedFilter = status;
    notifyListeners();
  }

  // Clear filter
  void clearFilter() {
    _selectedFilter = null;
    notifyListeners();
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final success = await _orderRepository.updateOrderStatus(orderId, status);
      if (success) {
        await loadOrderHistory();
        _clearError();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update order status: $e');
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}