// // lib/data/services/payment_service.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class PaymentService {
//   static const String _baseUrl = 'https://stripe-server-kappa.vercel.app';
  
//   void initialize(String publishableKey) {
//     Stripe.publishableKey = publishableKey;
//   }

//   Future<Map<String, dynamic>?> createPaymentIntent({
//     required double amount,
//     required String currency,
//   }) async {
//     try {
//       final amountInCents = (amount * 100).round();
      
//       final response = await http.post(
//         Uri.parse('$_baseUrl/create-payment-intent'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'amount': amountInCents,
//           'currency': currency.toLowerCase(),
//         }),
//       );

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         print('Failed to create payment intent: ${response.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       print('Error creating payment intent: $e');
//       return null;
//     }
//   }

//   Future<bool> initializePaymentSheet({
//     required String clientSecret,
//     required String merchantDisplayName,
//   }) async {
//     try {
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: clientSecret,
//           merchantDisplayName: merchantDisplayName,
//           style: ThemeMode.system,
//           appearance: PaymentSheetAppearance(
//             colors: PaymentSheetAppearanceColors(
//               primary: const Color(0xFF2196F3),
//             ),
//           ),
//         ),
//       );
//       return true;
//     } catch (e) {
//       print('Error initializing payment sheet: $e');
//       return false;
//     }
//   }

//   Future<bool> presentPaymentSheet() async {
//     try {
//       await Stripe.instance.presentPaymentSheet();
//       return true;
//     } catch (e) {
//       if (e is StripeException) {
//         if (e.error.code == FailureCode.Canceled) {
//           print('Payment canceled by user');
//         } else {
//           print('Stripe error: ${e.error.message}');
//         }
//       } else {
//         print('Error presenting payment sheet: $e');
//       }
//       return false;
//     }
//   }

//   Future<PaymentMethod?> createPaymentMethod({
//     required String cardNumber,
//     required int expMonth,
//     required int expYear,
//     required String cvc,
//   }) async {
//     try {
//       final paymentMethod = await Stripe.instance.createPaymentMethod(
//         params: PaymentMethodParams.card(
//           paymentMethodData: PaymentMethodData(
//             billingDetails: BillingDetails(),
//           ),
//         ),
//       );
//       return paymentMethod;
//     } catch (e) {
//       print('Error creating payment method: $e');
//       return null;
//     }
//   }

//   Future<bool> processPayment({
//     required String paymentMethodId,
//     required double amount,
//     required String currency,
//   }) async {
//     try {
//       // This would typically involve creating a payment intent on your backend
//       // and confirming it with the payment method
//       // For now, we'll simulate a successful payment
//       await Future.delayed(Duration(seconds: 2));
//       return true;
//     } catch (e) {
//       print('Error processing payment: $e');
//       return false;
//     }
//   }

//   // Complete payment flow using Payment Sheet (recommended)
//   Future<bool> processSimplePayment({
//     required double amount,
//     required String currency,
//     String merchantDisplayName = 'Koopon Marketplace',
//   }) async {
//     try {
//       // Step 1: Create payment intent
//       final paymentIntentData = await createPaymentIntent(
//         amount: amount,
//         currency: currency,
//       );

//       if (paymentIntentData == null) {
//         return false;
//       }

//       final clientSecret = paymentIntentData['client_secret'];
//       if (clientSecret == null) {
//         return false;
//       }

//       // Step 2: Initialize payment sheet
//       final initialized = await initializePaymentSheet(
//         clientSecret: clientSecret,
//         merchantDisplayName: merchantDisplayName,
//       );

//       if (!initialized) {
//         return false;
//       }

//       // Step 3: Present payment sheet
//       return await presentPaymentSheet();

//     } catch (e) {
//       print('Error processing payment: $e');
//       return false;
//     }
//   }
// }