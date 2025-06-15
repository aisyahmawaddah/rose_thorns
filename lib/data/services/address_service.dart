// lib/data/services/address_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address_model.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user addresses (SIMPLIFIED QUERY)
  Future<List<Address>> getUserAddresses() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      // Simplified query - just filter by userId and sort in code
      final snapshot = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: userId)
          .get();

      List<Address> addresses = snapshot.docs.map((doc) {
        final data = doc.data();
        return Address.fromJson({...data, 'id': doc.id});
      }).toList();

      // Sort in code: default addresses first, then by creation date
      addresses.sort((a, b) {
        // First sort by isDefault (true comes first)
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        
        // Then sort by createdAt (newest first)
        return b.createdAt.compareTo(a.createdAt);
      });

      return addresses;
    } catch (e) {
      print('Error getting addresses: $e');
      return [];
    }
  }

  // Add new address
  Future<String?> addAddress(Address address) async {
    try {
      final docRef = await _firestore.collection('addresses').add(address.toJson());
      return docRef.id;
    } catch (e) {
      print('Error adding address: $e');
      return null;
    }
  }

  // Update address
  Future<bool> updateAddress(String addressId, Address address) async {
    try {
      await _firestore.collection('addresses').doc(addressId).update(address.toJson());
      return true;
    } catch (e) {
      print('Error updating address: $e');
      return false;
    }
  }

  // Delete address
  Future<bool> deleteAddress(String addressId) async {
    try {
      await _firestore.collection('addresses').doc(addressId).delete();
      return true;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }

  // Set default address
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final batch = _firestore.batch();
      
      // First, remove default from all addresses
      final addresses = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in addresses.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Set the selected address as default
      batch.update(
        _firestore.collection('addresses').doc(addressId),
        {'isDefault': true}
      );

      await batch.commit();
      return true;
    } catch (e) {
      print('Error setting default address: $e');
      return false;
    }
  }
}