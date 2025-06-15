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
      
      // Create order with the generated ID
      final orderWithId = OrderRequest(
        id: orderDocRef.id,
        userId: orderRequest.userId,
        sellerId: orderRequest.sellerId,
        items: orderRequest.items,
        dealMethod: orderRequest.dealMethod,
        meetupLocation: orderRequest.meetupLocation,
        selectedDate: orderRequest.selectedDate,
        selectedTimeSlot: orderRequest.selectedTimeSlot,
        subtotal: orderRequest.subtotal,
        deliveryFee: orderRequest.deliveryFee,
        total: orderRequest.total,
        status: orderRequest.status,
        createdAt: orderRequest.createdAt,
        updatedAt: DateTime.now(),
      );

      // Add order to batch
      batch.set(orderDocRef, orderWithId.toJson());
      print('📋 Order added to batch: ${orderDocRef.id}');

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
      print('✅ Order placed and items marked as sold successfully: ${orderDocRef.id}');
      
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

  /// Get orders for a specific user
  Future<List<OrderRequest>> getOrdersForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderRequest.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching user orders: $e');
      return [];
    }
  }

  /// Get order history (alias for getOrdersForUser)
  Future<List<OrderRequest>> getOrderHistory(String userId) async {
    return await getOrdersForUser(userId);
  }

  /// Get orders for a specific seller
  Future<List<OrderRequest>> getOrdersForSeller(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderRequest.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching seller orders: $e');
      return [];
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
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

  /// Cancel an order
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': OrderStatus.cancelled.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }
}