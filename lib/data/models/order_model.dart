// lib/data/models/order_model.dart
import 'package:koopon/data/models/cart_item_model.dart';
import 'package:koopon/data/models/address_model.dart';
import 'package:koopon/data/models/time_slot_model.dart';

class OrderRequest {
  final String id;
  final String userId;
  final String sellerId;
  final List<CartItem> items;
  final DealMethod dealMethod;
  final Address? meetupLocation;
  final DateTime? selectedDate;
  final TimeSlot? selectedTimeSlot;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderRequest({
    required this.id,
    required this.userId,
    required this.sellerId,
    required this.items,
    required this.dealMethod,
    this.meetupLocation,
    this.selectedDate,
    this.selectedTimeSlot,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sellerId': sellerId,
      'items': items.map((item) => item.toJson()).toList(),
      'dealMethod': dealMethod.toString().split('.').last,
      'meetupLocation': meetupLocation?.toJson(),
      'selectedDate': selectedDate?.toIso8601String(),
      'selectedTimeSlot': selectedTimeSlot?.toJson(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory OrderRequest.fromJson(Map<String, dynamic> json) {
    try {
      print('🔄 Parsing OrderRequest: ${json['id']}');
      
      // Parse items with error handling
      List<CartItem> items = [];
      if (json['items'] != null && json['items'] is List) {
        for (var itemJson in json['items']) {
          try {
            items.add(CartItem.fromJson(itemJson));
          } catch (e) {
            print('❌ Error parsing cart item: $e');
            // Skip malformed items instead of crashing
          }
        }
      }
      
      // Parse deal method with fallback
      DealMethod dealMethod = DealMethod.inCampusMeetup; // Default fallback
      try {
        dealMethod = DealMethod.values.firstWhere(
          (e) => e.toString().split('.').last == json['dealMethod'],
        );
      } catch (e) {
        print('⚠️ Unknown deal method: ${json['dealMethod']}, using default');
      }
      
      // Parse meetup location with error handling
      Address? meetupLocation;
      if (json['meetupLocation'] != null) {
        try {
          meetupLocation = Address.fromJson(json['meetupLocation']);
        } catch (e) {
          print('❌ Error parsing meetup location: $e');
        }
      }
      
      // Parse selected date with error handling
      DateTime? selectedDate;
      if (json['selectedDate'] != null) {
        try {
          selectedDate = DateTime.parse(json['selectedDate']);
        } catch (e) {
          print('❌ Error parsing selected date: $e');
        }
      }
      
      // Parse time slot with error handling
      TimeSlot? selectedTimeSlot;
      if (json['selectedTimeSlot'] != null) {
        try {
          selectedTimeSlot = TimeSlot.fromJson(json['selectedTimeSlot']);
        } catch (e) {
          print('❌ Error parsing time slot: $e');
        }
      }
      
      // Parse order status with fallback
      OrderStatus status = OrderStatus.placed; // Default fallback
      try {
        status = OrderStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
        );
      } catch (e) {
        print('⚠️ Unknown order status: ${json['status']}, using default');
      }
      
      // Parse dates with error handling
      DateTime createdAt = DateTime.now(); // Fallback
      try {
        createdAt = DateTime.parse(json['createdAt']);
      } catch (e) {
        print('❌ Error parsing created date: $e');
      }
      
      DateTime? updatedAt;
      if (json['updatedAt'] != null) {
        try {
          updatedAt = DateTime.parse(json['updatedAt']);
        } catch (e) {
          print('❌ Error parsing updated date: $e');
        }
      }
      
      // Parse numeric values with safe conversion
      double subtotal = 0.0;
      try {
        subtotal = (json['subtotal'] ?? 0).toDouble();
      } catch (e) {
        print('❌ Error parsing subtotal: $e');
      }
      
      double deliveryFee = 0.0;
      try {
        deliveryFee = (json['deliveryFee'] ?? 0).toDouble();
      } catch (e) {
        print('❌ Error parsing delivery fee: $e');
      }
      
      double total = 0.0;
      try {
        total = (json['total'] ?? 0).toDouble();
      } catch (e) {
        print('❌ Error parsing total: $e');
      }
      
      final order = OrderRequest(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        sellerId: json['sellerId'] ?? '',
        items: items,
        dealMethod: dealMethod,
        meetupLocation: meetupLocation,
        selectedDate: selectedDate,
        selectedTimeSlot: selectedTimeSlot,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        status: status,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      
      print('✅ Successfully parsed OrderRequest: ${order.id}');
      return order;
      
    } catch (e, stackTrace) {
      print('❌ Critical error parsing OrderRequest: $e');
      print('📚 Stack trace: $stackTrace');
      print('📄 JSON data: $json');
      
      // Return a minimal valid order to prevent app crash
      return OrderRequest(
        id: json['id'] ?? 'error',
        userId: json['userId'] ?? '',
        sellerId: json['sellerId'] ?? '',
        items: [],
        dealMethod: DealMethod.inCampusMeetup,
        subtotal: 0.0,
        deliveryFee: 0.0,
        total: 0.0,
        status: OrderStatus.cancelled,
        createdAt: DateTime.now(),
      );
    }
  }
}

enum DealMethod {
  inCampusMeetup,
  delivery,
}

enum OrderStatus {
  placed,
  confirmed,
  completed,
  cancelled,
}