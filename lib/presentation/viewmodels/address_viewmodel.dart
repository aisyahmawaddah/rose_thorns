// lib/presentation/viewmodels/address_viewmodel.dart
import 'package:flutter/material.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/models/address_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();
  
  bool _isLoading = false;
  String? _error;
  List<Address> _addresses = [];
  bool _disposed = false;
  bool _hasLoaded = false; // ADD THIS LINE

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Address> get addresses => _addresses;
  bool get hasLoaded => _hasLoaded; // ADD THIS GETTER

  // Update loadAddresses method:
  Future<void> loadAddresses() async {
    if (_disposed || _isLoading || _hasLoaded) return; // PREVENT MULTIPLE CALLS
    
    _setLoading(true);
    try {
      _addresses = await _orderRepository.getUserAddresses();
      _hasLoaded = true; // SET FLAG AFTER SUCCESSFUL LOAD
      _clearError();
    } catch (e) {
      _setError('Failed to load addresses: $e');
      _hasLoaded = true; // SET FLAG EVEN ON ERROR
    }
    if (!_disposed) {
      _setLoading(false);
    }
  }

  // Add refresh method:
  Future<void> refreshAddresses() async {
    if (_disposed) return;
    _hasLoaded = false; // RESET FLAG TO ALLOW REFRESH
    await loadAddresses();
  }
  

  // Add address
  Future<bool> addAddress({
    required String title,
    required String address,
    String? building,
    String? room,
    String? notes,
    bool isDefault = false,
  }) async {
    if (_disposed) return false; // ADD THIS CHECK
    _setLoading(true);
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _setError('User not authenticated');
        return false;
      }

      final newAddress = Address(
        id: '', // Will be set by Firestore
        userId: currentUser.uid,
        title: title,
        address: address,
        building: building,
        room: room,
        notes: notes,
        isDefault: isDefault,
        createdAt: DateTime.now(),
      );

      final addressId = await _orderRepository.addAddress(newAddress);
      if (addressId != null) {
        if (!_disposed) await loadAddresses(); // ADD DISPOSED CHECK
        _clearError();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to add address: $e');
      return false;
    } finally {
      if (!_disposed) _setLoading(false); // ADD DISPOSED CHECK
    }
  }

  // Update address
  Future<bool> updateAddress(String addressId, Address updatedAddress) async {
    if (_disposed) return false; // ADD THIS CHECK
    _setLoading(true);
    try {
      final success = await _orderRepository.updateAddress(addressId, updatedAddress);
      if (success) {
        if (!_disposed) await loadAddresses(); // ADD DISPOSED CHECK
        _clearError();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update address: $e');
      return false;
    } finally {
      if (!_disposed) _setLoading(false); // ADD DISPOSED CHECK
    }
  }

  // Delete address
  Future<bool> deleteAddress(String addressId) async {
    if (_disposed) return false; // ADD THIS CHECK
    _setLoading(true);
    try {
      final success = await _orderRepository.deleteAddress(addressId);
      if (success) {
        if (!_disposed) await loadAddresses(); // ADD DISPOSED CHECK
        _clearError();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to delete address: $e');
      return false;
    } finally {
      if (!_disposed) _setLoading(false); // ADD DISPOSED CHECK
    }
  }

  // Set default address
  Future<bool> setDefaultAddress(String addressId) async {
    if (_disposed) return false; // ADD THIS CHECK
    _setLoading(true);
    try {
      final success = await _orderRepository.setDefaultAddress(addressId);
      if (success) {
        if (!_disposed) await loadAddresses(); // ADD DISPOSED CHECK
        _clearError();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to set default address: $e');
      return false;
    } finally {
      if (!_disposed) _setLoading(false); // ADD DISPOSED CHECK
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (_disposed) return; // ADD THIS CHECK
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    if (_disposed) return; // ADD THIS CHECK
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_disposed) return; // ADD THIS CHECK
    _error = null;
    notifyListeners();
  }

}