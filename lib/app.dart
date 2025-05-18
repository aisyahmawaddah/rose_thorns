import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/core/config/routes.dart';
import 'package:koopon/core/config/themes.dart';
import 'package:koopon/presentation/views/auth/login_screen.dart';
import 'package:koopon/presentation/views/authentication/welcome_screen.dart';
import 'package:koopon/presentation/views/splash_screen.dart';

class KooponApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koopon',
      theme: AppTheme.lightTheme,
      home: AuthWrapper(),
      routes: AppRoutes.routes,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show splash screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }

        // // If user is logged in, go to home screen
        // if (snapshot.hasData) {
        //   return AppRoutes.routes['/home']!(context);
        // }

        // Otherwise, go to login screen
        return WelcomeScreen();
      },
    );
  }
}
