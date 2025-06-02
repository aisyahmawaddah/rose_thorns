import 'package:flutter/material.dart';
import 'package:koopon/presentation/views/authentication/email_verification_screen.dart';
import 'package:koopon/presentation/views/authentication/login_screen.dart';
import 'package:koopon/presentation/views/authentication/register_screen.dart';
import 'package:koopon/presentation/views/authentication/password_reset_screen.dart';
import 'package:koopon/presentation/views/home_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => LoginScreen(),
    '/register': (context) => RegisterScreen(),
    // In your routes configuration
    '/email_verification': (context) => EmailVerificationScreen(),
    '/password_reset': (context) => PasswordResetScreen(),
    '/profile': (context) => ProfileScreen(),
    // '/home': (context) =>
    //     ProfileScreen(), // Temporary until you create a home screen
  };
}
