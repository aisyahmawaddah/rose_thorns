import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koopon/data/services/auth_service.dart'; // Import AuthService for validation
import 'email_verification_screen.dart'; // Import the EmailVerificationScreen

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController(); // Added confirm password controller
  final _matricNumberController = TextEditingController();
  final _emailController = TextEditingController();

  final AuthService _authService =
      AuthService(); // Instance for university email validation

  bool _isLoading = false;
  String _errorMessage = '';

  bool _isUniversityEmail(String email) {
    return email.endsWith('.edu.my') ||
        email.endsWith('.edu') ||
        email.contains('utm.my');
  }

  // Register Method
  Future<void> _register() async {
    if (_isUniversityEmail(_emailController.text.trim()) &&
        _passwordController.text == _confirmPasswordController.text) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final email = _emailController.text.trim();

        // Register user with email and password
        UserCredential result =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: _passwordController.text,
        );

        // Send email verification
        await result.user!.sendEmailVerification();

        // Save user profile to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(result.user!.uid)
            .set({
          'displayName': _fullnameController.text.trim(),
          'email': email,
          'role': 'buyer', // Default role
          'dateCreated': FieldValue.serverTimestamp(),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Registration successful! Please check your email to verify your account.'),
            duration: Duration(seconds: 8),
          ),
        );

        // After successful registration, navigate to EmailVerificationScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EmailVerificationScreen()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage =
            "Please make sure the email is valid and passwords match.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7EB8EC), // Light blue at top
              Color(0xFFD5B5E2), // Light purple at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 16.0),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  children: [
                    SizedBox(height: 10.0),
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      '"Your Campus Marketplace: Where One Student\'s Old Is Another\'s New"',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 30.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: TextField(
                        controller: _fullnameController,
                        decoration: InputDecoration(
                          hintText: 'Fullname',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 16.0),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 16.0),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 16.0),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 16.0),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'University Email',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 16.0),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 30.0),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Sign Up', style: TextStyle(fontSize: 16.0)),
                      ),
                    ),
                    if (_errorMessage.isNotEmpty) ...[
                      SizedBox(height: 16.0),
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
