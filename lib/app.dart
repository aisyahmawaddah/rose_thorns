import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:koopon/core/config/routes.dart';
import 'package:koopon/core/config/themes.dart';
import 'package:koopon/presentation/views/authentication/login_screen.dart';
import 'package:koopon/presentation/views/splash_screen.dart';
import 'package:koopon/presentation/views/home_screen.dart';
import 'package:koopon/presentation/views/admin/admin_screen.dart';
import 'package:koopon/presentation/viewmodels/home_viewmodel.dart';

class KooponApp extends StatelessWidget {
  const KooponApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel(), lazy: true),
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Sign out any existing user when app starts to force fresh login
    _signOutExistingUser();
  }

  Future<void> _signOutExistingUser() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      print('Error signing out existing user: $e');
    }
  }

  // NEW: Function to check user role and navigate accordingly
  Future<Widget> _getScreenBasedOnRole(User user) async {
    try {
      print('🔍 AuthWrapper: Checking role for user: ${user.email}');

      // Get user role from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final userRole = userData['role'] ?? 'buyer';

        print('🔍 AuthWrapper: User role found: $userRole');
        print('🔍 AuthWrapper: Complete user data: $userData');

        // Return appropriate screen based on role
        if (userRole == 'admin') {
          print('🔧 AuthWrapper: Returning AdminScreen for admin user');
          return const AdminScreen();
        } else {
          print('🏠 AuthWrapper: Returning HomeScreen for ${userRole} user');
          return const HomeScreen();
        }
      } else {
        print(
            '⚠️ AuthWrapper: No Firestore document found, defaulting to HomeScreen');
        // If no Firestore document, default to home screen
        return const HomeScreen();
      }
    } catch (e) {
      print('❌ AuthWrapper: Error checking user role: $e');
      // On error, default to home screen
      return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print(
            '🔄 AuthWrapper: Auth state changed - Connection: ${snapshot.connectionState}');

        // Show splash screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ AuthWrapper: Showing splash screen');
          return const SplashScreen();
        }

        // Handle errors
        if (snapshot.hasError) {
          print('❌ AuthWrapper: Error in auth stream: ${snapshot.error}');
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
        print('👤 AuthWrapper: Current user: ${user?.email ?? 'null'}');
        print(
            '✉️ AuthWrapper: Email verified: ${user?.emailVerified ?? 'N/A'}');
        print('📱 AuthWrapper: Has shown login: $_hasShownLoginScreen');

        // If user just logged in and email is verified, check role and navigate
        if (user != null && user.emailVerified && _hasShownLoginScreen) {
          print(
              '✅ AuthWrapper: User authenticated and verified, checking role...');

          return FutureBuilder<Widget>(
            future: _getScreenBasedOnRole(user),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                print('⏳ AuthWrapper: Checking user role...');
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading your dashboard...'),
                      ],
                    ),
                  ),
                );
              }

              if (roleSnapshot.hasError) {
                print(
                    '❌ AuthWrapper: Error getting role-based screen: ${roleSnapshot.error}');
                return const HomeScreen(); // Fallback to home screen
              }

              print('🎯 AuthWrapper: Displaying role-based screen');
              return roleSnapshot.data ?? const HomeScreen();
            },
          );
        }
        // If user is logged in but email not verified
        else if (user != null && !user.emailVerified && _hasShownLoginScreen) {
          print('📧 AuthWrapper: User needs email verification');
          // You can create an EmailVerificationScreen or redirect to login
          return const LoginScreen(); // Or EmailVerificationScreen
        }
        // Always show login screen first or if no user
        else {
          print('🔑 AuthWrapper: Showing login screen');
          _hasShownLoginScreen = true;
          return const LoginScreen();
        }
      },
    );
  }
}

// Email verification screen (if you want to use it)
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
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
                  'We sent a verification email to:\n${user?.email ?? 'your email'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Please check your email and click the verification link to continue.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _resendVerification(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3066BE),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Resend Verification Email'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _checkVerification(),
                  child: const Text(
                    'I\'ve verified my email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _logout(),
                  child: Text(
                    'Use different account',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
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
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resendVerification() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      setState(() {
        _message = 'Verification email sent successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error sending verification email: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkVerification() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user?.emailVerified == true) {
      // Email is now verified, AuthWrapper will handle navigation
      setState(() {});
    } else {
      setState(() {
        _message =
            'Email not yet verified. Please check your email and try again.';
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // AuthWrapper will handle navigation back to login
  }
}
