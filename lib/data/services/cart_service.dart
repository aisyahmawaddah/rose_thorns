// lib/data/services/cart_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item_model.dart';
import '../models/cart_model.dart'; // Use your existing CartModel
import '../models/item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Convert your existing CartModel to new CartItem for order processing
  static CartItem convertToCartItem(CartModel cartModel) {
    return CartItem(
      id: cartModel.id ?? '',
      itemId: cartModel.itemId,
      name: cartModel.item.name,
      imageUrl: cartModel.item.imageUrl ?? '',
      price: cartModel.item.price,
      quantity: cartModel.quantity,
      sellerId: cartModel.item.sellerId, // This should be the seller's userId
      sellerName: cartModel.item.sellerName,
      additionalFields: cartModel.item.additionalFields, // FIXED: Pass the additionalFields which contains timeslots
    );
  }

  // Get cart items using your existing structure
  Future<List<CartItem>> getCartItems() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      // Use your existing 'carts' collection
      final snapshot = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: userId)
          .get();

      List<CartItem> cartItems = [];
      
      for (var cartDoc in snapshot.docs) {
        try {
          final cartData = cartDoc.data();
          final itemId = cartData['itemId'];
          
          // Fetch the actual item details
          final itemDoc = await _firestore.collection('items').doc(itemId).get();
          
          if (itemDoc.exists) {
            // Create CartModel using your existing structure
            final item = ItemModel.fromMap(itemDoc.data()!, itemDoc.id);
            final cartModel = CartModel.fromMap(cartData, cartDoc.id, item);
            
            // Convert to CartItem for order processing
            final cartItem = convertToCartItem(cartModel);
            cartItems.add(cartItem);
            
            // Debug: Print the additionalFields to verify timeslots are included
            print('CartItem ${cartItem.id} additionalFields: ${cartItem.additionalFields}');
            if (cartItem.additionalFields.containsKey('meetup_timeslots')) {
              print('Found meetup_timeslots: ${cartItem.additionalFields['meetup_timeslots']}');
            }
          }
        } catch (e) {
          print('Error processing cart item: $e');
        }
      }

      return cartItems;
    } catch (e) {
      print('Error getting cart items: $e');
      return [];
    }
  }

  // Clear cart after successful order using your existing structure
  Future<bool> clearCart() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('carts') // Use your existing collection name
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }
}