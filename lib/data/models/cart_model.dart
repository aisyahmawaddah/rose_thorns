import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koopon/data/models/item_model.dart';

class CartModel {
  final String? id;
  final String userId;
  final String itemId;
  final ItemModel item; // The actual item details
  final int quantity;
  final DateTime addedAt;

  CartModel({
    this.id,
    required this.userId,
    required this.itemId,
    required this.item,
    this.quantity = 1,
    required this.addedAt,
  });

  // Convert CartModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'itemId': itemId,
      'quantity': quantity,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  // Create CartModel from Firestore document
  factory CartModel.fromMap(Map<String, dynamic> map, String documentId, ItemModel item) {
    return CartModel(
      id: documentId,
      userId: map['userId'] ?? '',
      itemId: map['itemId'] ?? '',
      item: item,
      quantity: map['quantity'] ?? 1,
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create a copy with updated fields
  CartModel copyWith({
    String? id,
    String? userId,
    String? itemId,
    ItemModel? item,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  // Calculate total price for this cart item
  double get totalPrice => item.price * quantity;

  @override
  String toString() {
    return 'CartModel(id: $id, itemId: $itemId, quantity: $quantity, totalPrice: $totalPrice)';
  }
}