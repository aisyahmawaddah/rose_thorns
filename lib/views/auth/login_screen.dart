import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koopon/services/auth_service.dart';
import 'package:koopon/views/auth/register_screen.dart';
import 'package:koopon/views/auth/password_reset_screen.dart';
import 'package:koopon/widgets/custom_button.dart';
import 'package:koopon/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // Sign in with email and password
        await _authService.signInWithEmailAndPassword(_email, _password);

        // Check if email is verified
        if (_authService.currentUser != null &&
            !_authService.currentUser!.emailVerified) {
          // Show error and don't proceed
          setState(() {
            _errorMessage =
                'Please verify your email before logging in. Check your inbox for the verification link.';
            _isLoading = false;
          });

          // Show dialog with option to resend
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Email Not Verified'),
              content: Text(
                  'You need to verify your email before logging in. Would you like us to send another verification email?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await _authService.currentUser!.sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Verification email sent again. Please check your inbox.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Error sending email: ${e.toString()}')),
                      );
                    }
                  },
                  child: Text('Resend Email'),
                ),
              ],
            ),
          );

          // Sign out since they shouldn't be logged in yet
          await _authService.signOut();
          return;
        }

        // If verified, proceed to home
        Navigator.pushReplacementNamed(context, '/home');
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
        title: Text('Login to Koopon'),
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
                'Welcome Back!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.0),
              CustomTextField(
                labelText: 'University Email',
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) => setState(() => _email = val),
              ),
              SizedBox(height: 16.0),
              CustomTextField(
                labelText: 'Password',
                obscureText: true,
                validator: (val) =>
                    val!.length < 6 ? 'Password must be 6+ chars' : null,
                onChanged: (val) => setState(() => _password = val),
              ),
              SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text('Forgot Password?'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PasswordResetScreen()),
                    );
                  },
                ),
              ),
              if (_errorMessage.isNotEmpty) ...[
                SizedBox(height: 8.0),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 24.0),
              CustomButton(
                text: 'Sign In',
                isLoading: _isLoading,
                onPressed: _signIn,
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    child: Text('Register Now'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterScreen()),
                      );
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
