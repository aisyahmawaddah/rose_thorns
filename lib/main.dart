import 'package:flutter/material.dart';
import 'package:koopon/app.dart';
import 'package:koopon/data/services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before running the app
  try {
    await Firebase.initializeApp();
    await FirebaseService
        .initialize(); // Your custom Firebase initialization logic
    print("Firebase Initialized");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(KooponApp());
}
