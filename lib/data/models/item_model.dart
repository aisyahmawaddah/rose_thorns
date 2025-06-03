import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String? id;
  final String name;
  final String category;
  final String status;
  final double price;
  final String? imageUrl;
  final String sellerId;
  final String sellerName;
  final DateTime createdAt;
  final Map<String, dynamic> additionalFields;

  ItemModel({
    this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.price,
    this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
    this.additionalFields = const {},
  });

  // Convert ItemModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'status': status,
      'price': price,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'createdAt': Timestamp.fromDate(createdAt),
      ...additionalFields,
    };
  }

  // Create ItemModel from Firestore document
  factory ItemModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Extract known fields
    final knownFields = {
      'name', 'category', 'status', 'price', 'imageUrl', 
      'sellerId', 'sellerName', 'createdAt'
    };
    
    // Get additional fields (dynamic fields based on category)
    final additionalFields = <String, dynamic>{};
    map.forEach((key, value) {
      if (!knownFields.contains(key)) {
        additionalFields[key] = value;
      }
    });

    return ItemModel(
      id: documentId,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'],
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalFields: additionalFields,
    );
  }

  // Create a copy with updated fields
  ItemModel copyWith({
    String? id,
    String? name,
    String? category,
    String? status,
    double? price,
    String? imageUrl,
    String? sellerId,
    String? sellerName,
    DateTime? createdAt,
    Map<String, dynamic>? additionalFields,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      createdAt: createdAt ?? this.createdAt,
      additionalFields: additionalFields ?? this.additionalFields,
    );
  }

  @override
  String toString() {
    return 'ItemModel(id: $id, name: $name, category: $category, price: $price, sellerId: $sellerId)';
  }
}