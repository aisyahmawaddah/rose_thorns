import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!; // Get the currently logged-in user
    _startVerificationCheck();
  }

  // Start a periodic check to verify the email status
  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkEmailVerified();
    });
  }

  // Check if the email is verified
  Future<void> _checkEmailVerified() async {
    await _user.reload(); // Reload the user to get updated information
    _user = _auth.currentUser!;

    if (_user.emailVerified) {
      _timer.cancel(); // Stop checking once the email is verified
      await _saveUserData(); // Save the user data to Firestore after verification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified successfully!')),
      );
      await _auth.signOut(); // Sign out after verification
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  // Save user data to Firestore after email verification
  Future<void> _saveUserData() async {
    try {
      final user = _auth.currentUser!;
      final displayName =
          widget.email.split('@')[0]; // Use email as displayName for now

      // Save user details to Firestore after email verification
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': displayName,
        'role': 'buyer', // Default role
        'dateCreated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save user data: $e')),
      );
    }
  }

  // Resend the email verification link
  Future<void> _resendVerificationEmail() async {
    try {
      await _user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email resent!')),
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
        title: const Text('Verify Your Email'),
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
              const SizedBox(height: 24.0),
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Text(
                'We\'ve sent a verification link to ${widget.email}.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Please check your inbox (and spam folder) and click the link to verify your account.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              const Text(
                'After verification, you\'ll be redirected to the login screen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _resendVerificationEmail,
                child: const Text('Resend Verification Email'),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
