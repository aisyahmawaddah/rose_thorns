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
  final String? trackingNumber;
  final String? cancelReason;
  final DateTime? deliveredAt;
  final DateTime? shippedAt;
  final DateTime? completedAt;
  // NEW: Cancellation tracking fields
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? cancelledByRole;
  final String? cancelledByName;

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
    this.trackingNumber,
    this.cancelReason,
    this.deliveredAt,
    this.shippedAt,
    this.completedAt,
    // NEW: Cancellation tracking
    this.cancelledAt,
    this.cancelledBy,
    this.cancelledByRole,
    this.cancelledByName,
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
      'trackingNumber': trackingNumber,
      'cancelReason': cancelReason,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'shippedAt': shippedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      // NEW: Include cancellation fields in JSON
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancelledBy': cancelledBy,
      'cancelledByRole': cancelledByRole,
      'cancelledByName': cancelledByName,
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
          }
        }
      }
      
      // Parse deal method with fallback
      DealMethod dealMethod = DealMethod.inCampusMeetup;
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
      
      // Parse dates with error handling
      DateTime? selectedDate;
      if (json['selectedDate'] != null) {
        try {
          selectedDate = DateTime.parse(json['selectedDate']);
        } catch (e) {
          print('❌ Error parsing selected date: $e');
        }
      }
      
      DateTime? deliveredAt;
      if (json['deliveredAt'] != null) {
        try {
          deliveredAt = DateTime.parse(json['deliveredAt']);
        } catch (e) {
          print('❌ Error parsing delivered date: $e');
        }
      }
      
      DateTime? shippedAt;
      if (json['shippedAt'] != null) {
        try {
          shippedAt = DateTime.parse(json['shippedAt']);
        } catch (e) {
          print('❌ Error parsing shipped date: $e');
        }
      }
      
      DateTime? completedAt;
      if (json['completedAt'] != null) {
        try {
          completedAt = DateTime.parse(json['completedAt']);
        } catch (e) {
          print('❌ Error parsing completed date: $e');
        }
      }
      
      // NEW: Parse cancellation dates
      DateTime? cancelledAt;
      if (json['cancelledAt'] != null) {
        try {
          cancelledAt = DateTime.parse(json['cancelledAt']);
        } catch (e) {
          print('❌ Error parsing cancelled date: $e');
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
      OrderStatus status = OrderStatus.placed;
      try {
        status = OrderStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
        );
      } catch (e) {
        print('⚠️ Unknown order status: ${json['status']}, using default');
      }
      
      // Parse dates with error handling
      DateTime createdAt = DateTime.now();
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
        trackingNumber: json['trackingNumber'],
        cancelReason: json['cancelReason'],
        deliveredAt: deliveredAt,
        shippedAt: shippedAt,
        completedAt: completedAt,
        // NEW: Parse cancellation fields
        cancelledAt: cancelledAt,
        cancelledBy: json['cancelledBy'],
        cancelledByRole: json['cancelledByRole'],
        cancelledByName: json['cancelledByName'],
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

  // Create a copy with updated fields
  OrderRequest copyWith({
    String? id,
    String? userId,
    String? sellerId,
    List<CartItem>? items,
    DealMethod? dealMethod,
    Address? meetupLocation,
    DateTime? selectedDate,
    TimeSlot? selectedTimeSlot,
    double? subtotal,
    double? deliveryFee,
    double? total,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? trackingNumber,
    String? cancelReason,
    DateTime? deliveredAt,
    DateTime? shippedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancelledBy,
    String? cancelledByRole,
    String? cancelledByName,
  }) {
    return OrderRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sellerId: sellerId ?? this.sellerId,
      items: items ?? this.items,
      dealMethod: dealMethod ?? this.dealMethod,
      meetupLocation: meetupLocation ?? this.meetupLocation,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      cancelReason: cancelReason ?? this.cancelReason,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      shippedAt: shippedAt ?? this.shippedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledByRole: cancelledByRole ?? this.cancelledByRole,
      cancelledByName: cancelledByName ?? this.cancelledByName,
    );
  }

  // Helper method to get cancellation display text
  String get cancellationDisplayText {
    if (status != OrderStatus.cancelled) return '';
    
    String text = 'Order Cancelled';
    
    if (cancelledByRole != null) {
      text += ' by ${cancelledByRole}';
    }
    
    if (cancelReason != null && cancelReason!.isNotEmpty) {
      text += ' - $cancelReason';
    }
    
    return text;
  }

  // Helper method to check if cancelled by seller
  bool get isCancelledBySeller {
    return status == OrderStatus.cancelled && 
           cancelledByRole == 'seller';
  }

  // Helper method to check if cancelled by buyer
  bool get isCancelledByBuyer {
    return status == OrderStatus.cancelled && 
           cancelledByRole == 'buyer';
  }
}

enum DealMethod {
  inCampusMeetup,
  delivery,
}

// UPDATED: Extended order status enum with all the statuses you requested
enum OrderStatus {
  placed,          // When buyer places order
  pendingPayment,  // Waiting for payment (if payment integration)
  confirmed,       // Seller confirms order
  shipped,         // Order has been shipped (for delivery)
  delivered,       // Order delivered (for delivery)
  completed,       // Transaction completed
  cancelled,       // Order cancelled
}