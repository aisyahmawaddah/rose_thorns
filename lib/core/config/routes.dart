import 'package:flutter/material.dart';
import 'package:koopon/presentation/views/home_screen.dart';
import 'package:koopon/presentation/views/authentication/login_screen.dart';
import 'package:koopon/presentation/views/authentication/register_screen.dart';
import 'package:koopon/presentation/views/authentication/welcome_screen.dart';
// Add other imports as needed

class AppRoutes {
  static const String home = '/home';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';
  static const String welcome = '/welcome';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    profile: (context) => const HomeScreen(), // Or ProfileScreen if you have one
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    welcome: (context) => const WelcomeScreen(),
    // Add other routes as needed
  };

  // Helper method for safe navigation
  static void navigateTo(BuildContext context, String routeName) {
    if (routes.containsKey(routeName)) {
      Navigator.pushNamed(context, routeName);
    } else {
      // Fallback or error handling
      print('Route $routeName not found');
    }
  }

  // Helper method for safe replacement navigation
  static void navigateAndReplace(BuildContext context, String routeName) {
    if (routes.containsKey(routeName)) {
      Navigator.pushReplacementNamed(context, routeName);
    } else {
      print('Route $routeName not found');
    }
  }
}