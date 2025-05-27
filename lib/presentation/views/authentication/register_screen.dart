import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_verification_screen.dart'; // Import EmailVerificationScreen here

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  // Register Method
  Future<void> _register() async {
    if (_passwordController.text == _confirmPasswordController.text) {
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

        // Wait for email verification before proceeding
        bool emailVerified = await waitForEmailVerification();

        if (!emailVerified) {
          setState(() {
            _errorMessage = "Please verify your email address first.";
            _isLoading = false;
          });
          return;
        }

        // Navigate to EmailVerificationScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(email: email)),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = "Please make sure the passwords match.";
      });
    }
  }

  // Wait for email verification
  Future<bool> waitForEmailVerification() async {
    while (FirebaseAuth.instance.currentUser != null &&
        !FirebaseAuth.instance.currentUser!.emailVerified) {
      await Future.delayed(Duration(seconds: 3)); // Check every 3 seconds
      await FirebaseAuth.instance.currentUser!
          .reload(); // Reload user to update emailVerified
    }
    return FirebaseAuth.instance.currentUser!.emailVerified;
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
                    _buildTextField(_fullnameController, 'Fullname'),
                    SizedBox(height: 15.0),
                    _buildTextField(_usernameController, 'Username'),
                    SizedBox(height: 15.0),
                    _buildPasswordField(_passwordController, 'Password'),
                    SizedBox(height: 15.0),
                    _buildPasswordField(
                        _confirmPasswordController, 'Confirm Password'),
                    SizedBox(height: 15.0),
                    _buildTextField(_emailController, 'University Email',
                        isEmail: true),
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

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool isEmail = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 16.0),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 16.0),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
