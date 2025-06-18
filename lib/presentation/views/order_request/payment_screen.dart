// lib/presentation/views/order_request/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../../../data/services/stripe_payment_service.dart';
import '../../../presentation/viewmodels/purchase_history_viewmodel.dart'; // UPDATED: Correct import
import 'purchase_history_screen.dart'; // UPDATED: Correct import path

class PaymentScreen extends StatefulWidget {
  final double amount;
  final Future<bool> Function() onPaymentSuccess;

  const PaymentScreen({
    Key? key,
    required this.amount,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final StripePaymentService _paymentService = StripePaymentService();
  bool _isProcessing = false;
  CardFieldInputDetails? _cardDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount to pay
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Amount to Pay',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RM ${widget.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Payment Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Stripe Card Field
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CardField(
                onCardChanged: (card) {
                  setState(() {
                    _cardDetails = card;
                  });
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintText: 'Card number, MM/YY, CVC',
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // REAL PAYMENT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing || !_isCardComplete() 
                    ? null 
                    : _processRealPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Processing Real Payment...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.credit_card),
                          const SizedBox(width: 8),
                          Text('PAY RM ${widget.amount.toStringAsFixed(2)} (REAL)', 
                               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade400)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR TEST PAYMENTS', 
                             style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Test buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () => _processTestPayment(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Test Success'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () => _processTestPayment(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Test Failure'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isCardComplete() => _cardDetails?.complete ?? false;

  // REAL PAYMENT METHOD
  void _processRealPayment() async {
    if (!_isCardComplete()) {
      _showErrorDialog('Please complete your card information');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final result = await _paymentService.processRealPayment(
        amount: widget.amount,
        currency: 'MYR',
      );
      
      await _handlePaymentResult(result);
    } catch (e) {
      _showErrorDialog('Payment failed: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // TEST PAYMENT METHODS
  void _processTestPayment(bool shouldSucceed) async {
    setState(() => _isProcessing = true);

    try {
      final result = await _paymentService.processTestPayment(
        amount: widget.amount,
        currency: 'MYR',
        shouldSucceed: shouldSucceed,
      );
      
      await _handlePaymentResult(result);
    } catch (e) {
      _showErrorDialog('Payment failed: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // COMMON PAYMENT RESULT HANDLER
  Future<void> _handlePaymentResult(PaymentResult result) async {
    if (result.isSuccess) {
      // Payment successful, now place the order
      final orderSuccess = await widget.onPaymentSuccess();
      
      if (orderSuccess) {
        // UPDATED: Navigate to purchase history
        await _navigateToPurchaseHistory();
      } else {
        _showErrorDialog('Payment successful but order failed. Contact support.');
      }
    } else {
      _showErrorDialog(result.message);
    }
  }

  // UPDATED: Navigate to Purchase History
  Future<void> _navigateToPurchaseHistory() async {
    try {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Order placed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Navigate to purchase history screen with provider
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => PurchaseHistoryViewModel(), // UPDATED: Create correct viewmodel
              child: PurchaseHistoryScreen(), // UPDATED: Navigate to purchase history
            ),
          ),
          (route) => route.isFirst, // Keep only the home screen in the stack
        );
      }
    } catch (e) {
      print('Error navigating to purchase history: $e');
      // Fallback: show success dialog if navigation fails
      _showSuccessDialog();
    }
  }

  // FALLBACK SUCCESS DIALOG (if navigation fails)
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Payment Successful!'),
          ],
        ),
        content: const Text('Your payment has been processed and your order has been placed.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Payment Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}