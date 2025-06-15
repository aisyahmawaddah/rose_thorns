// lib/data/model/order_model.dart
import 'package:koopon/data/models/cart_item_model.dart';
import 'package:koopon/data/models/address_model.dart';
import 'package:koopon/data/models/time_slot_model.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

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
    return OrderRequest(
      id: json['id'],
      userId: json['userId'],
      sellerId: json['sellerId'],
      items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
      dealMethod: DealMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['dealMethod'],
      ),
      meetupLocation: json['meetupLocation'] != null 
          ? Address.fromJson(json['meetupLocation']) 
          : null,
      selectedDate: json['selectedDate'] != null 
          ? DateTime.parse(json['selectedDate']) 
          : null,
      selectedTimeSlot: json['selectedTimeSlot'] != null 
          ? TimeSlot.fromJson(json['selectedTimeSlot']) 
          : null,
      subtotal: json['subtotal']?.toDouble() ?? 0.0,
      deliveryFee: json['deliveryFee']?.toDouble() ?? 0.0,
      total: json['total']?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
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