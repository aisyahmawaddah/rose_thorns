// lib/presentation/viewmodels/seller_order_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/repositories/seller_order_repository.dart';
import '../../data/models/seller_order_model.dart';

class SellerOrderViewModel extends ChangeNotifier {
  final SellerOrderRepository _repository = SellerOrderRepository();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, int> _orderStatistics = {};
  Map<String, double> _revenueStatistics = {};
  
  // Stream subscriptions
  StreamSubscription<List<SellerOrder>>? _newOrdersSubscription;
  StreamSubscription<List<SellerOrder>>? _toShipOrdersSubscription;
  StreamSubscription<List<SellerOrder>>? _shippedOrdersSubscription;
  StreamSubscription<List<SellerOrder>>? _completedOrdersSubscription;
  StreamSubscription<List<SellerOrder>>? _recentOrdersSubscription;

  // Order lists
  List<SellerOrder> _newOrders = [];
  List<SellerOrder> _toShipOrders = [];
  List<SellerOrder> _shippedOrders = [];
  List<SellerOrder> _completedOrders = [];
  List<SellerOrder> _recentOrders = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, int> get orderStatistics => _orderStatistics;
  Map<String, double> get revenueStatistics => _revenueStatistics;
  
  List<SellerOrder> get newOrders => _newOrders;
  List<SellerOrder> get toShipOrders => _toShipOrders;
  List<SellerOrder> get shippedOrders => _shippedOrders;
  List<SellerOrder> get completedOrders => _completedOrders;
  List<SellerOrder> get recentOrders => _recentOrders;

  // Statistics getters
  int get totalOrders => _orderStatistics['total'] ?? 0;
  int get newOrdersCount => _orderStatistics['newOrders'] ?? 0;
  int get toShipOrdersCount => _orderStatistics['toShip'] ?? 0;
  int get shippedOrdersCount => _orderStatistics['shipped'] ?? 0;
  int get completedOrdersCount => _orderStatistics['completed'] ?? 0;
  int get cancelledOrdersCount => _orderStatistics['cancelled'] ?? 0;

  double get totalRevenue => _revenueStatistics['totalRevenue'] ?? 0.0;
  double get averageOrderValue => _revenueStatistics['averageOrderValue'] ?? 0.0;

  // Initialize the view model
  void initialize() {
    _initializeOrderStreams();
    _loadStatistics();
  }

  // Initialize order streams
  void _initializeOrderStreams() {
    try {
      // New Orders Stream
      _newOrdersSubscription = _repository.getNewOrdersStream().listen(
        (orders) {
          _newOrders = orders;
          _clearError();
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to load new orders: $error');
        },
      );

      // To Ship Orders Stream
      _toShipOrdersSubscription = _repository.getToShipOrdersStream().listen(
        (orders) {
          _toShipOrders = orders;
          _clearError();
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to load orders to ship: $error');
        },
      );

      // Shipped Orders Stream
      _shippedOrdersSubscription = _repository.getShippedOrdersStream().listen(
        (orders) {
          _shippedOrders = orders;
          _clearError();
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to load shipped orders: $error');
        },
      );

      // Completed Orders Stream
      _completedOrdersSubscription = _repository.getCompletedOrdersStream().listen(
        (orders) {
          _completedOrders = orders;
          _clearError();
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to load completed orders: $error');
        },
      );

      // Recent Orders Stream
      _recentOrdersSubscription = _repository.getRecentOrdersStream().listen(
        (orders) {
          _recentOrders = orders;
          _clearError();
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to load recent orders: $error');
        },
      );

    } catch (e) {
      _setError('Failed to initialize order streams: $e');
    }
  }

  // Load statistics
  Future<void> _loadStatistics() async {
    try {
      _setLoading(true);
      
      // Load order statistics
      _orderStatistics = await _repository.getOrderStatistics();
      
      // Load revenue statistics
      _revenueStatistics = await _repository.getRevenueStatistics();
      
      _clearError();
    } catch (e) {
      _setError('Failed to load statistics: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await _loadStatistics();
    // Streams will automatically refresh
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, SellerOrderStatus newStatus, {String? trackingNumber}) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _repository.updateOrderStatus(
        orderId, 
        newStatus, 
        trackingNumber: trackingNumber,
      );

      if (success) {
        // Refresh statistics after successful update
        await _loadStatistics();
        _clearError();
        return true;
      } else {
        _setError('Failed to update order status');
        return false;
      }
    } catch (e) {
      _setError('Error updating order status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Confirm order
  Future<bool> confirmOrder(String orderId) async {
    return await updateOrderStatus(orderId, SellerOrderStatus.confirmed);
  }

  // Mark as shipped
  Future<bool> markAsShipped(String orderId, {String? trackingNumber}) async {
    return await updateOrderStatus(orderId, SellerOrderStatus.shipped, trackingNumber: trackingNumber);
  }

  // Mark as delivered
  Future<bool> markAsDelivered(String orderId) async {
    return await updateOrderStatus(orderId, SellerOrderStatus.delivered);
  }

  // Process next status automatically
  Future<bool> processNextStatus(SellerOrder order, {String? trackingNumber}) async {
    final nextStatus = order.nextStatus;
    if (nextStatus != null) {
      return await updateOrderStatus(order.id, nextStatus, trackingNumber: trackingNumber);
    }
    return false;
  }

  // Get order by ID
  Future<SellerOrder?> getOrder(String orderId) async {
    try {
      return await _repository.getSellerOrder(orderId);
    } catch (e) {
      _setError('Failed to get order: $e');
      return null;
    }
  }

  // Add tracking number
  Future<bool> addTrackingNumber(String orderId, String trackingNumber) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _repository.addTrackingNumber(orderId, trackingNumber);
      
      if (!success) {
        _setError('Failed to add tracking number');
      }

      return success;
    } catch (e) {
      _setError('Error adding tracking number: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get orders by date range
  Future<List<SellerOrder>> getOrdersByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await _repository.getOrdersByDateRange(startDate, endDate);
    } catch (e) {
      _setError('Failed to get orders by date range: $e');
      return [];
    }
  }

  // Filter orders by search term
  List<SellerOrder> filterOrders(List<SellerOrder> orders, String searchTerm) {
    if (searchTerm.isEmpty) return orders;
    
    final lowerSearchTerm = searchTerm.toLowerCase();
    
    return orders.where((order) {
      return order.id.toLowerCase().contains(lowerSearchTerm) ||
             order.buyerName.toLowerCase().contains(lowerSearchTerm) ||
             order.items.any((item) => item.name.toLowerCase().contains(lowerSearchTerm)) ||
             order.statusDisplayText.toLowerCase().contains(lowerSearchTerm);
    }).toList();
  }

  // Get orders that need action
  List<SellerOrder> getOrdersNeedingAction() {
    final needingAction = <SellerOrder>[];
    needingAction.addAll(_newOrders);
    needingAction.addAll(_toShipOrders);
    
    // Sort by creation date, newest first
    needingAction.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return needingAction;
  }

  // Get orders by status
  List<SellerOrder> getOrdersByStatus(SellerOrderStatus status) {
    switch (status) {
      case SellerOrderStatus.placed:
      case SellerOrderStatus.pending:
        return _newOrders;
      case SellerOrderStatus.confirmed:
        return _toShipOrders;
      case SellerOrderStatus.shipped:
        return _shippedOrders;
      case SellerOrderStatus.delivered:
      case SellerOrderStatus.completed:
        return _completedOrders;
      case SellerOrderStatus.cancelled:
        // You might want to add a separate stream for cancelled orders
        return [];
    }
  }

  // Validation helpers
  bool canUpdateOrderStatus(SellerOrder order) {
    return _repository.canUpdateStatus(order.status);
  }

  String getNextActionText(SellerOrder order) {
    return _repository.getNextActionText(order.status);
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
    notifyListeners();
  }

  // Format helpers for UI
  String formatCurrency(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color getStatusColor(SellerOrderStatus status) {
    switch (status) {
      case SellerOrderStatus.placed:
      case SellerOrderStatus.pending:
        return Colors.orange;
      case SellerOrderStatus.confirmed:
        return const Color(0xFF9C27B0);
      case SellerOrderStatus.shipped:
        return Colors.purple;
      case SellerOrderStatus.delivered:
      case SellerOrderStatus.completed:
        return Colors.green;
      case SellerOrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData getStatusIcon(SellerOrderStatus status) {
    switch (status) {
      case SellerOrderStatus.placed:
      case SellerOrderStatus.pending:
        return Icons.new_releases;
      case SellerOrderStatus.confirmed:
        return Icons.check_circle;
      case SellerOrderStatus.shipped:
        return Icons.local_shipping;
      case SellerOrderStatus.delivered:
        return Icons.done_all;
      case SellerOrderStatus.completed:
        return Icons.star;
      case SellerOrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    _newOrdersSubscription?.cancel();
    _toShipOrdersSubscription?.cancel();
    _shippedOrdersSubscription?.cancel();
    _completedOrdersSubscription?.cancel();
    _recentOrdersSubscription?.cancel();
    
    super.dispose();
  }
}