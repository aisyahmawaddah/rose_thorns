// lib/data/models/seller_order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum SellerOrderStatus {
  placed,
  pending,
  confirmed,
  shipped,
  delivered,
  completed,
  cancelled
}

class SellerOrderItem {
  final String itemId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String category;

  const SellerOrderItem({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    required this.category,
  });

  factory SellerOrderItem.fromMap(Map<String, dynamic> map) {
    return SellerOrderItem(
      itemId: map['itemId'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown Item',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 1,
      imageUrl: map['imageUrl'] as String?,
      category: map['category'] as String? ?? 'Other',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  SellerOrderItem copyWith({
    String? itemId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    String? category,
  }) {
    return SellerOrderItem(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }

  double get total => price * quantity;
}

class SellerOrder {
  final String id;
  final String userId; // Buyer ID
  final String sellerId;
  final String buyerName;
  final String? buyerEmail;
  final List<SellerOrderItem> items;
  final String dealMethod; // 'delivery' or 'meetup'
  final Map<String, dynamic>? deliveryAddress;
  final Map<String, dynamic>? meetupLocation;
  final DateTime? selectedDate;
  final Map<String, dynamic>? selectedTimeSlot;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final SellerOrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? trackingNumber;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;

  const SellerOrder({
    required this.id,
    required this.userId,
    required this.sellerId,
    required this.buyerName,
    this.buyerEmail,
    required this.items,
    required this.dealMethod,
    this.deliveryAddress,
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
    this.cancelledAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.completedAt,
  });

  factory SellerOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return SellerOrder(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      sellerId: data['sellerId'] as String? ?? '',
      buyerName: data['buyerName'] as String? ?? 'Unknown Buyer',
      buyerEmail: data['buyerEmail'] as String?,
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => SellerOrderItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      dealMethod: data['dealMethod'] as String? ?? 'delivery',
      deliveryAddress: data['deliveryAddress'] as Map<String, dynamic>?,
      meetupLocation: data['meetupLocation'] as Map<String, dynamic>?,
      selectedDate: (data['selectedDate'] as Timestamp?)?.toDate(),
      selectedTimeSlot: data['selectedTimeSlot'] as Map<String, dynamic>?,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: _parseStatus(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      trackingNumber: data['trackingNumber'] as String?,
      cancelReason: data['cancelReason'] as String?,
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      confirmedAt: (data['confirmedAt'] as Timestamp?)?.toDate(),
      shippedAt: (data['shippedAt'] as Timestamp?)?.toDate(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'sellerId': sellerId,
      'buyerName': buyerName,
      'buyerEmail': buyerEmail,
      'items': items.map((item) => item.toMap()).toList(),
      'dealMethod': dealMethod,
      'deliveryAddress': deliveryAddress,
      'meetupLocation': meetupLocation,
      'selectedDate': selectedDate != null ? Timestamp.fromDate(selectedDate!) : null,
      'selectedTimeSlot': selectedTimeSlot,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'trackingNumber': trackingNumber,
      'cancelReason': cancelReason,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'shippedAt': shippedAt != null ? Timestamp.fromDate(shippedAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  static SellerOrderStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'placed':
        return SellerOrderStatus.placed;
      case 'pending':
        return SellerOrderStatus.pending;
      case 'confirmed':
        return SellerOrderStatus.confirmed;
      case 'shipped':
        return SellerOrderStatus.shipped;
      case 'delivered':
        return SellerOrderStatus.delivered;
      case 'completed':
        return SellerOrderStatus.completed;
      case 'cancelled':
        return SellerOrderStatus.cancelled;
      default:
        return SellerOrderStatus.pending;
    }
  }

  SellerOrder copyWith({
    String? id,
    String? userId,
    String? sellerId,
    String? buyerName,
    String? buyerEmail,
    List<SellerOrderItem>? items,
    String? dealMethod,
    Map<String, dynamic>? deliveryAddress,
    Map<String, dynamic>? meetupLocation,
    DateTime? selectedDate,
    Map<String, dynamic>? selectedTimeSlot,
    double? subtotal,
    double? deliveryFee,
    double? total,
    SellerOrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? trackingNumber,
    String? cancelReason,
    DateTime? cancelledAt,
    DateTime? confirmedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? completedAt,
  }) {
    return SellerOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sellerId: sellerId ?? this.sellerId,
      buyerName: buyerName ?? this.buyerName,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      items: items ?? this.items,
      dealMethod: dealMethod ?? this.dealMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
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
      cancelledAt: cancelledAt ?? this.cancelledAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Helper methods
  bool get isNewOrder => status == SellerOrderStatus.placed || status == SellerOrderStatus.pending;
  bool get isToShip => status == SellerOrderStatus.confirmed;
  bool get isShipped => status == SellerOrderStatus.shipped;
  bool get isCompleted => status == SellerOrderStatus.delivered || status == SellerOrderStatus.completed;
  bool get isCancelled => status == SellerOrderStatus.cancelled;
  bool get canUpdateStatus => [SellerOrderStatus.placed, SellerOrderStatus.pending, SellerOrderStatus.confirmed, SellerOrderStatus.shipped].contains(status);

  String get statusDisplayText {
    switch (status) {
      case SellerOrderStatus.placed:
        return 'New Order';
      case SellerOrderStatus.pending:
        return 'Pending';
      case SellerOrderStatus.confirmed:
        return 'To Ship';
      case SellerOrderStatus.shipped:
        return 'Shipped';
      case SellerOrderStatus.delivered:
        return 'Delivered';
      case SellerOrderStatus.completed:
        return 'Completed';
      case SellerOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  SellerOrderStatus? get nextStatus {
    switch (status) {
      case SellerOrderStatus.placed:
      case SellerOrderStatus.pending:
        return SellerOrderStatus.confirmed;
      case SellerOrderStatus.confirmed:
        return SellerOrderStatus.shipped;
      case SellerOrderStatus.shipped:
        return SellerOrderStatus.delivered;
      default:
        return null;
    }
  }

  String get nextActionText {
    switch (status) {
      case SellerOrderStatus.placed:
      case SellerOrderStatus.pending:
        return 'Confirm Order';
      case SellerOrderStatus.confirmed:
        return 'Mark as Shipped';
      case SellerOrderStatus.shipped:
        return 'Mark as Delivered';
      default:
        return 'Update Status';
    }
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  String get itemsSummary {
    if (items.isEmpty) return 'No items';
    if (items.length == 1) return '${items.first.name} (${items.first.quantity})';
    return '${items.first.name} + ${items.length - 1} more';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SellerOrder &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SellerOrder{id: $id, status: $status, total: $total, buyerName: $buyerName}';
  }
}