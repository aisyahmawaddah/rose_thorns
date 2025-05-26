import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/presentation/views/auth/password_reset_screen.dart';
import 'package:koopon/presentation/views/auth/register_screen.dart';
import 'package:koopon/presentation/widgets/custom_button.dart';
import 'package:koopon/presentation/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
        // Sign in the user with email and password
        UserCredential result = await _auth.signInWithEmailAndPassword(
            email: _email, password: _password);

        // Check if the email is verified
        if (!result.user!.emailVerified) {
          setState(() {
            _errorMessage =
                'Please verify your email before logging in. Check your inbox for the verification link.';
            _isLoading = false;
          });

          // Show dialog with option to resend verification email
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
                      // Resend verification email
                      await result.user!.sendEmailVerification();
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

          // Sign out after failed login attempt due to unverified email
          await _auth.signOut();
          return;
        }

        // If the email is verified, navigate to the home screen
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
