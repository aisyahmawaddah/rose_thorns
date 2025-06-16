// lib/data/repositories/order_repository.dart
import '../services/order_service.dart';
import '../services/address_service.dart';
import '../models/order_model.dart';
import '../models/address_model.dart';
import '../models/time_slot_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderRepository {
  final OrderService _orderService = OrderService();
  final AddressService _addressService = AddressService();
  // REMOVED: final PaymentService _paymentService = PaymentService(); - No longer needed

  // Order related methods
  Future<List<TimeSlot>> getAvailableTimeSlots(String sellerId) {
    return _orderService.getAvailableTimeSlots(sellerId);
  }

  Future<String?> createOrder(OrderRequest order) async {
    try {
      // Since OrderService.createOrderRequest returns Future<bool>,
      // we need to handle it and return the order ID if successful
      final success = await _orderService.createOrderRequest(order);
      if (success) {
        return order.id; // Return the order ID if successful
      }
      return null; // Return null if failed
    } catch (e) {
      print('Error creating order in repository: $e');
      return null;
    }
  }

  Future<List<OrderRequest>> getOrderHistory() async {
    try {
      // Get current user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('No authenticated user found');
        return [];
      }
      
      return await _orderService.getOrderHistory(currentUser.uid);
    } catch (e) {
      print('Error getting order history: $e');
      return [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus status) {
    return _orderService.updateOrderStatus(orderId, status);
  }

  // Address related methods
  Future<List<Address>> getUserAddresses() {
    return _addressService.getUserAddresses();
  }

  Future<String?> addAddress(Address address) {
    return _addressService.addAddress(address);
  }

  Future<bool> updateAddress(String addressId, Address address) {
    return _addressService.updateAddress(addressId, address);
  }

  Future<bool> deleteAddress(String addressId) {
    return _addressService.deleteAddress(addressId);
  }

  Future<bool> setDefaultAddress(String addressId) {
    return _addressService.setDefaultAddress(addressId);
  }


}