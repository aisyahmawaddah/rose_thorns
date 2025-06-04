import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/models/item_model.dart';
import 'package:koopon/data/services/auth_service.dart';
import 'package:koopon/data/services/supabase_image_service.dart';
import 'package:koopon/core/config/supabase_config.dart';

class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  
  // Lazy initialization of image service
  SupabaseImageService? _imageService;
  SupabaseImageService get imageService {
    if (_imageService == null) {
      if (!SupabaseConfig.isInitialized) {
        throw Exception('Supabase not initialized. Call SupabaseConfig.initialize() in main.dart');
      }
      _imageService = SupabaseImageService();
    }
    return _imageService!;
  }

  // Collection reference
  CollectionReference get _itemsCollection => _firestore.collection('items');

  // Add new item (SAME METHOD SIGNATURE - no changes needed in UI)
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
      
      // Upload image to Supabase if provided (now optional)
      if (imageFile != null) {
        imageUrl = await _uploadImageToSupabase(imageFile, user.uid);
      } else {
        // No image provided - this is now acceptable
        imageUrl = null;
      }

      // Create item data (SAME AS BEFORE)
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

      // DEBUG: Print what we're saving to Firebase
      print('💾 Saving to Firebase with imageUrl: $imageUrl');
      print('📋 Item data: ${itemData.toMap()}');

      // Add to Firestore (SAME AS BEFORE)
      final docRef = await _itemsCollection.add(itemData.toMap());
      
      print('Item added successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding item: $e');
      throw Exception('Failed to add item: ${e.toString()}');
    }
  }

  // NEW: Upload image to Supabase (replaces Firebase Storage)
  Future<String> _uploadImageToSupabase(File imageFile, String userId) async {
    try {
      // Create a custom path with user ID for organization
      final fileName = 'user_${userId}/${DateTime.now().millisecondsSinceEpoch}_${userId}.jpg';
      
      final imageUrl = await imageService.uploadImage(imageFile, customPath: fileName);
      
      if (imageUrl == null) {
        throw Exception('Failed to get image URL from Supabase');
      }
      
      print('Image uploaded successfully to Supabase: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Error uploading image to Supabase: $e');
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  // Get all items (UNCHANGED)
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

  // Get items by category (UNCHANGED)
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

  // Get items by seller (UNCHANGED)
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

  // Update item (ENHANCED to handle image updates)
  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    try {
      await _itemsCollection.doc(itemId).update(updates);
      print('Item updated successfully');
    } catch (e) {
      print('Error updating item: $e');
      throw Exception('Failed to update item: ${e.toString()}');
    }
  }

  // NEW: Update item with optional new image
  Future<void> updateItemWithImage({
    required String itemId,
    required String name,
    required String category,
    required String status,
    required double price,
    File? newImageFile,
    Map<String, dynamic> additionalFields = const {},
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get current item data to check for existing image
      final doc = await _itemsCollection.doc(itemId).get();
      if (!doc.exists) {
        throw Exception('Item not found');
      }
      
      final currentData = doc.data() as Map<String, dynamic>;
      String? imageUrl = currentData['imageUrl'];

      // Handle image update
      if (newImageFile != null) {
        // Delete old image if exists
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await _deleteImageFromSupabase(imageUrl);
        }
        
        // Upload new image
        imageUrl = await _uploadImageToSupabase(newImageFile, user.uid);
      }

      // Prepare update data
      final updates = {
        'name': name,
        'category': category,
        'status': status,
        'price': price,
        'imageUrl': imageUrl,
        'updatedAt': Timestamp.now(),
        ...additionalFields,
      };

      await updateItem(itemId, updates);
    } catch (e) {
      print('Error updating item with image: $e');
      throw Exception('Failed to update item: ${e.toString()}');
    }
  }

  // Delete item (MODIFIED to use Supabase)
  Future<void> deleteItem(String itemId) async {
    try {
      // Get item data first to delete associated image
      final doc = await _itemsCollection.doc(itemId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final imageUrl = data['imageUrl'] as String?;
        
        // Delete image from Supabase if exists
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await _deleteImageFromSupabase(imageUrl);
        }
      }
      
      // Delete item document from Firestore (SAME AS BEFORE)
      await _itemsCollection.doc(itemId).delete();
      print('Item deleted successfully');
    } catch (e) {
      print('Error deleting item: $e');
      throw Exception('Failed to delete item: ${e.toString()}');
    }
  }

  // NEW: Delete image from Supabase (replaces Firebase Storage deletion)
  Future<void> _deleteImageFromSupabase(String imageUrl) async {
    try {
      final success = await imageService.deleteImage(imageUrl);
      if (success) {
        print('Image deleted from Supabase');
      } else {
        print('Failed to delete image from Supabase, but continuing...');
      }
    } catch (e) {
      print('Error deleting image from Supabase: $e');
      // Don't throw error here as item deletion should still proceed
    }
  }

  // Search items by name (UNCHANGED)
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

  // Get items stream for real-time updates (UNCHANGED)
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

  // OPTIONAL: Migration helper to move existing Firebase Storage images to Supabase
  Future<void> migrateImageToSupabase(String itemId) async {
    try {
      final doc = await _itemsCollection.doc(itemId).get();
      if (!doc.exists) return;
      
      final data = doc.data() as Map<String, dynamic>;
      final currentImageUrl = data['imageUrl'] as String?;
      
      if (currentImageUrl != null && currentImageUrl.contains('firebase')) {
        print('Migration not implemented - manual process required');
        // You would need to download from Firebase and upload to Supabase
        // This is optional and can be done gradually
      }
    } catch (e) {
      print('Error in migration: $e');
    }
  }
}