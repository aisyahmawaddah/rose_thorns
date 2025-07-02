// lib/data/services/item_service.dart
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

  // ENHANCED: Filter out sold items helper
  List<ItemModel> _filterAvailableItems(List<ItemModel> items) {
    return items.where((item) => 
      item.status != 'sold' && 
      item.status != 'unavailable'
    ).toList();
  }

  // Add new item (ENHANCED: Set status as available by default)
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

      // ENHANCED: Ensure new items are marked as available
      final finalStatus = status.isEmpty ? 'available' : status;

      // Create item data
      final itemData = ItemModel(
        name: name,
        category: category,
        status: finalStatus, // Use the finalized status
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

      // Add to Firestore
      final docRef = await _itemsCollection.add(itemData.toMap());
      
      print('Item added successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding item: $e');
      throw Exception('Failed to add item: ${e.toString()}');
    }
  }

  // Upload image to Supabase (private method)
  Future<String> _uploadImageToSupabase(File imageFile, String userId) async {
    try {
      // Create a custom path with user ID for organization
      final fileName = 'user_$userId/${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
      
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

  // ENHANCED: Get all items (filter out sold items for homescreen)
  Future<List<ItemModel>> getAllItems() async {
    try {
      print('📱 Loading all available items (filtering out sold items)...');
      
      final querySnapshot = await _itemsCollection
          .orderBy('createdAt', descending: true)
          .get();
      
      final allItems = querySnapshot.docs
          .map((doc) => ItemModel.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id))
          .toList();

      // CRITICAL: Filter out sold items for homescreen
      final availableItems = _filterAvailableItems(allItems);
      
      print('✅ Loaded ${availableItems.length} available items (filtered out ${allItems.length - availableItems.length} sold items)');
      return availableItems;
    } catch (e) {
      print('Error getting items: $e');
      throw Exception('Failed to get items: ${e.toString()}');
    }
  }

  // ENHANCED: Get items by category (filter out sold items)
  Future<List<ItemModel>> getItemsByCategory(String category) async {
    try {
      print('📂 Loading items by category: $category (filtering out sold items)...');
      
      // Remove orderBy to avoid composite index requirement
      final querySnapshot = await _itemsCollection
          .where('category', isEqualTo: category)
          .get();
      
      final allItems = querySnapshot.docs
          .map((doc) => ItemModel.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id))
          .toList();
      
      // CRITICAL: Filter out sold items
      final availableItems = _filterAvailableItems(allItems);
      
      // Sort in memory instead
      availableItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('✅ Loaded ${availableItems.length} available items in category "$category"');
      return availableItems;
    } catch (e) {
      print('Error getting items by category: $e');
      throw Exception('Failed to get items by category: ${e.toString()}');
    }
  }

  // ENHANCED: Get items by seller (keep original functionality for seller's own items)
  Future<List<ItemModel>> getItemsBySeller(String sellerId) async {
    try {
      print('🔍 DEBUG getItemsBySeller called with sellerId: $sellerId');
      
      if (sellerId.isEmpty) {
        print('❌ ERROR: sellerId is empty');
        throw Exception('Seller ID cannot be empty');
      }
      
      print('📡 Querying Firestore for items where sellerId == $sellerId (NO ORDER BY)');
      
      // CRITICAL FIX: Remove ALL orderBy operations to avoid composite index
      final querySnapshot = await _itemsCollection
          .where('sellerId', isEqualTo: sellerId)
          .get(); // NO .orderBy() here!
      
      print('📊 Query completed. Documents found: ${querySnapshot.docs.length}');
      
      if (querySnapshot.docs.isEmpty) {
        print('⚠️ No documents found for seller: $sellerId');
        
        // Debug: Check if there are ANY items in the collection
        try {
          final allItemsQuery = await _itemsCollection.limit(3).get();
          print('📋 Total items in collection (first 3): ${allItemsQuery.docs.length}');
          
          for (var doc in allItemsQuery.docs) {
            final data = doc.data() as Map<String, dynamic>;
            print('   Item: ${data['name']} | Seller: ${data['sellerId']}');
          }
        } catch (debugError) {
          print('Debug query failed: $debugError');
        }
        
        return [];
      }
      
      final items = <ItemModel>[];
      
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          print('📄 Processing document ${doc.id}:');
          print('   Name: ${data['name']}');
          print('   Category: ${data['category']}');
          print('   Price: ${data['price']}');
          print('   SellerId: ${data['sellerId']}');
          print('   Status: ${data['status']}'); // Added status logging
          print('   ImageUrl: ${data['imageUrl']}');
          
          final item = ItemModel.fromMap(data, doc.id);
          items.add(item);
          print('✅ Successfully created ItemModel for: ${item.name}');
        } catch (e) {
          print('❌ Error processing document ${doc.id}: $e');
          print('   Document data: ${doc.data()}');
        }
      }
      
      // Sort in memory by creation date (newest first)
      try {
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        print('✅ Items sorted by creation date');
      } catch (sortError) {
        print('⚠️ Sort error, keeping original order: $sortError');
        // If sorting fails, just keep the original order
      }
      
      print('🎉 Successfully loaded ${items.length} items for seller: $sellerId');
      return items; // NOTE: For seller's own view, show ALL items including sold ones
      
    } catch (e) {
      print('💥 ERROR in getItemsBySeller: $e');
      print('   StackTrace: ${StackTrace.current}');
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

  // Update item with optional new image
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

  // ENHANCED: Delete item (mark as unavailable instead of hard delete)
  Future<void> deleteItem(String itemId) async {
    try {
      print('🗑️ Starting item deletion: $itemId');
      
      // SOFT DELETE: Mark as unavailable instead of hard delete
      await _itemsCollection.doc(itemId).update({
        'status': 'unavailable',
        'deletedAt': Timestamp.now(),
      });
      
      print('✅ Item marked as unavailable successfully');
      
      // Optionally, still handle image deletion in background
      final doc = await _itemsCollection.doc(itemId).get();
      String? imageUrl;
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        imageUrl = data['imageUrl'] as String?;
        print('📷 Item has image: ${imageUrl != null ? "Yes" : "No"}');
      }
      
      // DELETE IMAGE IN BACKGROUND (don't wait for it)
      if (imageUrl != null && imageUrl.isNotEmpty) {
        print('🔄 Starting background image deletion...');
        _deleteImageInBackground(imageUrl);
      }
      
      print('🎉 Item deletion completed (image deletion running in background)');
      
    } catch (e) {
      print('❌ Error deleting item: $e');
      throw Exception('Failed to delete item: ${e.toString()}');
    }
  }

  // Helper method to delete image in background (fire-and-forget)
  void _deleteImageInBackground(String imageUrl) {
    // Run this asynchronously without blocking the UI
    Future.delayed(Duration.zero, () async {
      try {
        print('🔄 Background: Attempting to delete image from Supabase...');
        final success = await imageService.deleteImage(imageUrl).timeout(
          const Duration(seconds: 10), // 10 second timeout
          onTimeout: () {
            print('⏰ Image deletion timed out, but continuing...');
            return false;
          },
        );
        
        if (success) {
          print('✅ Background: Image deleted from Supabase successfully');
        } else {
          print('⚠️ Background: Image deletion failed, but item is already deleted from database');
        }
      } catch (e) {
        print('❌ Background: Error deleting image from Supabase: $e');
        // Don't throw error since the item is already deleted from Firestore
      }
    });
  }

  // Delete image from Supabase (private method)
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

  // ENHANCED: Search items by name (filter out sold items)
  Future<List<ItemModel>> searchItems(String query) async {
    try {
      print('🔍 Searching for: "$query" (filtering out sold items)...');
      
      // Firestore doesn't support full-text search, so we'll use a simple approach
      // For better search, consider using Algolia or similar service
      final querySnapshot = await _itemsCollection.get();
      
      final allItems = querySnapshot.docs
          .map((doc) => ItemModel.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id))
          .toList();
      
      // Filter items that contain the query in name (case-insensitive) AND are available
      final availableItems = _filterAvailableItems(allItems);
      final searchResults = availableItems.where((item) => 
          item.name.toLowerCase().contains(query.toLowerCase())).toList();
      
      print('✅ Found ${searchResults.length} available items matching "$query"');
      return searchResults;
    } catch (e) {
      print('Error searching items: $e');
      throw Exception('Failed to search items: ${e.toString()}');
    }
  }

  // ENHANCED: Get items stream for real-time updates (filter out sold items)
  Stream<List<ItemModel>> getItemsStream() {
    return _itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final allItems = snapshot.docs
              .map((doc) => ItemModel.fromMap(
                  doc.data() as Map<String, dynamic>, 
                  doc.id))
              .toList();
          
          // Filter out sold items for live updates
          return _filterAvailableItems(allItems);
        });
  }

  // NEW: Check if item is still available
  Future<bool> isItemAvailable(String itemId) async {
    try {
      final doc = await _itemsCollection.doc(itemId).get();
      
      if (!doc.exists) return false;
      
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? '';
      
      return status != 'sold' && status != 'unavailable';
    } catch (e) {
      print('Error checking item availability: $e');
      return false;
    }
  }

  // NEW: Mark item as sold (used by OrderService)
  Future<bool> markItemAsSold(String itemId, String buyerId, String orderId) async {
    try {
      await _itemsCollection.doc(itemId).update({
        'status': 'sold',
        'soldAt': Timestamp.now(),
        'soldTo': buyerId,
        'orderId': orderId,
      });
      return true;
    } catch (e) {
      print('Error marking item as sold: $e');
      return false;
    }
  }

  // DEBUG METHODS (Keep all your existing debug methods)
  
  // Test Firestore connection
  Future<void> testFirestoreConnection() async {
    try {
      print('🧪 Testing Firestore connection...');
      
      // Test 1: Check if we can read from items collection
      final testQuery = await _itemsCollection.limit(1).get();
      print('✅ Firestore connection successful. Can read items collection.');
      print('   Items collection has ${testQuery.docs.length} documents (showing first 1)');
      
      // Test 2: Check current user
      final user = _auth.currentUser;
      if (user != null) {
        print('✅ User authenticated:');
        print('   UID: ${user.uid}');
        print('   Email: ${user.email}');
        print('   Display Name: ${user.displayName}');
      } else {
        print('❌ No user authenticated');
      }
      
    } catch (e) {
      print('❌ Firestore connection test failed: $e');
    }
  }

  // Debug helper: Get all items with debug prints
  Future<List<ItemModel>> getAllItemsDebug() async {
    try {
      print('🔍 DEBUG getAllItemsDebug called');
      
      final querySnapshot = await _itemsCollection
          .orderBy('createdAt', descending: true)
          .get();
      
      print('📊 Total items in database: ${querySnapshot.docs.length}');
      
      final items = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              print('📄 Item: ${data['name']} | Seller: ${data['sellerId']} | Status: ${data['status']}');
              return ItemModel.fromMap(data, doc.id);
            } catch (e) {
              print('❌ Error parsing item ${doc.id}: $e');
              return null;
            }
          })
          .where((item) => item != null)
          .cast<ItemModel>()
          .toList();
      
      print('✅ Successfully parsed ${items.length} items');
      return items;
      
    } catch (e) {
      print('💥 ERROR in getAllItemsDebug: $e');
      throw Exception('Failed to get all items: ${e.toString()}');
    }
  }

  // Migration helper to move existing Firebase Storage images to Supabase
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

  // Add these methods to your existing ItemService class (item_services.dart)

  // ADMIN: Get ALL items including sold ones (for admin management)
  Future<List<ItemModel>> getAllItemsForAdmin() async {
    try {
      print('🔧 ADMIN: Loading ALL items (including sold items)...');
      
      final querySnapshot = await _itemsCollection
          .orderBy('createdAt', descending: true)
          .get();
      
      final allItems = querySnapshot.docs
          .map((doc) => ItemModel.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id))
          .toList();

      print('✅ ADMIN: Loaded ${allItems.length} total items (including sold items)');
      return allItems;
    } catch (e) {
      print('Error getting all items for admin: $e');
      throw Exception('Failed to get all items for admin: ${e.toString()}');
    }
  }

  // ADMIN: Get items by category including sold ones
  Future<List<ItemModel>> getItemsByCategoryForAdmin(String category) async {
    try {
      print('🔧 ADMIN: Loading items by category: $category (including sold items)...');
      
      final querySnapshot = await _itemsCollection
          .where('category', isEqualTo: category)
          .get();
      
      final allItems = querySnapshot.docs
          .map((doc) => ItemModel.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id))
          .toList();
      
      // Sort in memory by creation date
      allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('✅ ADMIN: Loaded ${allItems.length} items in category "$category" (including sold)');
      return allItems;
    } catch (e) {
      print('Error getting items by category for admin: $e');
      throw Exception('Failed to get items by category for admin: ${e.toString()}');
    }
  }

  // ADMIN: Search all items including sold ones
  Future<List<ItemModel>> searchAllItemsForAdmin(String query) async {
    try {
      print('🔧 ADMIN: Searching ALL items for: "$query" (including sold items)...');
      
      // Get all items first
      final querySnapshot = await _itemsCollection.get();
      
      final allItems = querySnapshot.docs
          .map((doc) => ItemModel.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id))
          .toList();
      
      // Filter items that contain the query in name, seller, or category
      final searchResults = allItems.where((item) => 
          item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.sellerName.toLowerCase().contains(query.toLowerCase()) ||
          item.category.toLowerCase().contains(query.toLowerCase())).toList();
      
      print('✅ ADMIN: Found ${searchResults.length} items matching "$query" (including sold)');
      return searchResults;
    } catch (e) {
      print('Error searching all items for admin: $e');
      throw Exception('Failed to search all items for admin: ${e.toString()}');
    }
  }

  // ADMIN: Get items by status
  Future<List<ItemModel>> getItemsByStatusForAdmin(String status) async {
    try {
      print('🔧 ADMIN: Loading items with status: $status...');
      
      QuerySnapshot querySnapshot;
      
      if (status.toLowerCase() == 'all') {
        querySnapshot = await _itemsCollection
            .orderBy('createdAt', descending: true)
            .get();
      } else {
        querySnapshot = await _itemsCollection
            .where('status', isEqualTo: status)
            .get();
      }
      
      final items = querySnapshot.docs
          .map((doc) => ItemModel.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id))
          .toList();
      
      // Sort if not already sorted
      if (status.toLowerCase() != 'all') {
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      
      print('✅ ADMIN: Loaded ${items.length} items with status "$status"');
      return items;
    } catch (e) {
      print('Error getting items by status for admin: $e');
      throw Exception('Failed to get items by status for admin: ${e.toString()}');
    }
  }

  // ADMIN: Get statistics about items
  Future<Map<String, dynamic>> getItemStatisticsForAdmin() async {
    try {
      print('🔧 ADMIN: Calculating item statistics...');
      
      final querySnapshot = await _itemsCollection.get();
      
      final allItems = querySnapshot.docs
          .map((doc) => ItemModel.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id))
          .toList();
      
      final Map<String, int> statusCount = {};
      final Map<String, int> categoryCount = {};
      final Map<String, int> sellerCount = {};
      
      for (final item in allItems) {
        // Count by status
        statusCount[item.status] = (statusCount[item.status] ?? 0) + 1;
        
        // Count by category
        categoryCount[item.category] = (categoryCount[item.category] ?? 0) + 1;
        
        // Count by seller
        sellerCount[item.sellerId] = (sellerCount[item.sellerId] ?? 0) + 1;
      }
      
      final statistics = {
        'totalItems': allItems.length,
        'availableItems': allItems.where((item) => item.status != 'sold').length,
        'soldItems': allItems.where((item) => item.status == 'sold').length,
        'statusBreakdown': statusCount,
        'categoryBreakdown': categoryCount,
        'sellerBreakdown': sellerCount,
        'totalSellers': sellerCount.keys.length,
      };
      
      print('✅ ADMIN: Statistics calculated');
      return statistics;
    } catch (e) {
      print('Error getting item statistics for admin: $e');
      return {};
    }
  }

  // ADMIN: Log admin actions for audit trail
  Future<void> logAdminAction({
    required String action,
    required String itemId,
    String? details,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('adminLogs').add({
        'adminId': user.uid,
        'adminEmail': user.email,
        'action': action,
        'itemId': itemId,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('✅ ADMIN: Action logged - $action for item $itemId');
    } catch (e) {
      print('Error logging admin action: $e');
      // Don't throw error as this is just for logging
    }
  }
}