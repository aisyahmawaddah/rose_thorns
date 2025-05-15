import 'package:flutter/material.dart';
import 'package:koopon/presentation/views/auth/email_verification_screen.dart';
import 'package:koopon/presentation/views/auth/login_screen.dart';
import 'package:koopon/presentation/views/auth/register_screen.dart';
import 'package:koopon/presentation/views/auth/password_reset_screen.dart';
import 'package:koopon/presentation/views/profile/profile_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => LoginScreen(),
    '/register': (context) => RegisterScreen(),
    // In your routes configuration
'/email_verification': (context) => EmailVerificationScreen(),
    '/password_reset': (context) => PasswordResetScreen(),
    '/profile': (context) => ProfileScreen(),
    '/home': (context) => ProfileScreen(), // Temporary until you create a home screen
  };
}