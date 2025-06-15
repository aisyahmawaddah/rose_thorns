// lib/data/services/seller_order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/seller_order_model.dart';

class SellerOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all orders for the current seller
  Stream<List<SellerOrder>> getSellerOrdersStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }

    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SellerOrder.fromFirestore(doc))
            .toList());
  }

  // Get orders by status for the current seller
  Stream<List<SellerOrder>> getSellerOrdersByStatusStream(List<SellerOrderStatus> statuses) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }

    final statusNames = statuses.map((s) => s.name).toList();

    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: currentUser.uid)
        .where('status', whereIn: statusNames)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SellerOrder.fromFirestore(doc))
            .toList());
  }

  // Get single order by ID (seller must own the order)
  Future<SellerOrder?> getSellerOrder(String orderId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final doc = await _firestore.collection('orders').doc(orderId).get();
      
      if (!doc.exists) {
        return null;
      }

      final order = SellerOrder.fromFirestore(doc);
      
      // Verify that the current user is the seller
      if (order.sellerId != currentUser.uid) {
        throw Exception('Access denied: You are not the seller of this order');
      }

      return order;
    } catch (e) {
      print('Error getting seller order: $e');
      return null;
    }
  }

  // Update order status (following Firestore rules)
  Future<bool> updateOrderStatus(String orderId, SellerOrderStatus newStatus, {String? trackingNumber}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // First, verify the order belongs to the current seller
      final order = await getSellerOrder(orderId);
      if (order == null) {
        throw Exception('Order not found or access denied');
      }

      // Validate status transition
      if (!_isValidStatusTransition(order.status, newStatus)) {
        throw Exception('Invalid status transition from ${order.status.name} to ${newStatus.name}');
      }

      // Prepare update data
      final Map<String, dynamic> updateData = {
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add timestamp for specific status changes
      switch (newStatus) {
        case SellerOrderStatus.confirmed:
          updateData['confirmedAt'] = FieldValue.serverTimestamp();
          break;
        case SellerOrderStatus.shipped:
          updateData['shippedAt'] = FieldValue.serverTimestamp();
          if (trackingNumber != null && trackingNumber.isNotEmpty) {
            updateData['trackingNumber'] = trackingNumber;
          }
          break;
        case SellerOrderStatus.delivered:
          updateData['deliveredAt'] = FieldValue.serverTimestamp();
          break;
        case SellerOrderStatus.completed:
          updateData['completedAt'] = FieldValue.serverTimestamp();
          break;
        default:
          break;
      }

      // Update the order
      await _firestore.collection('orders').doc(orderId).update(updateData);

      // Create notification for buyer (optional)
      await _createOrderStatusNotification(orderId, order.userId, newStatus);

      print('Order $orderId status updated to ${newStatus.name}');
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Validate status transition
  bool _isValidStatusTransition(SellerOrderStatus currentStatus, SellerOrderStatus newStatus) {
    // Define valid transitions
    switch (currentStatus) {
      case SellerOrderStatus.placed:
      case SellerOrderStatus.pending:
        return newStatus == SellerOrderStatus.confirmed;
      case SellerOrderStatus.confirmed:
        return newStatus == SellerOrderStatus.shipped;
      case SellerOrderStatus.shipped:
        return newStatus == SellerOrderStatus.delivered;
      case SellerOrderStatus.delivered:
        return newStatus == SellerOrderStatus.completed;
      default:
        return false;
    }
  }

  // Get order statistics for seller
  Future<Map<String, int>> getSellerOrderStatistics() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: currentUser.uid)
          .get();

      final Map<String, int> stats = {
        'total': 0,
        'newOrders': 0,
        'toShip': 0,
        'shipped': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (final doc in snapshot.docs) {
        final order = SellerOrder.fromFirestore(doc);
        stats['total'] = stats['total']! + 1;

        switch (order.status) {
          case SellerOrderStatus.placed:
          case SellerOrderStatus.pending:
            stats['newOrders'] = stats['newOrders']! + 1;
            break;
          case SellerOrderStatus.confirmed:
            stats['toShip'] = stats['toShip']! + 1;
            break;
          case SellerOrderStatus.shipped:
            stats['shipped'] = stats['shipped']! + 1;
            break;
          case SellerOrderStatus.delivered:
          case SellerOrderStatus.completed:
            stats['completed'] = stats['completed']! + 1;
            break;
          case SellerOrderStatus.cancelled:
            stats['cancelled'] = stats['cancelled']! + 1;
            break;
        }
      }

      return stats;
    } catch (e) {
      print('Error getting seller order statistics: $e');
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
  Future<Map<String, double>> getSellerRevenueStatistics() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: currentUser.uid)
          .where('status', whereIn: ['delivered', 'completed'])
          .get();

      double totalRevenue = 0.0;
      int completedOrders = 0;

      for (final doc in snapshot.docs) {
        final order = SellerOrder.fromFirestore(doc);
        totalRevenue += order.total;
        completedOrders++;
      }

      return {
        'totalRevenue': totalRevenue,
        'averageOrderValue': completedOrders > 0 ? totalRevenue / completedOrders : 0.0,
        'completedOrdersCount': completedOrders.toDouble(),
      };
    } catch (e) {
      print('Error getting seller revenue statistics: $e');
      return {
        'totalRevenue': 0.0,
        'averageOrderValue': 0.0,
        'completedOrdersCount': 0.0,
      };
    }
  }

  // Create notification for order status update
  Future<void> _createOrderStatusNotification(String orderId, String buyerId, SellerOrderStatus newStatus) async {
    try {
      final notificationData = {
        'userId': buyerId,
        'title': 'Order Status Updated',
        'message': 'Your order has been ${newStatus.name}',
        'type': 'order_status_update',
        'orderId': orderId,
        'status': newStatus.name,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('notifications').add(notificationData);
      print('Notification created for order status update');
    } catch (e) {
      print('Error creating notification: $e');
      // Don't throw error as this is not critical
    }
  }

  // Get orders that need action (new orders and confirmed orders)
  Stream<List<SellerOrder>> getOrdersNeedingActionStream() {
    return getSellerOrdersByStatusStream([
      SellerOrderStatus.placed,
      SellerOrderStatus.pending,
      SellerOrderStatus.confirmed,
    ]);
  }

  // Get recent orders (last 30 days)
  Stream<List<SellerOrder>> getRecentOrdersStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: currentUser.uid)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SellerOrder.fromFirestore(doc))
            .toList());
  }

  // Add tracking number to shipped order
  Future<bool> addTrackingNumber(String orderId, String trackingNumber) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Verify order belongs to seller and is shipped
      final order = await getSellerOrder(orderId);
      if (order == null || order.status != SellerOrderStatus.shipped) {
        throw Exception('Order not found or not in shipped status');
      }

      await _firestore.collection('orders').doc(orderId).update({
        'trackingNumber': trackingNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error adding tracking number: $e');
      return false;
    }
  }

  // Get orders by date range
  Future<List<SellerOrder>> getOrdersByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: currentUser.uid)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SellerOrder.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting orders by date range: $e');
      return [];
    }
  }
}