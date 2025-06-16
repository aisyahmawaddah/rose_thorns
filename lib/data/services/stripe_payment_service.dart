// lib/data/services/stripe_payment_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StripePaymentService {
  static const String _backendUrl = 'http://10.211.104.46:3000'; // Replace with your server URL
  
  // REAL PAYMENT PROCESSING (SIMPLIFIED)
  Future<PaymentResult> processRealPayment({
    required double amount,
    required String currency,
  }) async {
    try {
      // Step 1: Create payment intent on backend
      final response = await http.post(
        Uri.parse('$_backendUrl/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (amount * 100).round(), // Convert to cents
          'currency': currency.toLowerCase(),
        }),
      );

      if (response.statusCode != 200) {
        return PaymentResult.error('Failed to create payment intent');
      }

      final data = json.decode(response.body);
      final clientSecret = data['client_secret'];

      if (clientSecret == null) {
        return PaymentResult.error('Invalid payment intent response');
      }

      // Step 2: Confirm payment with Stripe
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // If we reach here without exception, payment was successful
      return PaymentResult.success('Payment completed successfully');

    } catch (e) {
      if (e is StripeException) {
        if (e.error.code == FailureCode.Canceled) {
          return PaymentResult.error('Payment canceled by user');
        } else {
          return PaymentResult.error('Payment error: ${e.error.message}');
        }
      }
      return PaymentResult.error('Payment failed: ${e.toString()}');
    }
  }

  // MOCK PAYMENT (keep for testing)
  Future<PaymentResult> processTestPayment({
    required double amount,
    required String currency,
    bool shouldSucceed = true,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      if (shouldSucceed) {
        return PaymentResult.success(
          'Test payment of ${currency.toUpperCase()} ${amount.toStringAsFixed(2)} completed successfully'
        );
      } else {
        return PaymentResult.error('Test payment failed - insufficient funds');
      }
    } catch (e) {
      return PaymentResult.error('Test payment error: ${e.toString()}');
    }
  }

  // MOCK PAYMENT WITH CARD FIELD (keep for testing)
  Future<PaymentResult> processPaymentWithCardField({
    required double amount,
    required String currency,
  }) async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: 'Test User',
              email: 'test@example.com',
            ),
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      
      return PaymentResult.success('Payment of ${currency.toUpperCase()} ${amount.toStringAsFixed(2)} processed successfully');

    } catch (e) {
      return PaymentResult.error('Payment failed: ${e.toString()}');
    }
  }
}

class PaymentResult {
  final bool isSuccess;
  final String message;

  PaymentResult._(this.isSuccess, this.message);

  factory PaymentResult.success(String message) {
    return PaymentResult._(true, message);
  }

  factory PaymentResult.error(String message) {
    return PaymentResult._(false, message);
  }
}