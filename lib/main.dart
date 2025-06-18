// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:koopon/presentation/viewmodels/admin_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:koopon/core/config/app_config.dart';
import 'package:koopon/core/config/supabase_config.dart'; // Add this import
import 'package:koopon/app.dart'; // Import your app.dart file
import 'package:koopon/presentation/viewmodels/home_viewmodel.dart';
import 'package:koopon/presentation/viewmodels/cart_viewmodel.dart';
import 'package:koopon/presentation/viewmodels/order_request_viewmodel.dart';
import 'package:koopon/presentation/viewmodels/purchase_history_viewmodel.dart'; // UPDATED: For buyers
import 'package:koopon/presentation/viewmodels/order_history_viewmodel.dart'; // UPDATED: For sellers
import 'package:koopon/presentation/viewmodels/address_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase first
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
    
    // Initialize Supabase
    await SupabaseConfig.initialize();
    print('✅ Supabase initialized successfully');
    
    // ADDED: Initialize Stripe in main() to prevent CardField errors
    await _initializeStripe();
    print('✅ Stripe initialized successfully');
    
  } catch (e) {
    print('❌ Initialization failed: $e');
  }

  runApp(MyApp());
}

// ADDED: Stripe initialization function (moved from MyApp class)
Future<void> _initializeStripe() async {
  try {
    Stripe.publishableKey = AppConfig.stripePublishableKey;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    await Stripe.instance.applySettings();
    print('🔧 Stripe settings applied successfully');
  } catch (e) {
    print('❌ Stripe initialization failed: $e');
    // Don't rethrow - allow app to continue even if Stripe fails
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _stripeInitialized = true; // CHANGED: Set to true since Stripe is initialized in main()

  @override
  void initState() {
    super.initState();
    // REMOVED: _initializeStripe() call since it's now done in main()
  }

// <<<<<<< HEAD
//   Future<void> _initializeStripe() async {
//     try {
//       Stripe.publishableKey = AppConfig.stripePublishableKey;
//       Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
//       await Stripe.instance.applySettings();

//       setState(() {
//         _stripeInitialized = true;
//       });

//       print('✅ Stripe initialized successfully');
//     } catch (e) {
//       print('❌ Stripe initialization failed: $e');
//       setState(() {
//         _stripeInitialized = true;
//       });
//     }
//   }
// =======
//   // REMOVED: _initializeStripe() method since it's now a top-level function
// >>>>>>> af529623f2e2ccf11ee885748501c8674520d4eb

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => OrderRequestViewModel()),
        ChangeNotifierProvider(create: (_) => PurchaseHistoryViewModel()), // UPDATED: For buyers (purchase history)
        ChangeNotifierProvider(create: (_) => OrderHistoryViewModel()), // UPDATED: For sellers (order history)
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
    return Scaffold(
      backgroundColor: Colors.blue,
      body: const Center(
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
