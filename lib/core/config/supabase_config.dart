import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://fhxrqrbgxecqktmuwpez.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZoeHJxcmJneGVjcWt0bXV3cGV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyMzM4NTcsImV4cCI6MjA2MzgwOTg1N30.Kl_HU7GqGsO9WJQD1ncT9DJaK3EY8NoVhophDuId2oU';
  
  static bool _initialized = false;
  
  static SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase must be initialized before accessing client. Call SupabaseConfig.initialize() first.');
    }
    return Supabase.instance.client;
  }
  
  static Future<void> initialize() async {
    if (_initialized) {
      print('Supabase already initialized');
      return;
    }
    
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _initialized = true;
      print('Supabase initialized successfully');
    } catch (e) {
      print('Error initializing Supabase: $e');
      rethrow;
    }
  }
  
  static bool get isInitialized => _initialized;
}