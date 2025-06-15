// lib/data/services/order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../models/time_slot_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'orders';

  /// Place a new order
  Future<bool> placeOrder(OrderRequest orderRequest) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('ERROR: No authenticated user in OrderService');
        return false;
      }

      // Generate a new document ID
      final docRef = _firestore.collection(_collection).doc();
      
      // Create order with the generated ID
      final orderWithId = OrderRequest(
        id: docRef.id,
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

      // Save to Firestore
      await docRef.set(orderWithId.toJson());
      
      print('Order placed successfully with ID: ${docRef.id}');
      return true;
      
    } catch (e) {
      print('Error placing order: $e');
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