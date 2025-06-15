// lib/presentation/views/order_request_screen.dart
import 'package:flutter/material.dart';
import 'package:koopon/presentation/views/order_request/purchase_history_screen.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/order_request_viewmodel.dart';
import '../../viewmodels/address_viewmodel.dart';
import '../../widgets/deal_method_selector.dart';
import '../../widgets/address_selector.dart';
import '../../widgets/time_slot_selector.dart';
import '../../widgets/order_summary_widget.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/order_model.dart';
//import 'purchase_history_screen.dart';
import 'payment_screen.dart';

class OrderRequestScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const OrderRequestScreen({
    Key? key,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<OrderRequestScreen> createState() => _OrderRequestScreenState();
}

class _OrderRequestScreenState extends State<OrderRequestScreen> {
  late PageController _pageController;
  int _currentStep = 0;

  final List<String> _stepTitles = [
    'Deal Method',
    'Location',
    'Date & Time',
    'Order Summary',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final orderViewModel = context.read<OrderRequestViewModel>();
    
    // Validate current step before proceeding
    if (!orderViewModel.validateCurrentStep(_currentStep)) {
      final error = orderViewModel.getValidationError(_currentStep);
      if (error != null) {
        _showErrorSnackBar(error);
      }
      return;
    }

    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Request'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<OrderRequestViewModel, AddressViewModel>(
        builder: (context, orderViewModel, addressViewModel, _) {
          // Initialize on first build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!orderViewModel.isInitialized) {
              orderViewModel.initializeOrder(widget.cartItems);
            }
            if (addressViewModel.addresses.isEmpty && !addressViewModel.isLoading) {
              addressViewModel.loadAddresses();
            }
          });

          return Column(
            children: [
              // Progress indicator
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  children: List.generate(_stepTitles.length, (index) {
                    final isActive = index == _currentStep;
                    final isCompleted = index < _currentStep;
                    
                    return Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? Colors.green
                                  : isActive
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                            ),
                            child: Icon(
                              isCompleted ? Icons.check : Icons.circle,
                              size: 14,
                              color: isCompleted || isActive
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _stepTitles[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                color: isActive ? Colors.blue : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          if (index < _stepTitles.length - 1)
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Colors.grey.shade400,
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              
              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildDealMethodStep(),
                    _buildLocationStep(),
                    _buildDateTimeStep(),
                    _buildOrderSummaryStep(),
                  ],
                ),
              ),
              
              // Navigation buttons
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          child: Text('Back'),
                        ),
                      ),
                    if (_currentStep > 0) SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: orderViewModel.isLoading ? null : _handleNextAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: orderViewModel.isLoading
                            ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : Text(_getButtonText(orderViewModel)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDealMethodStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Deal Method',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Choose how you would like to receive your items',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          SizedBox(height: 16),
          DealMethodSelector(),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    return Consumer<OrderRequestViewModel>(
      builder: (context, viewModel, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewModel.selectedDealMethod == DealMethod.inCampusMeetup
                    ? 'Select Meetup Location'
                    : 'Select Delivery Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                viewModel.selectedDealMethod == DealMethod.inCampusMeetup
                    ? 'Choose a convenient location to meet with the seller'
                    : 'Choose where you want your items delivered',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 16),
              
              // Show AddressSelector for both deal methods
              AddressSelector(),
              
              // Optional info box based on deal method
              if (viewModel.selectedDealMethod == DealMethod.delivery) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Delivery fee: RM 3.00 will be added to your total.',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateTimeStep() {
    return Consumer<OrderRequestViewModel>(
      builder: (context, viewModel, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewModel.selectedDealMethod == DealMethod.inCampusMeetup
                    ? 'Select Meetup Date & Time'
                    : 'Select Delivery Date & Time',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                viewModel.selectedDealMethod == DealMethod.inCampusMeetup
                    ? 'Choose when you want to meet with the seller'
                    : 'Choose when you want your items delivered',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 16),
              
              // Show TimeSlotSelector for both deal methods
              TimeSlotSelector(),
              
              // Optional info box based on deal method
              if (viewModel.selectedDealMethod == DealMethod.delivery) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please select a convenient time window for delivery. The seller will deliver during your selected time slot.',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSummaryStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Review your order details before confirming',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          SizedBox(height: 16),
          OrderSummaryWidget(),
          SizedBox(height: 24),
          Consumer<OrderRequestViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.error != null) {
                return Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  String _getButtonText(OrderRequestViewModel viewModel) {
    switch (_currentStep) {
      case 0:
      case 1:
      case 2:
        return 'Continue';
      case 3:
        return viewModel.selectedDealMethod == DealMethod.delivery
            ? 'Pay using Stripe'
            : 'Place Order';
      default:
        return 'Continue';
    }
  }

  void _handleNextAction() async {
    final viewModel = context.read<OrderRequestViewModel>();
    
    switch (_currentStep) {
      case 0:
      case 1:
      case 2:
        _nextStep();
        break;
      case 3:
        bool success = false;
        
        if (viewModel.selectedDealMethod == DealMethod.delivery) {
          // Navigate to payment screen
          final paymentResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentScreen(
                amount: viewModel.total,
                onPaymentSuccess: () async {
                  return await viewModel.placeOrder();
                },
              ),
            ),
          );
          success = paymentResult == true;
        } else {
          // Place order directly for in-campus meetup
          success = await viewModel.placeOrder();
        }
        
        if (success) {
          _showSuccessDialog();
        }
        break;
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Order Placed!'),
          ],
        ),
        content: Text('Your order has been placed successfully. You can track its status in your order history.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to cart or previous screen
            },
            child: Text('Back to Shopping'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PurchaseHistoryScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('View Order History'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}