// lib/data/services/order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../models/time_slot_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'orders';

  /// ENHANCED: Place order and mark items as sold
  Future<bool> placeOrder(OrderRequest orderRequest) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('ERROR: No authenticated user in OrderService');
        return false;
      }

      // Start a batch write to ensure atomicity
      final batch = _firestore.batch();

      // Generate a new document ID for the order
      final orderDocRef = _firestore.collection(_collection).doc();
      
      // Create order with the generated ID and initial status
      final orderWithId = orderRequest.copyWith(
        id: orderDocRef.id,
        status: OrderStatus.placed, // Always start with 'placed' status
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add order to batch
      batch.set(orderDocRef, orderWithId.toJson());
      print('📋 Order added to batch: ${orderDocRef.id} with status: placed');

      // CRITICAL: Update each item's status to "sold"
      for (final cartItem in orderRequest.items) {
        final itemDocRef = _firestore.collection('items').doc(cartItem.itemId);
        batch.update(itemDocRef, {
          'status': 'sold',
          'soldAt': Timestamp.now(),
          'soldTo': orderRequest.userId,
          'orderId': orderDocRef.id,
        });
        print('🏷️ Item ${cartItem.itemId} marked as sold in batch');
      }

      // Commit all changes atomically
      await batch.commit();
      print('✅ Order placed successfully with status "placed": ${orderDocRef.id}');
      
      return true;
      
    } catch (e) {
      print('❌ Error in OrderService.placeOrder: $e');
      return false;
    }
  }

  /// Create order request (alias for placeOrder)
  Future<bool> createOrderRequest(OrderRequest orderRequest) async {
    return await placeOrder(orderRequest);
  }

  /// Get available time slots for an item (placeholder method)
  Future<List<TimeSlot>> getAvailableTimeSlots(String itemId) async {
    try {
      return [];
    } catch (e) {
      print('Error fetching available timeslots: $e');
      return [];
    }
  }

  /// Get orders for a specific user (buyer perspective)
  Future<List<OrderRequest>> getOrdersForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      List<OrderRequest> orders = [];
      print('📊 Processing ${snapshot.docs.length} buyer order documents');
      
      for (var doc in snapshot.docs) {
        try {
          final order = OrderRequest.fromJson(doc.data());
          orders.add(order);
        } catch (e) {
          print('❌ Skipping malformed order ${doc.id}: $e');
        }
      }
      
      print('✅ Successfully processed ${orders.length} buyer orders');
      return orders;
    } catch (e) {
      print('❌ Error fetching user orders: $e');
      return [];
    }
  }

  /// Get order history (alias for getOrdersForUser)
  Future<List<OrderRequest>> getOrderHistory(String userId) async {
    return await getOrdersForUser(userId);
  }

  /// Get orders for a specific seller (seller perspective)
  Future<List<OrderRequest>> getOrdersForSeller(String sellerId) async {
    try {
      print('🔍 OrderService: Fetching orders for seller: $sellerId');
      
      final snapshot = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      List<OrderRequest> orders = [];
      print('📊 Processing ${snapshot.docs.length} seller order documents');
      
      for (var doc in snapshot.docs) {
        try {
          final order = OrderRequest.fromJson(doc.data());
          orders.add(order);
          print('✅ Processed order ${order.id} with status: ${order.status}');
        } catch (e) {
          print('❌ Skipping malformed order ${doc.id}: $e');
        }
      }
      
      print('✅ Successfully processed ${orders.length} seller orders');
      return orders;
    } catch (e) {
      print('❌ Error fetching seller orders: $e');
      return [];
    }
  }

  /// ENHANCED: Update order status with proper validation and timestamps
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus, {
    String? trackingNumber,
    String? cancelReason,
  }) async {
    try {
      print('📝 OrderService: Updating order $orderId to status: $newStatus');
      
      // Get current order to validate transition
      final orderDoc = await _firestore.collection(_collection).doc(orderId).get();
      if (!orderDoc.exists) {
        print('❌ Order not found: $orderId');
        return false;
      }
      
      final currentOrder = OrderRequest.fromJson(orderDoc.data()!);
      
      // Validate status transition
      if (!_isValidStatusTransition(currentOrder.status, newStatus)) {
        print('❌ Invalid status transition from ${currentOrder.status} to $newStatus');
        return false;
      }
      
      // Prepare update data
      Map<String, dynamic> updateData = {
        'status': newStatus.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      // Add specific timestamps based on status
      switch (newStatus) {
        case OrderStatus.shipped:
          updateData['shippedAt'] = DateTime.now().toIso8601String();
          if (trackingNumber != null) {
            updateData['trackingNumber'] = trackingNumber;
          }
          break;
        case OrderStatus.delivered:
          updateData['deliveredAt'] = DateTime.now().toIso8601String();
          break;
        case OrderStatus.cancelled:
          if (cancelReason != null) {
            updateData['cancelReason'] = cancelReason;
          }
          // IMPORTANT: If cancelled, mark items as available again
          await _markItemsAsAvailable(currentOrder.items);
          break;
        case OrderStatus.completed:
          if (updateData['deliveredAt'] == null) {
            updateData['deliveredAt'] = DateTime.now().toIso8601String();
          }
          break;
        default:
          break;
      }
      
      await _firestore.collection(_collection).doc(orderId).update(updateData);
      
      print('✅ Order $orderId status updated to: $newStatus');
      return true;
      
    } catch (e) {
      print('❌ Error updating order status: $e');
      return false;
    }
  }

  /// Helper method to validate status transitions
  bool _isValidStatusTransition(OrderStatus currentStatus, OrderStatus newStatus) {
    // Define valid transitions
    const validTransitions = {
      OrderStatus.placed: [
        OrderStatus.confirmed,
        OrderStatus.cancelled,
        OrderStatus.pendingPayment,
      ],
      OrderStatus.pendingPayment: [
        OrderStatus.confirmed,
        OrderStatus.cancelled,
      ],
      OrderStatus.confirmed: [
        OrderStatus.shipped,
        OrderStatus.completed, // For meetup orders
        OrderStatus.cancelled,
      ],
      OrderStatus.shipped: [
        OrderStatus.delivered,
        OrderStatus.cancelled,
      ],
      OrderStatus.delivered: [
        OrderStatus.completed,
      ],
      OrderStatus.completed: [], // Final state
      OrderStatus.cancelled: [], // Final state
    };
    
    return validTransitions[currentStatus]?.contains(newStatus) ?? false;
  }

  /// Helper method to mark items as available again (when order is cancelled)
  Future<void> _markItemsAsAvailable(List<dynamic> items) async {
    try {
      final batch = _firestore.batch();
      
      for (final item in items) {
        String itemId;
        if (item is Map<String, dynamic>) {
          itemId = item['itemId'] ?? '';
        } else {
          itemId = item.itemId ?? '';
        }
        
        if (itemId.isNotEmpty) {
          final itemDocRef = _firestore.collection('items').doc(itemId);
          batch.update(itemDocRef, {
            'status': 'available',
            'soldAt': FieldValue.delete(),
            'soldTo': FieldValue.delete(),
            'orderId': FieldValue.delete(),
          });
        }
      }
      
      await batch.commit();
      print('✅ Items marked as available again');
    } catch (e) {
      print('❌ Error marking items as available: $e');
    }
  }

  /// Quick status update methods for common transitions
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

  /// Get a specific order by ID
  Future<OrderRequest?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      
      if (doc.exists && doc.data() != null) {
        return OrderRequest.fromJson(doc.data()!);
      }
      
      return null;
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  /// Get order statistics for a seller
  Future<Map<String, dynamic>> getSellerOrderStats(String sellerId) async {
    try {
      final orders = await getOrdersForSeller(sellerId);
      
      int totalOrders = orders.length;
      int completedOrders = orders.where((o) => o.status == OrderStatus.completed).length;
      int pendingOrders = orders.where((o) => [
        OrderStatus.placed, 
        OrderStatus.confirmed, 
        OrderStatus.shipped
      ].contains(o.status)).length;
      int cancelledOrders = orders.where((o) => o.status == OrderStatus.cancelled).length;
      
      double totalRevenue = orders
          .where((o) => o.status == OrderStatus.completed)
          .fold(0.0, (sum, order) => sum + order.total);
      
      int totalItemsSold = orders
          .where((o) => o.status == OrderStatus.completed)
          .fold(0, (sum, order) => sum + order.items.length);
      
      return {
        'totalOrders': totalOrders,
        'completedOrders': completedOrders,
        'pendingOrders': pendingOrders,
        'cancelledOrders': cancelledOrders,
        'totalRevenue': totalRevenue,
        'totalItemsSold': totalItemsSold,
      };
    } catch (e) {
      print('Error getting seller stats: $e');
      return {
        'totalOrders': 0,
        'completedOrders': 0,
        'pendingOrders': 0,
        'cancelledOrders': 0,
        'totalRevenue': 0.0,
        'totalItemsSold': 0,
      };
    }
  }

  /// Stream orders for real-time updates
  Stream<List<OrderRequest>> getSellerOrdersStream(String sellerId) {
    return _firestore
        .collection(_collection)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderRequest.fromJson(doc.data()))
          .toList();
    });
  }

  /// Stream orders for buyer (purchase history)
  Stream<List<OrderRequest>> getBuyerOrdersStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderRequest.fromJson(doc.data()))
          .toList();
    });
  }
}