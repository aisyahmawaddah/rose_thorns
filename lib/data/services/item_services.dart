import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/models/item_model.dart';
import 'package:koopon/data/services/auth_service.dart';

class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  // Collection reference
  CollectionReference get _itemsCollection => _firestore.collection('items');

  // Add new item
  Future<String> addItem({
    required String name,
    required String category,
    required String status,
    required double price,
    File? imageFile,
    Map<String, dynamic> additionalFields = const {},
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Ensure user document exists and get proper seller name
      await _authService.ensureUserDocument(user);
      final sellerName = await _authService.getUserDisplayName(user.uid);

      String? imageUrl;
      
      // Upload image if provided (now optional)
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, user.uid);
      } else {
        // No image provided - this is now acceptable
        imageUrl = null;
      }

      // Create item data
      final itemData = ItemModel(
        name: name,
        category: category,
        status: status,
        price: price,
        imageUrl: imageUrl,
        sellerId: user.uid,
        sellerName: sellerName,
        createdAt: DateTime.now(),
        additionalFields: additionalFields,
      );

      // Add to Firestore
      final docRef = await _itemsCollection.add(itemData.toMap());
      
      print('Item added successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding item: $e');
      throw Exception('Failed to add item: ${e.toString()}');
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile, String userId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${userId}.jpg';
      final storageRef = _storage.ref().child('item_images/$fileName');
      
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  // Get all items
  Future<List<ItemModel>> getAllItems() async {
    try {
      final querySnapshot = await _itemsCollection
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ItemModel.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id))
          .toList();
    } catch (e) {
      print('Error getting items: $e');
      throw Exception('Failed to get items: ${e.toString()}');
    }
  }

  // Get items by category
  Future<List<ItemModel>> getItemsByCategory(String category) async {
    try {
      final querySnapshot = await _itemsCollection
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ItemModel.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id))
          .toList();
    } catch (e) {
      print('Error getting items by category: $e');
      throw Exception('Failed to get items by category: ${e.toString()}');
    }
  }

  // Get items by seller
  Future<List<ItemModel>> getItemsBySeller(String sellerId) async {
    try {
      final querySnapshot = await _itemsCollection
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ItemModel.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id))
          .toList();
    } catch (e) {
      print('Error getting items by seller: $e');
      throw Exception('Failed to get items by seller: ${e.toString()}');
    }
  }

  // Update item
  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    try {
      await _itemsCollection.doc(itemId).update(updates);
      print('Item updated successfully');
    } catch (e) {
      print('Error updating item: $e');
      throw Exception('Failed to update item: ${e.toString()}');
    }
  }

  // Delete item
  Future<void> deleteItem(String itemId) async {
    try {
      // Get item data first to delete associated image
      final doc = await _itemsCollection.doc(itemId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final imageUrl = data['imageUrl'] as String?;
        
        // Delete image from storage if exists
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await _deleteImageFromStorage(imageUrl);
        }
      }
      
      // Delete item document
      await _itemsCollection.doc(itemId).delete();
      print('Item deleted successfully');
    } catch (e) {
      print('Error deleting item: $e');
      throw Exception('Failed to delete item: ${e.toString()}');
    }
  }

  // Delete image from Firebase Storage
  Future<void> _deleteImageFromStorage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('Image deleted from storage');
    } catch (e) {
      print('Error deleting image from storage: $e');
      // Don't throw error here as item deletion should still proceed
    }
  }

  // Search items by name
  Future<List<ItemModel>> searchItems(String query) async {
    try {
      // Firestore doesn't support full-text search, so we'll use a simple approach
      // For better search, consider using Algolia or similar service
      final querySnapshot = await _itemsCollection.get();
      
      final allItems = querySnapshot.docs
          .map((doc) => ItemModel.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id))
          .toList();
      
      // Filter items that contain the query in name (case-insensitive)
      return allItems.where((item) => 
          item.name.toLowerCase().contains(query.toLowerCase())).toList();
    } catch (e) {
      print('Error searching items: $e');
      throw Exception('Failed to search items: ${e.toString()}');
    }
  }

  // Get items stream for real-time updates
  Stream<List<ItemModel>> getItemsStream() {
    return _itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemModel.fromMap(
                doc.data() as Map<String, dynamic>, 
                doc.id))
            .toList());
  }
}