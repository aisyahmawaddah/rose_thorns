import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // ADD THIS LINE
import 'package:koopon/core/config/routes.dart';
import 'package:koopon/core/config/themes.dart';
import 'package:koopon/presentation/views/authentication/login_screen.dart';
import 'package:koopon/presentation/views/splash_screen.dart';
import 'package:koopon/presentation/views/home_screen.dart';
import 'package:koopon/presentation/viewmodels/cart_viewmodel.dart'; 
import 'package:koopon/presentation/viewmodels/home_viewmodel.dart';

class KooponApp extends StatelessWidget {
  const KooponApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ADD MultiProvider here to wrap MaterialApp
    return MultiProvider(
      providers: [
        // ADD THESE PROVIDERS:
        ChangeNotifierProvider(create: (_) => HomeViewModel(), lazy: true),
        ChangeNotifierProvider(create: (_) => CartViewModel(), lazy: true),
        
        // Add any other providers you have here...
      ],
      child: MaterialApp(
        title: 'Koopon',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        routes: AppRoutes.routes,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasShownLoginScreen = false;

  @override
  void initState() {
    super.initState();
    
    // REMOVED: Don't sign out users on app start anymore
    // This allows Firebase Auth to persist login state
    // _signOutExistingUser(); // REMOVE THIS LINE
    
    // ADD: Initialize CartViewModel auth listener when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
      cartViewModel.listenToAuthChanges();
    });
  }

  // REMOVED: _signOutExistingUser method since we don't need it anymore

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show splash screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // Handle errors
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Force rebuild
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final User? user = snapshot.data;
        
        // If user is logged in and email is verified, go to home
        if (user != null && user.emailVerified) {
          // Initialize cart when user successfully logs in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
            if (!cartViewModel.isInitialized) {
              cartViewModel.initializeCart();
            }
          });
          
          final routeBuilder = AppRoutes.routes['/home'] ?? AppRoutes.routes['/profile'];
          if (routeBuilder != null) {
            return routeBuilder(context);
          } else {
            return const HomeScreen();
          }
        } 
        // If user is logged in but email not verified
        else if (user != null && !user.emailVerified) {
          return const EmailVerificationScreen();
        } 
        // No user logged in - show login screen
        else {
          return const LoginScreen();
        }
      },
    );
  }
}

// Email verification screen remains the same as before...
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  String _message = '';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3066BE),
              Color(0xFFFFC2E2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_unread,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We sent a verification email to:\n${user?.email ?? "your email"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please check your email and click the verification link to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Resend verification email button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resendVerificationEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3066BE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Resend Verification Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Check verification status button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _checkEmailVerification,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'I\'ve Verified My Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Sign out button
                TextButton(
                  onPressed: _signOut,
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                
                // Message display
                if (_message.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      setState(() {
        _message = 'Verification email sent! Please check your inbox.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error sending email: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkEmailVerification() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user?.emailVerified == true) {
        setState(() {
          _message = 'Email verified successfully!';
        });
      } else {
        setState(() {
          _message = 'Email not yet verified. Please check your email.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error checking verification: ${e.toString()}';
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      
      // ADDED: Reset cart when user signs out
      if (mounted) {
        final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
        cartViewModel.resetCart();
      }
    } catch (e) {
      setState(() {
        _message = 'Error signing out: ${e.toString()}';
      });
    }
  }
}