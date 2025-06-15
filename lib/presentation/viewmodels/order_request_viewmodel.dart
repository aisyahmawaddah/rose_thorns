// lib/presentation/viewmodels/order_request_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/address_model.dart';
import '../../data/models/time_slot_model.dart';
import '../../data/services/order_service.dart';
import '../../data/services/cart_service.dart'; // ADD: Import cart service

class OrderRequestViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartService _cartService = CartService(); // ADD: Cart service instance
  
  // ... keep all your existing state variables and getters ...
  
  // State
  List<CartItem> _cartItems = [];
  DealMethod _selectedDealMethod = DealMethod.inCampusMeetup;
  Address? _selectedMeetupLocation;
  Address? _selectedAddress;
  DateTime? _selectedDate;
  TimeSlot? _selectedTimeSlot;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  // Getters
  List<CartItem> get cartItems => _cartItems;
  DealMethod get selectedDealMethod => _selectedDealMethod;
  Address? get selectedMeetupLocation => _selectedMeetupLocation;
  Address? get selectedAddress => _selectedAddress;
  DateTime? get selectedDate => _selectedDate;
  TimeSlot? get selectedTimeSlot => _selectedTimeSlot;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  // Calculated getters
  double get subtotal {
    return _cartItems.fold(0.0, (sum, item) {
      double price = 0.0;
      int quantity = 1;
      
      try {
        if (item.price != null) {
          price = item.price!.toDouble();
        } else if (item.totalPrice != null) {
          return sum + item.totalPrice!.toDouble();
        }
        
        if (item.quantity != null) {
          quantity = item.quantity!;
        }
      } catch (e) {
        print('Error calculating subtotal for item: $e');
      }
      
      return sum + (price * quantity);
    });
  }

  double get deliveryFee {
    return _selectedDealMethod == DealMethod.delivery ? 3.0 : 0.0;
  }

  double get total {
    return subtotal + deliveryFee;
  }

  // Validation getters
  bool get canProceedFromDealMethod => true;

  bool get canProceedFromLocation {
    if (_selectedDealMethod == DealMethod.inCampusMeetup) {
      return _selectedMeetupLocation != null;
    } else if (_selectedDealMethod == DealMethod.delivery) {
      return _selectedAddress != null;
    }
    return true;
  }

  bool get canProceedFromDateTime {
    return _selectedDate != null && _selectedTimeSlot != null;
  }

  bool get canPlaceOrder {
    if (_selectedDealMethod == DealMethod.inCampusMeetup) {
      return _selectedMeetupLocation != null && 
             _selectedDate != null && 
             _selectedTimeSlot != null;
    } else {
      return _selectedAddress != null &&
             _selectedDate != null && 
             _selectedTimeSlot != null;
    }
  }

  // Initialize with cart items
  void initializeOrder(List<CartItem> items) {
    if (_isInitialized) return;
    
    _cartItems = List.from(items);
    _isInitialized = true;
    _clearError();
    notifyListeners();
  }

  // Set deal method
  void setDealMethod(DealMethod method) {
    _selectedDealMethod = method;
    _clearError();
    
    if (method == DealMethod.delivery) {
      _selectedMeetupLocation = null;
    } else {
      _selectedAddress = null;
    }
    
    notifyListeners();
  }

  void selectDealMethod(DealMethod method) => setDealMethod(method);

  void setMeetupLocation(Address? address) {
    _selectedMeetupLocation = address;
    _clearError();
    notifyListeners();
  }

  void setAddress(Address? address) {
    _selectedAddress = address;
    _clearError();
    notifyListeners();
  }

  void selectAddress(Address? address) => setAddress(address);

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    _clearError();
    notifyListeners();
  }

  void setSelectedTimeSlot(TimeSlot? timeSlot) {
    _selectedTimeSlot = timeSlot;
    _clearError();
    
    if (timeSlot != null) {
      _selectedDate = timeSlot.date;
    }
    
    notifyListeners();
  }

  void clearTimeSlotSelection() {
    _selectedTimeSlot = null;
    _selectedDate = null;
    _clearError();
    notifyListeners();
  }

  // Validation methods
  bool validateCurrentStep(int step) {
    switch (step) {
      case 0: return canProceedFromDealMethod;
      case 1: return canProceedFromLocation;
      case 2: return canProceedFromDateTime;
      case 3: return canPlaceOrder;
      default: return false;
    }
  }

  String? getValidationError(int step) {
    switch (step) {
      case 1:
        if (_selectedDealMethod == DealMethod.inCampusMeetup && _selectedMeetupLocation == null) {
          return 'Please select a meetup location';
        }
        if (_selectedDealMethod == DealMethod.delivery && _selectedAddress == null) {
          return 'Please select a delivery address';
        }
        break;
      case 2:
        if (_selectedDate == null) {
          return _selectedDealMethod == DealMethod.inCampusMeetup
              ? 'Please select a meetup date'
              : 'Please select a delivery date';
        }
        if (_selectedTimeSlot == null) {
          return _selectedDealMethod == DealMethod.inCampusMeetup
              ? 'Please select a meetup time slot'
              : 'Please select a delivery time slot';
        }
        break;
      case 3:
        if (!canPlaceOrder) {
          if (_selectedDealMethod == DealMethod.inCampusMeetup) {
            if (_selectedMeetupLocation == null) return 'Missing meetup location';
            if (_selectedDate == null) return 'Missing meetup date';
            if (_selectedTimeSlot == null) return 'Missing meetup time slot';
          } else {
            if (_selectedAddress == null) return 'Missing delivery address';
            if (_selectedDate == null) return 'Missing delivery date';
            if (_selectedTimeSlot == null) return 'Missing delivery time slot';
          }
        }
        break;
    }
    return null;
  }

  // UPDATED: Place order with cart clearing
  Future<bool> placeOrder() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _setError('User not authenticated. Please login and try again.');
      return false;
    }

    if (!canPlaceOrder) {
      _setError('Please complete all required fields before placing the order');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      // Get sellers from cart items
      final sellers = <String>{};
      for (final cartItem in _cartItems) {
        if (cartItem.sellerId.isNotEmpty) {
          sellers.add(cartItem.sellerId);
        }
      }
      
      if (sellers.length > 1) {
        throw Exception('Cannot place order for items from multiple sellers');
      }
      
      if (sellers.isEmpty) {
        throw Exception('No seller information found in cart items');
      }

      final sellerId = sellers.first;

      Address? orderAddress;
      if (_selectedDealMethod == DealMethod.inCampusMeetup) {
        orderAddress = _selectedMeetupLocation;
      } else {
        orderAddress = _selectedAddress;
      }

      final orderRequest = OrderRequest(
        id: '',
        userId: currentUser.uid,
        sellerId: sellerId,
        items: _cartItems,
        dealMethod: _selectedDealMethod,
        meetupLocation: orderAddress,
        selectedDate: _selectedDate,
        selectedTimeSlot: _selectedTimeSlot,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        status: OrderStatus.placed,
        createdAt: DateTime.now(),
      );

      print('Attempting to place order...');
      final success = await _orderService.placeOrder(orderRequest);
      
      if (success) {
        print('Order placed successfully!');
        
        // IMPORTANT: Clear the cart after successful order
        try {
          final cartCleared = await _cartService.clearCart();
          if (cartCleared) {
            print('✅ Cart cleared successfully');
          } else {
            print('⚠️ Warning: Cart may not have been cleared completely');
          }
        } catch (e) {
          print('⚠️ Warning: Error clearing cart: $e');
          // Don't fail the order if cart clearing fails
        }
        
        _resetOrder();
        return true;
      } else {
        _setError('Failed to place order. Please try again.');
        return false;
      }

    } catch (e) {
      print('ERROR placing order: $e');
      _setError('Error placing order: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset order data
  void _resetOrder() {
    _cartItems.clear();
    _selectedDealMethod = DealMethod.inCampusMeetup;
    _selectedMeetupLocation = null;
    _selectedAddress = null;
    _selectedDate = null;
    _selectedTimeSlot = null;
    _isInitialized = false;
    _clearError();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Get order summary for display
  Map<String, dynamic> getOrderSummary() {
    return {
      'items': _cartItems,
      'dealMethod': _selectedDealMethod,
      'meetupLocation': _selectedMeetupLocation,
      'deliveryAddress': _selectedAddress,
      'selectedDate': _selectedDate,
      'selectedTimeSlot': _selectedTimeSlot,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
    };
  }

  @override
  void dispose() {
    super.dispose();
  }
}