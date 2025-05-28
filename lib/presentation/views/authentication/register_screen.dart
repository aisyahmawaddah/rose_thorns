import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/services/auth_service.dart'; // Import AuthService for validation
import 'email_verification_screen.dart'; // Import EmailVerificationScreen

class PigeonUserDetails {
  final String username;
  final String email;

  PigeonUserDetails({required this.username, required this.email});

  // Factory method to convert map to PigeonUserDetails
  factory PigeonUserDetails.fromMap(Map<String, dynamic> map) {
    return PigeonUserDetails(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();

  final AuthService _authService =
      AuthService(); // For university email validation

  bool _isLoading = false;
  String _errorMessage = '';

  // Register Method
  Future<void> _register() async {
    if (_passwordController.text == _confirmPasswordController.text) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final email = _emailController.text.trim();

      // Validate university email before proceeding
      if (!_authService.isUniversityEmail(email)) {
        setState(() {
          _errorMessage = 'Please use your university email address.';
          _isLoading = false;
        });
        return;
      }

      try {
        // Register user with email and password
        UserCredential result =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: _passwordController.text,
        );

        // Log that the user was created
        print("User created successfully: ${result.user!.email}");

        // Send email verification
        await result.user!.sendEmailVerification();

        // Log email verification sent
        print("Email verification sent to: ${result.user!.email}");

        setState(() {
          _isLoading = false;
          _errorMessage =
              "A verification email has been sent. Please verify your email address before continuing.";
        });

        // Navigate to email verification screen to let user know they need to verify their email
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(email: email),
          ),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        print("Error occurred during registration: $e");
      }
    } else {
      setState(() {
        _errorMessage = "Please make sure the passwords match.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          decoration: const BoxDecoration(
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              children: [
                const SizedBox(height: 10.0),
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                _buildTextField(_fullnameController, 'Fullname'),
                const SizedBox(height: 15.0),
                _buildTextField(_usernameController, 'Username'),
                const SizedBox(height: 15.0),
                _buildPasswordField(_passwordController, 'Password'),
                const SizedBox(height: 15.0),
                _buildPasswordField(
                    _confirmPasswordController, 'Confirm Password'),
                const SizedBox(height: 15.0),
                _buildTextField(_emailController, 'University Email',
                    isEmail: true),
                const SizedBox(height: 30.0),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 30.0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sign Up',
                            style: TextStyle(fontSize: 16.0)),
                  ),
                ),
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
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
      child: TextFormField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16.0),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16.0),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
