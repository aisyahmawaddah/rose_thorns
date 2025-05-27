import 'package:flutter/material.dart';
import 'package:koopon/presentation/views/authentication/email_verification_screen.dart';
import 'package:koopon/presentation/views/authentication/login_screen.dart';
import 'package:koopon/presentation/views/authentication/register_screen.dart';
import 'package:koopon/presentation/views/authentication/password_reset_screen.dart';
import 'package:koopon/presentation/views/profile/profile_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => LoginPageScreen(), // Login page
    '/register': (context) => RegisterScreen(), // Register page
    '/email_verification': (context) => EmailVerificationScreen(
          email: '',
        ), // Email verification page
    '/password_reset': (context) =>
        PasswordResetScreen(), // Password reset page
    '/profile': (context) => ProfileScreen(), // Profile page
    '/home': (context) =>
        ProfileScreen(), // Temporary home screen while you're working on it
  };

  // Example of navigation helper to push routes dynamically
  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/register');
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/profile');
  }

  static void navigateToPasswordReset(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/password_reset');
  }

  static void navigateToEmailVerification(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/email_verification');
  }
}
