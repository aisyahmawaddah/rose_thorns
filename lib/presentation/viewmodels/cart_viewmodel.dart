import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:koopon/data/models/item_model.dart';
import 'package:koopon/data/models/cart_model.dart';

class CartViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CartModel> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Constructor - don't do any Firebase operations here
  CartViewModel() {
    print('CartViewModel: Constructor called - no Firebase operations yet');
  }

  // Getters
  List<CartModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _cartItems.length;
  int get totalQuantity => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isInitialized => _isInitialized;

  // Get current user token (Firebase Auth UID) - with complete safety checks
  String? get _userToken {
    try {
      // Safety check 1: ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        print('CartViewModel: Firebase not initialized yet');
        return null;
      }
      
      // Safety check 2: ensure Firebase Auth is ready
      if (_auth.currentUser == null) {
        return null;
      }
      
      final userToken = _auth.currentUser?.uid;
      if (userToken != null) {
        print('CartViewModel: Current user token: ${userToken.substring(0, 8)}...');
      }
      return userToken;
    } catch (e) {
      print('CartViewModel: Error getting user token (this is normal during startup): $e');
      return null;
    }
  }

  // Check if user is authenticated (has valid token)
  bool get isUserAuthenticated {
    try {
      // Safety check: ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        return false;
      }
      return _userToken != null;
    } catch (e) {
      print('CartViewModel: Error checking authentication: $e');
      return false;
    }
  }

  // Get user token (public method for external use)
  String? get userToken => _userToken;

  // Initialize cart (only call this when user is authenticated)
  Future<void> initializeCart() async {
    try {
      // Safety check: ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        print('CartViewModel: Cannot initialize cart - Firebase not ready');
        _isInitialized = true;
        return;
      }

      if (!isUserAuthenticated) {
        print('CartViewModel: User not authenticated, skipping cart initialization');
        _isInitialized = true;
        return;
      }
      
      if (_isInitialized) return; // Prevent multiple initializations
      
      print('CartViewModel: Initializing cart for user token: $_userToken');
      _setLoading(true);
      
      await fetchCartItems();
      _setError(null);
      _isInitialized = true;
      print('CartViewModel: Cart initialized successfully with user token');
    } catch (e) {
      print('CartViewModel: Error during initialization: $e');
      _setError('Failed to load cart: $e');
      _isInitialized = true; // Mark as initialized even on error
    } finally {
      _setLoading(false);
    }
  }

  // Reset cart (call this when user logs out - clears token association)
  void resetCart() {
    print('CartViewModel: Resetting cart (user token cleared)');
    _cartItems.clear();
    _isLoading = false;
    _errorMessage = null;
    _isInitialized = false;
    notifyListeners();
  }

  // Fetch cart items from Firestore (filtered by user token)
  Future<void> fetchCartItems() async {
    try {
      // Safety checks
      if (Firebase.apps.isEmpty) {
        print('CartViewModel: Cannot fetch cart items - Firebase not ready');
        return;
      }

      if (!isUserAuthenticated) {
        print('CartViewModel: Cannot fetch cart items - no user token');
        return;
      }

      print('CartViewModel: Fetching cart items for user token: $_userToken');
      
      // Query cart items using user token (Firebase UID)
      final cartSnapshot = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: _userToken) // Using user token here
          .get();

      List<CartModel> cartItems = [];
      
      print('CartViewModel: Found ${cartSnapshot.docs.length} cart documents for user token: $_userToken');
      
      for (var cartDoc in cartSnapshot.docs) {
        try {
          final cartData = cartDoc.data();
          final itemId = cartData['itemId'];
          
          print('CartViewModel: Processing cart item with itemId: $itemId');
          
          // Fetch the actual item details
          final itemDoc = await _firestore.collection('items').doc(itemId).get();
          
          if (itemDoc.exists) {
            final item = ItemModel.fromMap(itemDoc.data()!, itemDoc.id);
            final cartItem = CartModel.fromMap(cartData, cartDoc.id, item);
            cartItems.add(cartItem);
            print('CartViewModel: Added cart item: ${item.name} for user token: $_userToken');
          } else {
            // Item no longer exists, remove from cart
            print('CartViewModel: Item $itemId no longer exists, removing from cart for user token: $_userToken');
            await cartDoc.reference.delete();
          }
        } catch (e) {
          print('CartViewModel: Error processing cart item: $e');
        }
      }

      _cartItems = cartItems;
      print('CartViewModel: Successfully fetched ${cartItems.length} cart items for user token: $_userToken');
      notifyListeners();
    } catch (e) {
      print('CartViewModel: Error fetching cart items for user token $_userToken: $e');
      _setError('Failed to load cart items');
    }
  }

  // Add item to cart (with user token)
  Future<bool> addToCart(ItemModel item) async {
    try {
      // Safety checks
      if (Firebase.apps.isEmpty) {
        _setError('Please wait, app is starting...');
        return false;
      }

      if (!isUserAuthenticated) {
        _setError('Please login to add items to cart');
        return false;
      }

      // Check if user is trying to add their own item
      if (item.sellerId == _userToken) {
        _setError('You cannot add your own items to cart');
        return false;
      }

      print('CartViewModel: Adding item ${item.name} to cart for user token: $_userToken');
      _setLoading(true);
      
      // Check if item already exists in cart for this user token
      final existingCartQuery = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: _userToken) // Filter by user token
          .where('itemId', isEqualTo: item.id)
          .get();

      if (existingCartQuery.docs.isNotEmpty) {
        // Item already in cart, update quantity
        final cartDoc = existingCartQuery.docs.first;
        final currentQuantity = cartDoc.data()['quantity'] ?? 1;
        
        await cartDoc.reference.update({
          'quantity': currentQuantity + 1,
        });
        
        print('CartViewModel: Updated quantity for existing item for user token: $_userToken');
      } else {
        // Add new item to cart with user token
        final cartItem = CartModel(
          userId: _userToken!, // User token stored here
          itemId: item.id!,
          item: item,
          quantity: 1,
          addedAt: DateTime.now(),
        );

        await _firestore.collection('carts').add(cartItem.toMap());
        print('CartViewModel: Added new item to cart for user token: $_userToken');
      }
      
      // Update local cart
      await fetchCartItems();
      _setError(null);
      return true;
    } catch (e) {
      print('CartViewModel: Error adding to cart for user token $_userToken: $e');
      _setError('Failed to add item to cart');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remove item from cart (with user token verification)
  Future<bool> removeFromCart(String cartItemId) async {
    try {
      // Safety checks
      if (Firebase.apps.isEmpty) {
        _setError('Please wait, app is starting...');
        return false;
      }

      if (!isUserAuthenticated) {
        _setError('Please login to manage cart');
        return false;
      }

      print('CartViewModel: Removing item from cart: $cartItemId for user token: $_userToken');
      _setLoading(true);
      
      // Verify ownership before deletion (security check)
      final cartDoc = await _firestore.collection('carts').doc(cartItemId).get();
      if (cartDoc.exists && cartDoc.data()?['userId'] == _userToken) {
        await _firestore.collection('carts').doc(cartItemId).delete();
        print('CartViewModel: Successfully removed cart item for user token: $_userToken');
      } else {
        print('CartViewModel: Unauthorized attempt to delete cart item');
        _setError('Unauthorized action');
        return false;
      }
      
      // Update local cart
      await fetchCartItems();
      _setError(null);
      return true;
    } catch (e) {
      print('CartViewModel: Error removing from cart for user token $_userToken: $e');
      _setError('Failed to remove item from cart');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update cart item quantity (with user token verification)
  Future<bool> updateQuantity(String cartItemId, int newQuantity) async {
    try {
      // Safety checks
      if (Firebase.apps.isEmpty) {
        _setError('Please wait, app is starting...');
        return false;
      }

      if (!isUserAuthenticated) {
        _setError('Please login to manage cart');
        return false;
      }

      if (newQuantity <= 0) {
        return await removeFromCart(cartItemId);
      }

      print('CartViewModel: Updating quantity for $cartItemId to $newQuantity for user token: $_userToken');
      
      // Verify ownership before update (security check)
      final cartDoc = await _firestore.collection('carts').doc(cartItemId).get();
      if (cartDoc.exists && cartDoc.data()?['userId'] == _userToken) {
        await _firestore.collection('carts').doc(cartItemId).update({
          'quantity': newQuantity,
        });
        print('CartViewModel: Successfully updated quantity for user token: $_userToken');
      } else {
        print('CartViewModel: Unauthorized attempt to update cart item');
        _setError('Unauthorized action');
        return false;
      }
      
      // Update local cart
      await fetchCartItems();
      _setError(null);
      return true;
    } catch (e) {
      print('CartViewModel: Error updating quantity for user token $_userToken: $e');
      _setError('Failed to update quantity');
      return false;
    }
  }

  // Clear entire cart (with user token verification)
  Future<bool> clearCart() async {
    try {
      // Safety checks
      if (Firebase.apps.isEmpty) {
        _setError('Please wait, app is starting...');
        return false;
      }

      if (!isUserAuthenticated) {
        _setError('Please login to manage cart');
        return false;
      }

      print('CartViewModel: Clearing entire cart for user token: $_userToken');
      _setLoading(true);
      
      // Only delete cart items belonging to current user token
      final cartSnapshot = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: _userToken) // Filter by user token
          .get();

      // Delete all cart items for this user token
      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      _cartItems.clear();
      notifyListeners();
      _setError(null);
      print('CartViewModel: Cart cleared successfully for user token: $_userToken');
      return true;
    } catch (e) {
      print('CartViewModel: Error clearing cart for user token $_userToken: $e');
      _setError('Failed to clear cart');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if item is already in cart (for current user token)
  bool isItemInCart(String itemId) {
    return _cartItems.any((cartItem) => cartItem.itemId == itemId);
  }

  // Get cart item by item ID (for current user token)
  CartModel? getCartItemByItemId(String itemId) {
    try {
      return _cartItems.firstWhere((cartItem) => cartItem.itemId == itemId);
    } catch (e) {
      return null;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Refresh cart (safe to call anytime with user token)
  Future<void> refreshCart() async {
    try {
      // Safety checks
      if (Firebase.apps.isEmpty) {
        print('CartViewModel: Cannot refresh cart - Firebase not ready');
        return;
      }

      if (!isUserAuthenticated) {
        print('CartViewModel: Cannot refresh cart - no user token');
        return;
      }
      
      print('CartViewModel: Refreshing cart for user token: $_userToken');
      await fetchCartItems();
    } catch (e) {
      print('CartViewModel: Error refreshing cart: $e');
      _setError('Failed to refresh cart');
    }
  }

  // Listen to auth state changes (handle user token changes)
  void listenToAuthChanges() {
    try {
      // Safety check: ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        print('CartViewModel: Cannot listen to auth changes - Firebase not ready');
        return;
      }

      _auth.authStateChanges().listen((User? user) {
        if (user == null) {
          // User logged out - clear token and reset cart
          print('CartViewModel: User logged out, resetting cart (token cleared)');
          resetCart();
        } else {
          // User logged in - new token available
          print('CartViewModel: User logged in with token: ${user.uid}');
          if (!_isInitialized) {
            initializeCart();
          }
        }
      });
    } catch (e) {
      print('CartViewModel: Error setting up auth listener: $e');
    }
  }

  // Get user info with token
  Map<String, dynamic> getUserInfo() {
    try {
      if (Firebase.apps.isEmpty) {
        return {
          'userToken': null,
          'email': null,
          'displayName': null,
          'isAuthenticated': false,
          'firebaseReady': false,
        };
      }

      final user = _auth.currentUser;
      return {
        'userToken': _userToken,
        'email': user?.email,
        'displayName': user?.displayName,
        'isAuthenticated': isUserAuthenticated,
        'firebaseReady': true,
      };
    } catch (e) {
      print('CartViewModel: Error getting user info: $e');
      return {
        'userToken': null,
        'email': null,
        'displayName': null,
        'isAuthenticated': false,
        'firebaseReady': false,
        'error': e.toString(),
      };
    }
  }
}