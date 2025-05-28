import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/services/auth_service.dart'; // Import AuthService for validation

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService =
      AuthService(); // For university email validation

  bool _isLoading = false;
  String _errorMessage = '';
  bool _resetSent = false;

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _resetSent = false;
      });

      // Validate university email before proceeding
      if (!_authService.isUniversityEmail(_emailController.text.trim())) {
        setState(() {
          _errorMessage = 'Please use your university email address.';
          _isLoading = false;
        });
        return;
      }

      try {
        // Send password reset email
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );

        setState(() {
          _isLoading = false;
          _resetSent = true;
        });
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                // Reset Password header
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Description text
                const Padding(
                  padding: EdgeInsets.only(
                      left: 8.0, top: 8.0, right: 30.0, bottom: 10.0),
                  child: Text(
                    'Enter your university email address and we\'ll send you a link to reset your password.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      height: 1.4,
                    ),
                  ),
                ),

                // Lock reset icon
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Icon(
                      Icons.lock_reset,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Email field
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
                  ),
                ),

                // Error message display
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                // Success message display
                if (_resetSent) ...[
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      'Password reset email sent! Check your inbox and follow the instructions to reset your password.',
                      style: TextStyle(color: Colors.green[800]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 24.0),

                // Send Reset Link button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Text(
                            'Send Reset Link',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                  ),
                ),

                // Back to Login button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 40.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
