// lib/data/services/stripe_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();
  
  // Add your Stripe secret key here (keep it secure!)
  static const String stripeSecretKey = "sk_test_51RbLKZQ7pm5NWh7m33PtDA4xhqIPJwSG3r3quojV3k156SRlx7cPs7gHrzU1102yeqDmjy9rQuY0uc1sEbcsiLdm007a1ys9po"; // Replace with your actual secret key

  Future<bool> makePayment(double amount, String currency) async {
    try {
      print('🔄 Starting payment for ${currency.toUpperCase()} ${amount.toStringAsFixed(2)}');
      
      String? paymentIntentClientSecret = await _createPaymentIntent(amount, currency);
      if (paymentIntentClientSecret == null) {
        print('❌ Failed to create payment intent');
        return false;
      }
      
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Koopon",
          style: ThemeMode.light,
        ),
      );
      
      return await _processPayment();
    } catch (e) {
      print('❌ Payment error: $e');
      return false;
    }
  }

  Future<String?> _createPaymentIntent(double amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency.toLowerCase(),
      };
      
      print('📡 Creating payment intent with amount: ${_calculateAmount(amount)}');
      
      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents", 
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": 'application/x-www-form-urlencoded'
          },
        ),
      );
      
      if (response.data != null) {
        print('✅ Payment intent created successfully');
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      print('❌ Error creating payment intent: $e');
      return null;
    }
  }

  Future<bool> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      print('✅ Payment completed successfully');
      return true;
    } catch (e) {
      if (e is StripeException) {
        if (e.error.code == FailureCode.Canceled) {
          print('⚠️ Payment was canceled by user');
        } else {
          print('❌ Stripe error: ${e.error.message}');
        }
      } else {
        print('❌ Payment processing error: $e');
      }
      return false;
    }
  }

  String _calculateAmount(double amount) {
    final calculatedAmount = (amount * 100).round();
    return calculatedAmount.toString();
  }
}