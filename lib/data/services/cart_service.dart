// lib/data/services/cart_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item_model.dart';
import '../models/cart_model.dart';
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
      sellerId: cartModel.item.sellerId,
      sellerName: cartModel.item.sellerName,
      additionalFields: {
        ...cartModel.item.additionalFields,
        'status': cartModel.item.status, // IMPORTANT: Include item status
        'category': cartModel.item.category,
      },
    );
  }

  // UPDATED: Get cart items including sold items (let UI handle sold status)
  Future<List<CartItem>> getCartItems() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      print('🛒 Loading cart items for user: $userId (including sold items)');

      // Get cart items
      final snapshot = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: userId)
          .get();

      List<CartItem> cartItems = [];
      List<String> deletedItemsToRemove = [];
      
      for (var cartDoc in snapshot.docs) {
        try {
          final cartData = cartDoc.data();
          final itemId = cartData['itemId'];
          
          // Fetch the actual item details
          final itemDoc = await _firestore.collection('items').doc(itemId).get();
          
          if (itemDoc.exists) {
            final itemData = itemDoc.data()!;
            final itemStatus = itemData['status'] ?? '';
            
            // KEEP ALL ITEMS (including sold ones) - let UI handle the display
            final item = ItemModel.fromMap(itemData, itemDoc.id);
            final cartModel = CartModel.fromMap(cartData, cartDoc.id, item);
            final cartItem = convertToCartItem(cartModel);
            cartItems.add(cartItem);
            
            if (itemStatus == 'sold') {
              print('📦 Including sold item in cart: ${itemData['name']} (status: $itemStatus)');
            }
            
          } else {
            // Only remove items that don't exist anymore (deleted items)
            print('🗑️ Found non-existent item in cart: $itemId');
            deletedItemsToRemove.add(cartDoc.id);
          }
        } catch (e) {
          print('Error processing cart item: $e');
        }
      }

      // Remove only deleted/non-existent items from cart (not sold items)
      if (deletedItemsToRemove.isNotEmpty) {
        await _removeSoldItemsFromCart(deletedItemsToRemove);
        print('✅ Removed ${deletedItemsToRemove.length} deleted items from cart');
      }

      final soldItemsCount = cartItems.where((item) => item.additionalFields['status'] == 'sold').length;
      print('✅ Loaded ${cartItems.length} total items in cart (${soldItemsCount} sold items will be shown with disabled checkout)');
      return cartItems;
    } catch (e) {
      print('Error getting cart items: $e');
      return [];
    }
  }

  // Helper method to remove cart document IDs (for deleted items only)
  Future<void> _removeSoldItemsFromCart(List<String> cartDocIds) async {
    try {
      final batch = _firestore.batch();
      
      for (String cartDocId in cartDocIds) {
        final cartDocRef = _firestore.collection('carts').doc(cartDocId);
        batch.delete(cartDocRef);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error removing deleted items from cart: $e');
    }
  }

  // ENHANCED: Clear cart after successful order
  Future<bool> clearCart() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      print('🧹 Clearing cart for user: $userId');

      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Cart cleared successfully');
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // NEW: Remove specific purchased items from current user's cart only
  Future<bool> removePurchasedItemsFromCart(List<String> purchasedItemIds) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      print('🛒 Removing purchased items from current user cart: $purchasedItemIds');
      
      final batch = _firestore.batch();
      int removedCount = 0;

      // For each purchased item, find and remove from CURRENT USER's cart only
      for (String itemId in purchasedItemIds) {
        final cartSnapshot = await _firestore
            .collection('carts')
            .where('userId', isEqualTo: userId)
            .where('itemId', isEqualTo: itemId)
            .get();

        for (var cartDoc in cartSnapshot.docs) {
          batch.delete(cartDoc.reference);
          removedCount++;
          print('   Removing purchased item $itemId from current user cart');
        }
      }

      if (removedCount > 0) {
        await batch.commit();
        print('✅ Removed $removedCount purchased items from current user cart');
      }

      return true;
    } catch (e) {
      print('Error removing purchased items from cart: $e');
      return false;
    }
  }

  // UPDATED: Remove sold items from ALL users' carts (when items get sold by others)
  Future<bool> removeSoldItemsFromAllCarts(List<String> soldItemIds) async {
    try {
      print('🧹 Removing sold items from all users carts: $soldItemIds');
      
      final batch = _firestore.batch();
      int removedCount = 0;

      // For each sold item, find and remove from ALL users' carts
      for (String itemId in soldItemIds) {
        final cartSnapshot = await _firestore
            .collection('carts')
            .where('itemId', isEqualTo: itemId)
            .get();

        for (var cartDoc in cartSnapshot.docs) {
          batch.delete(cartDoc.reference);
          removedCount++;
          print('   Removing sold item $itemId from cart ${cartDoc.id}');
        }
      }

      if (removedCount > 0) {
        await batch.commit();
        print('✅ Removed $removedCount cart entries for sold items from all users');
      }

      return true;
    } catch (e) {
      print('Error removing sold items from all carts: $e');
      return false;
    }
  }
}