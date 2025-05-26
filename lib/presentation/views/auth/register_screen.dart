import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koopon/data/services/auth_service.dart'; // Import AuthService for validation

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService =
      AuthService(); // Instance for university email validation

  bool _isLoading = false;
  String _errorMessage = '';

  bool _isUniversityEmail(String email) {
    // Add your university domain validation logic here
    return email.endsWith('.edu.my') ||
        email.endsWith('.edu') ||
        email.contains('utm.my');
  }

  String _extractUniversityFromEmail(String email) {
    // Basic extraction logic - can be improved
    final domain = email.split('@').last;
    if (domain.contains('utm.my')) return 'UTM';
    // Add more universities as needed
    return domain.split('.').first.toUpperCase();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // Check if email is a university email
        final email = _emailController.text.trim();
        if (!_isUniversityEmail(email)) {
          throw Exception('Please use a university email address');
        }

        // Check if passwords match
        if (_passwordController.text != _confirmPasswordController.text) {
          throw Exception('Passwords do not match');
        }

        // Create user in Firebase Auth
        UserCredential result =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: _passwordController.text,
        );

        // Add user profile to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(result.user!.uid)
            .set({
          'displayName': _nameController.text.trim(),
          'email': email,
          'role': 'buyer', // Default role
          'dateCreated': FieldValue.serverTimestamp(),
          'universityName': _extractUniversityFromEmail(email),
        });

        // Update display name
        await result.user!.updateDisplayName(_nameController.text.trim());

        // Send verification email
        await result.user!.sendEmailVerification();

        // Sign out the user so they need to log in after verification
        await FirebaseAuth.instance.signOut();

        // Show success message and navigate back to login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Registration successful! Please check your email and verify your account before logging in.'),
            duration: Duration(seconds: 8),
          ),
        );

        // Navigate back to login
        Navigator.pop(context);
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
      appBar: AppBar(
        title: Text('Register for Koopon'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24.0),
              Text(
                'Create an Account',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val!.isEmpty ? 'Enter your name' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'University Email',
                  prefixIcon: Icon(Icons.email),
                  hintText: 'example@utm.my',
                ),
                validator: (val) {
                  if (val!.isEmpty) return 'Enter an email';
                  if (!val.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (val) =>
                    val!.length < 6 ? 'Password must be 6+ chars' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (val) {
                  if (val!.isEmpty) return 'Please confirm your password';
                  if (val != _passwordController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),
              if (_errorMessage.isNotEmpty) ...[
                SizedBox(height: 16.0),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Create Account'),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(
                    child: Text('Login Instead'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
