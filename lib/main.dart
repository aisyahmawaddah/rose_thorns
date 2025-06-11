import 'package:flutter/material.dart';
import 'package:koopon/app.dart';
import 'package:koopon/data/services/firebase_service.dart';
import 'package:koopon/core/config/supabase_config.dart'; // ADD THIS LINE

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Your existing Firebase initialization
  await FirebaseService.initialize();
  
  // Add Supabase initialization
  await SupabaseConfig.initialize();
  
  runApp(const KooponApp());
  
}