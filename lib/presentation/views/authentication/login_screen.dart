// login_screen.dart - Updated with ViewModel integration
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koopon/presentation/viewmodels/login_viewmodel.dart';
import 'package:koopon/presentation/views/authentication/password_reset_screen.dart';
import 'package:koopon/presentation/views/home_screen.dart'; // Import the ItemListPage

class LoginPageScreen extends StatefulWidget {
  const LoginPageScreen({super.key});

  @override
  _LoginPageScreenState createState() => _LoginPageScreenState();
}

class _LoginPageScreenState extends State<LoginPageScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenHeight = MediaQuery.of(context).size.height;

    // Use ChangeNotifierProvider to provide LoginViewModel to this widget and its descendants
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            // Allow the screen to resize when keyboard appears
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
                    // Using ListView for better scrolling
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      // Top navigation bar
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),

                      // Sign In header
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, top: 8.0),
                        child: Text(
                          'Sign In',
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
                          'This is your student-friendly corner of the internet. Sign in to reconnect with your favorites, discover new preloved gems.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            height: 1.4,
                          ),
                        ),
                      ),

                      // Shopping cart image
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Center(
                          child: Image.asset(
                            'images/shopping_cart.png', // Make sure this path matches your assets
                            height: screenHeight * 0.25,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Email field with validation and viewmodel integration
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
                            hintText: 'University Emails',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16.0,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 15.0),
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
                          onChanged: (value) {
                            viewModel.updateEmail(value);
                          },
                        ),
                      ),

                      const SizedBox(height: 16.0),

                      // Password field with validation and viewmodel integration
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBEBEB),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16.0,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            viewModel.updatePassword(value);
                          },
                        ),
                      ),

                      // Error message from viewmodel
                      if (viewModel.state.errorMessage != null) ...[
                        const SizedBox(height: 8.0),
                        Text(
                          viewModel.state.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      // Forgot Password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PasswordResetScreen()),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8.0),

                      // Sign In button with viewmodel login implementation
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 80.0),
                        child: ElevatedButton(
                          onPressed: viewModel.state.isLoading
                              ? null
                              : () async {
                                  // Hide keyboard
                                  FocusScope.of(context).unfocus();

                                  // Validate form
                                  if (_formKey.currentState!.validate()) {
                                    // Perform login
                                    final success = await viewModel.login(
                                        _emailController.text,
                                        _passwordController.text);

                                    if (success && mounted) {
                                      // Navigate to home screen (ItemListPage)
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ItemListPage()),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          child: viewModel.state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
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
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
