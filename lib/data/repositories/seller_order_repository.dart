// lib/data/repositories/seller_order_repository.dart
import '../services/seller_order_service.dart';
import '../models/seller_order_model.dart';

class SellerOrderRepository {
  final SellerOrderService _sellerOrderService = SellerOrderService();

  // Get orders that need action from seller
  Stream<List<SellerOrder>> getOrdersNeedingActionStream() {
    return _sellerOrderService.getOrdersNeedingActionStream();
  }

  // Get recent orders (last 30 days)
  Stream<List<SellerOrder>> getRecentOrdersStream() {
    return _sellerOrderService.getRecentOrdersStream();
  }

  // Add tracking number to shipped order
  Future<bool> addTrackingNumber(String orderId, String trackingNumber) async {
    try {
      return await _sellerOrderService.addTrackingNumber(orderId, trackingNumber);
    } catch (e) {
      print('Repository error adding tracking number: $e');
      return false;
    }
  }

  // Get orders by date range
  Future<List<SellerOrder>> getOrdersByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await _sellerOrderService.getOrdersByDateRange(startDate, endDate);
    } catch (e) {
      print('Repository error getting orders by date range: $e');
      return [];
    }
  }

  // Helper methods for specific actions
  Future<bool> processNextStatus(String orderId, SellerOrderStatus currentStatus, {String? trackingNumber}) async {
    SellerOrderStatus? nextStatus;
    
    switch (currentStatus) {
      case SellerOrderStatus.placed:
      case SellerOrderStatus.pending:
        nextStatus = SellerOrderStatus.confirmed;
        break;
      case SellerOrderStatus.confirmed:
        nextStatus = SellerOrderStatus.shipped;
        break;
      case SellerOrderStatus.shipped:
        nextStatus = SellerOrderStatus.delivered;
        break;
      case SellerOrderStatus.delivered:
        nextStatus = SellerOrderStatus.completed;
        break;
      default:
        return false;
    }

    if (nextStatus != null) {
      return await updateOrderStatus(orderId, nextStatus, trackingNumber: trackingNumber);
    }
    
    return false;
  }

  // Validation helpers
  bool canUpdateStatus(SellerOrderStatus currentStatus) {
    return [
      SellerOrderStatus.placed,
      SellerOrderStatus.pending,
      SellerOrderStatus.confirmed,
      SellerOrderStatus.shipped,
    ].contains(currentStatus);
  }

  String getNextActionText(SellerOrderStatus currentStatus) {
    switch (currentStatus) {
      case SellerOrderStatus.placed:
      case SellerOrderStatus.pending:
        return 'Confirm Order';
      case SellerOrderStatus.confirmed:
        return 'Mark as Shipped';
      case SellerOrderStatus.shipped:
        return 'Mark as Delivered';
      case SellerOrderStatus.delivered:
        return 'Mark as Completed';
      default:
        return 'Update Status';
    }
  }

  // Get count of orders by status
  Future<int> getOrderCountByStatus(SellerOrderStatus status) async {
    try {
      final stats = await getOrderStatistics();
      switch (status) {
        case SellerOrderStatus.placed:
        case SellerOrderStatus.pending:
          return stats['newOrders'] ?? 0;
        case SellerOrderStatus.confirmed:
          return stats['toShip'] ?? 0;
        case SellerOrderStatus.shipped:
          return stats['shipped'] ?? 0;
        case SellerOrderStatus.delivered:
        case SellerOrderStatus.completed:
          return stats['completed'] ?? 0;
        case SellerOrderStatus.cancelled:
          return stats['cancelled'] ?? 0;
      }
    } catch (e) {
      print('Repository error getting order count by status: $e');
      return 0;
    }
}

// Get all seller orders as a stream
Stream<List<SellerOrder>> getSellerOrdersStream() {
  return _sellerOrderService.getSellerOrdersStream();
}

// Get orders by status as a stream
Stream<List<SellerOrder>> getOrdersByStatusStream(List<SellerOrderStatus> statuses) {
  return _sellerOrderService.getSellerOrdersByStatusStream(statuses);
}

// Get new orders (placed, pending)
Stream<List<SellerOrder>> getNewOrdersStream() {
  return _sellerOrderService.getSellerOrdersByStatusStream([
    SellerOrderStatus.placed,
    SellerOrderStatus.pending,
  ]);
}

// Get orders to ship (confirmed)
Stream<List<SellerOrder>> getToShipOrdersStream() {
  return _sellerOrderService.getSellerOrdersByStatusStream([
    SellerOrderStatus.confirmed,
  ]);
}

// Get shipped orders
Stream<List<SellerOrder>> getShippedOrdersStream() {
  return _sellerOrderService.getSellerOrdersByStatusStream([
    SellerOrderStatus.shipped,
  ]);
}

// Get completed orders (delivered, completed)
Stream<List<SellerOrder>> getCompletedOrdersStream() {
  return _sellerOrderService.getSellerOrdersByStatusStream([
    SellerOrderStatus.delivered,
    SellerOrderStatus.completed,
  ]);
}

// Get single order by ID
Future<SellerOrder?> getSellerOrder(String orderId) async {
  try {
    return await _sellerOrderService.getSellerOrder(orderId);
  } catch (e) {
    print('Repository error getting seller order: $e');
    return null;
  }
}

// Update order status
Future<bool> updateOrderStatus(String orderId, SellerOrderStatus newStatus, {String? trackingNumber}) async {
  try {
    return await _sellerOrderService.updateOrderStatus(orderId, newStatus, trackingNumber: trackingNumber);
  } catch (e) {
    print('Repository error updating order status: $e');
    return false;
  }
}

// Confirm order (pending/placed -> confirmed)
Future<bool> confirmOrder(String orderId) async {
  return await updateOrderStatus(orderId, SellerOrderStatus.confirmed);
}

// Mark order as shipped (confirmed -> shipped)
Future<bool> markAsShipped(String orderId, {String? trackingNumber}) async {
  return await updateOrderStatus(orderId, SellerOrderStatus.shipped, trackingNumber: trackingNumber);
}

// Mark order as delivered (shipped -> delivered)
Future<bool> markAsDelivered(String orderId) async {
  return await updateOrderStatus(orderId, SellerOrderStatus.delivered);
}

// Mark order as completed (delivered -> completed)
Future<bool> markAsCompleted(String orderId) async {
  return await updateOrderStatus(orderId, SellerOrderStatus.completed);
}

// Get order statistics
Future<Map<String, int>> getOrderStatistics() async {
  try {
    return await _sellerOrderService.getSellerOrderStatistics();
  } catch (e) {
    print('Repository error getting order statistics: $e');
    return {
      'total': 0,
      'newOrders': 0,
      'toShip': 0,
      'shipped': 0,
      'completed': 0,
      'cancelled': 0,
    };
  }
}

// Get revenue statistics
Future<Map<String, double>> getRevenueStatistics() async {
  try {
    return await _sellerOrderService.getSellerRevenueStatistics();
  } catch (e) {
    print('Repository error getting revenue statistics: $e');
    return {
      'totalRevenue': 0.0,
      'averageOrderValue': 0.0,
      'completedOrdersCount': 0.0,
    };
  }
}
}