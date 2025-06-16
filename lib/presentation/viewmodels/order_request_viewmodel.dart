// lib/presentation/viewmodels/order_request_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/address_model.dart';
import '../../data/models/time_slot_model.dart';
import '../../data/services/order_service.dart';
import '../../data/services/cart_service.dart';

class OrderRequestViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartService _cartService = CartService();
  
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

  // FINAL: Complete order placement with item status update and cart cleanup
  Future<bool> placeOrder() async {
    print('🚀 Starting order placement process...');
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('❌ ERROR: User not authenticated');
      _setError('User not authenticated. Please login and try again.');
      return false;
    }
    print('✅ User authenticated: ${currentUser.uid}');

    if (!canPlaceOrder) {
      print('❌ ERROR: Cannot place order - validation failed');
      final error = getValidationError(3);
      _setError(error ?? 'Please complete all required fields before placing the order');
      return false;
    }
    print('✅ Order validation passed');

    _setLoading(true);
    _clearError();

    try {
      // ENHANCED: Better cart items validation
      print('📦 Validating cart items...');
      if (_cartItems.isEmpty) {
        throw Exception('Cart is empty - no items to order');
      }
      print('✅ Cart has ${_cartItems.length} items');

      // ENHANCED: Better seller validation with debugging
      final sellers = <String>{};
      final itemsWithoutSeller = <String>[];
      
      for (final cartItem in _cartItems) {
        print('   Item: ${cartItem.name}, SellerId: "${cartItem.sellerId}"');
        if (cartItem.sellerId.isNotEmpty) {
          sellers.add(cartItem.sellerId);
        } else {
          itemsWithoutSeller.add(cartItem.name);
        }
      }
      
      if (itemsWithoutSeller.isNotEmpty) {
        throw Exception('Items missing seller information: ${itemsWithoutSeller.join(", ")}');
      }
      
      if (sellers.length > 1) {
        print('❌ ERROR: Multiple sellers found: $sellers');
        throw Exception('Cannot place order for items from multiple sellers. Please order from one seller at a time.');
      }
      
      if (sellers.isEmpty) {
        throw Exception('No seller information found in cart items');
      }

      final sellerId = sellers.first;
      print('✅ Order for seller: $sellerId');

      // ENHANCED: Better address validation
      Address? orderAddress;
      if (_selectedDealMethod == DealMethod.inCampusMeetup) {
        orderAddress = _selectedMeetupLocation;
        if (orderAddress == null) {
          throw Exception('Meetup location is required for in-campus meetup');
        }
        print('✅ Meetup location: ${orderAddress.title}');
      } else {
        orderAddress = _selectedAddress;
        if (orderAddress == null) {
          throw Exception('Delivery address is required for delivery');
        }
        print('✅ Delivery address: ${orderAddress.title}');
      }

      // ENHANCED: Better date/time validation
      if (_selectedDate == null) {
        throw Exception('Date selection is required');
      }
      if (_selectedTimeSlot == null) {
        throw Exception('Time slot selection is required');
      }
      print('✅ Date & Time: ${_selectedDate.toString()} - ${_selectedTimeSlot!.timeRange}');

      // Create order request
      final orderRequest = OrderRequest(
        id: '', // Will be set by OrderService
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

      print('💰 Order totals - Subtotal: RM${subtotal.toStringAsFixed(2)}, Delivery: RM${deliveryFee.toStringAsFixed(2)}, Total: RM${total.toStringAsFixed(2)}');
      print('📋 Attempting to place order in Firestore...');
      
      // CRITICAL: This will now mark items as sold AND place the order atomically
      final success = await _orderService.placeOrder(orderRequest);
      
      if (success) {
        print('✅ Order placed successfully and items marked as sold!');
        
        // IMPORTANT: Clear only the current user's cart (not all carts)
        try {
          await _cartService.clearCart();
          print('✅ Current user cart cleared');
        } catch (cartError) {
          print('⚠️ Warning: Error clearing current cart: $cartError');
        }
        
        // Reset the order state
        _resetOrder();
        print('🎉 Order placement completed successfully!');
        print('🏷️ Items are now marked as sold - other users will see them as sold in their carts');
        return true;
        
      } else {
        print('❌ ERROR: OrderService.placeOrder returned false');
        _setError('Failed to place order in database. Please try again.');
        return false;
      }

    } catch (e) {
      print('❌ EXCEPTION in placeOrder: ${e.toString()}');
      print('Stack trace: ${StackTrace.current}');
      _setError('Error placing order: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
      print('🏁 Order placement process finished');
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