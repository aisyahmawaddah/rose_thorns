import 'dart:io';
import 'package:koopon/data/models/item_model.dart';
import 'package:koopon/data/services/item_services.dart';

class ItemRepository {
  final ItemService _itemService;

  ItemRepository({ItemService? itemService})
      : _itemService = itemService ?? ItemService();

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
      return await _itemService.addItem(
        name: name,
        category: category,
        status: status,
        price: price,
        imageFile: imageFile,
        additionalFields: additionalFields,
      );
    } catch (e) {
      throw Exception('Repository: Failed to add item - ${e.toString()}');
    }
  }

  // Get all items
  Future<List<ItemModel>> getAllItems() async {
    try {
      return await _itemService.getAllItems();
    } catch (e) {
      throw Exception('Repository: Failed to get items - ${e.toString()}');
    }
  }

  // Get items by category
  Future<List<ItemModel>> getItemsByCategory(String category) async {
    try {
      return await _itemService.getItemsByCategory(category);
    } catch (e) {
      throw Exception('Repository: Failed to get items by category - ${e.toString()}');
    }
  }

  // Get items by seller
  Future<List<ItemModel>> getItemsBySeller(String sellerId) async {
    try {
      return await _itemService.getItemsBySeller(sellerId);
    } catch (e) {
      throw Exception('Repository: Failed to get items by seller - ${e.toString()}');
    }
  }

  // Update item
  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    try {
      await _itemService.updateItem(itemId, updates);
    } catch (e) {
      throw Exception('Repository: Failed to update item - ${e.toString()}');
    }
  }

  // Delete item
  Future<void> deleteItem(String itemId) async {
    try {
      await _itemService.deleteItem(itemId);
    } catch (e) {
      throw Exception('Repository: Failed to delete item - ${e.toString()}');
    }
  }

  // Search items
  Future<List<ItemModel>> searchItems(String query) async {
    try {
      return await _itemService.searchItems(query);
    } catch (e) {
      throw Exception('Repository: Failed to search items - ${e.toString()}');
    }
  }

  // Get items stream for real-time updates
  Stream<List<ItemModel>> getItemsStream() {
    return _itemService.getItemsStream();
  }
}