import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/services/auth_service.dart'; // Import AuthService for validation

class PasswordResetScreen extends StatefulWidget {
  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService =
      AuthService(); // Instance for university email validation

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
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24.0),
              Icon(
                Icons.lock_reset,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 24.0),
              Text(
                'Reset Your Password',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Text(
                'Enter your university email address and we\'ll send you a link to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 24.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'University Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) {
                  if (val!.isEmpty) return 'Enter your email';
                  if (!val.contains('@')) return 'Enter a valid email';
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
              if (_resetSent) ...[
                SizedBox(height: 16.0),
                Container(
                  padding: EdgeInsets.all(12),
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
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Send Reset Link'),
              ),
              SizedBox(height: 16.0),
              TextButton(
                child: Text('Back to Login'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
