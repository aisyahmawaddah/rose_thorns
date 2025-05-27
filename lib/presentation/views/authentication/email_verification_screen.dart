import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/auth_service.dart'; // Import AuthService for university email validation

class EmailVerificationScreen extends StatefulWidget {
  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService =
      AuthService(); // Instance for university email validation
  late User _user;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!; // Get the currently logged-in user

    // Validate if the email is a valid university email before proceeding
    if (!_authService.isUniversityEmail(_user.email!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please use a valid university email address.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      _startVerificationCheck();
    }
  }

  // Start a periodic check to verify the email status
  void _startVerificationCheck() {
    _timer = Timer.periodic(Duration(seconds: 3), (_) async {
      await _checkEmailVerified();
    });
  }

  // Check if the email is verified
  Future<void> _checkEmailVerified() async {
    await _user.reload(); // Reload the user to get updated information
    _user = _auth.currentUser!;

    if (_user.emailVerified) {
      _timer.cancel(); // Stop checking once the email is verified
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email verified successfully!')),
      );
      await _auth.signOut(); // Sign out after verification
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  // Resend the email verification link
  Future<void> _resendVerificationEmail() async {
    try {
      await _user.sendEmailVerification();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification email resent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend verification email: $e')),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Your Email'),
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_unread,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 24.0),
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Text(
                'We\'ve sent a verification link to ${_user.email}.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Please check your inbox (and spam folder) and click the link to verify your account.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.0),
              Text(
                'After verification, you\'ll be redirected to the login screen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _resendVerificationEmail,
                child: Text('Resend Verification Email'),
              ),
              SizedBox(height: 16.0),
              // Button to sign out and go back to login
              TextButton(
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
