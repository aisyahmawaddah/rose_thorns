// lib/data/model/cart_item_model.dart
class CartItem {
  final String id;
  final String itemId;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final String sellerId; // This is actually the seller's userId
  final String sellerName;
  final Map<String, dynamic> additionalFields; // Add this to preserve timeslots

  CartItem({
    required this.id,
    required this.itemId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.sellerId, // Keep the name for compatibility, but it's userId
    required this.sellerName,
    this.additionalFields = const {}, // Add this with default empty map
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'sellerId': sellerId, // This is the seller's userId
      'sellerName': sellerName,
      'additionalFields': additionalFields, // Include this in JSON
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      itemId: json['itemId'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price']?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
      sellerId: json['sellerId'], // This is the seller's userId
      sellerName: json['sellerName'],
      additionalFields: Map<String, dynamic>.from(json['additionalFields'] ?? {}), // Parse additionalFields
    );
  }
}