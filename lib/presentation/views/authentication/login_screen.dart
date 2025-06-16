import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koopon/data/repositories/login_repository.dart';
import 'package:koopon/data/models/login_model.dart';
import 'package:koopon/presentation/views/authentication/register_screen.dart';
import 'package:koopon/presentation/views/authentication/password_reset_screen.dart';
import 'package:koopon/presentation/views/authentication/welcome_screen.dart';
import 'package:koopon/presentation/views/home_screen.dart';
import 'package:koopon/presentation/views/admin/admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginRepository _loginRepository = LoginRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginModel _loginModel = const LoginModel(email: '', password: '');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    print('=== STARTING LOGIN PROCESS ===');
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      if (!mounted) return;
      setState(() {
        _loginModel = _loginModel.copyWith(
          isLoading: true,
          errorMessage: null,
        );
      });

      try {
        print(
            'Attempting to sign in with email: ${_emailController.text.trim()}');

        // Sign in with email and password
        final userCredential = await _loginRepository.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        print('Firebase Auth successful: ${userCredential.user?.email}');

        // Check if email is verified
        if (userCredential.user != null &&
            !userCredential.user!.emailVerified) {
          print('Email not verified for user: ${userCredential.user!.email}');
          // Show error and don't proceed
          if (!mounted) return;
          setState(() {
            _loginModel = _loginModel.copyWith(
              errorMessage:
                  'Please verify your email before logging in. Check your inbox for the verification link.',
              isLoading: false,
            );
          });

          // Show dialog with option to resend
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Email Not Verified'),
              content: const Text(
                  'You need to verify your email before logging in. Would you like us to send another verification email?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await userCredential.user!.sendEmailVerification();
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification email sent!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error sending email: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Resend'),
                ),
              ],
            ),
          );
          return;
        }

        // Email is verified, now check user role
        if (userCredential.user != null && userCredential.user!.emailVerified) {
          print('Email verified, checking user role in Firestore...');

          // Get user role from Firestore
          final userDoc = await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

          print('Firestore document exists: ${userDoc.exists}');

          if (!mounted) return;

          String userRole = 'buyer'; // Default role
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            userRole = userData['role'] ?? 'buyer';
            print('User role from Firestore: $userRole');
            print('Complete user data: $userData');
          } else {
            print(
                'No Firestore document found for user, using default role: buyer');
          }

          // Navigate based on user role
          if (!mounted) return;
          setState(() {
            _loginModel = _loginModel.copyWith(isLoading: false);
          });

          print('=== NAVIGATION DECISION ===');
          print('User role: $userRole');
          print('User email: ${userCredential.user!.email}');

          if (userRole == 'admin') {
            print('🔧 REDIRECTING TO ADMIN SCREEN');
            // Navigate to admin screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminScreen(),
              ),
            );
          } else {
            print('🏠 REDIRECTING TO HOME SCREEN (buyer/seller)');
            // Navigate to regular user home screen (buyer/seller)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        print('Firebase Auth Exception: ${e.code} - ${e.message}');
        if (!mounted) return;

        String errorMessage = 'Login failed. Please try again.';

        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No account found with this email address.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address format.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many failed attempts. Please try again later.';
            break;
          case 'invalid-credential':
            errorMessage =
                'Invalid email or password. Please check your credentials.';
            break;
          default:
            errorMessage = e.message ?? 'Login failed. Please try again.';
        }

        setState(() {
          _loginModel = _loginModel.copyWith(
            errorMessage: errorMessage,
            isLoading: false,
          );
        });
      } catch (e) {
        print('General Exception during login: $e');
        if (!mounted) return;
        setState(() {
          _loginModel = _loginModel.copyWith(
            errorMessage: 'An unexpected error occurred: ${e.toString()}',
            isLoading: false,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Allow the screen to resize when keyboard appears
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3066BE), // Top blue color
                Color(0xFFFFC2E2), // Bottom pink color
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              // Using ListView for better scrolling
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                // Top navigation bar
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sign In header
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Description text
                const Padding(
                  padding: EdgeInsets.only(
                      left: 8.0, top: 8.0, right: 30.0, bottom: 0.0),
                  child: Text(
                    'This is your student-friendly corner of the internet. Sign in to reconnect with your favorites, discover new preloved gems.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      height: 1.4,
                    ),
                  ),
                ),

                // Shopping cart image
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Center(
                    child: Image.asset(
                      'images/shopping_cart.png', // Your shopping cart image path
                      height: screenHeight * 0.25,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback widget if image fails to load
                        return SizedBox(
                          height: screenHeight * 0.25,
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.purple.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.shopping_cart,
                                size: 50,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Email field with validation
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'University Email',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      // Clear errors when user starts typing
                      if (_loginModel.errorMessage != null) {
                        setState(() {
                          _loginModel =
                              _loginModel.copyWith(errorMessage: null);
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16.0),

                // Password field with validation
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      // Clear errors when user starts typing
                      if (_loginModel.errorMessage != null) {
                        setState(() {
                          _loginModel =
                              _loginModel.copyWith(errorMessage: null);
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16.0),

                // Error message
                if (_loginModel.errorMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[700],
                          size: 20.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _loginModel.errorMessage!,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                ],

                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PasswordResetScreen()),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.0,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5.0),

                // Sign In button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: _loginModel.isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: _loginModel.isLoading
                          ? Colors.grey[600]
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      elevation: _loginModel.isLoading ? 0 : 2,
                    ),
                    child: _loginModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                    TextButton(
                      child: const Text(
                        'Register Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
