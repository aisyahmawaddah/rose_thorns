// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:koopon/presentation/viewmodels/admin_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:koopon/core/config/app_config.dart';
import 'package:koopon/app.dart'; // Import your app.dart file
import 'package:koopon/presentation/viewmodels/home_viewmodel.dart';
import 'package:koopon/presentation/viewmodels/cart_viewmodel.dart';
import 'package:koopon/presentation/viewmodels/order_request_viewmodel.dart';
import 'package:koopon/presentation/viewmodels/order_history_viewmodel.dart';
import 'package:koopon/presentation/viewmodels/address_viewmodel.dart';
import 'package:koopon/presentation/viewmodels/seller_order_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase first
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _stripeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeStripe();
  }

  Future<void> _initializeStripe() async {
    try {
      Stripe.publishableKey = AppConfig.stripePublishableKey;
      Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
      await Stripe.instance.applySettings();

      setState(() {
        _stripeInitialized = true;
      });

      print('✅ Stripe initialized successfully');
    } catch (e) {
      print('❌ Stripe initialization failed: $e');
      setState(() {
        _stripeInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => OrderRequestViewModel()),
        ChangeNotifierProvider(create: (_) => OrderHistoryViewModel()),
        ChangeNotifierProvider(create: (_) => AddressViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        // Add other providers as needed
      ],
      child: MaterialApp(
        title: 'Koopon',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // ✅ Use AuthWrapper instead of direct HomeScreen
        home: _stripeInitialized
            ? const AuthWrapper() // This will handle auth logic
            : const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Initializing Koopon...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
