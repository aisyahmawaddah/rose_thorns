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
    print('🔍 AddressService: userId = $userId');
    
    if (userId == null) {
      print('❌ AddressService: No user ID, returning empty list');
      return [];
    }

    print('📡 AddressService: Querying Firestore...');
    final snapshot = await _firestore
        .collection('addresses')
        .where('userId', isEqualTo: userId)
        .get();

    print('✅ AddressService: Query completed, ${snapshot.docs.length} documents found');

    List<Address> addresses = snapshot.docs.map((doc) {
      final data = doc.data();
      return Address.fromJson({...data, 'id': doc.id});
    }).toList();

    print('📋 AddressService: Parsed ${addresses.length} addresses');
    return addresses;
  } catch (e) {
    print('❌ AddressService error: $e');
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