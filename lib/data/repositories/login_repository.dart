import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/services/auth_service.dart';

class LoginRepository {
  final AuthService _authService;

  LoginRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<UserCredential> login(String email, String password) async {
    try {
      // Validate inputs
      if (email.trim().isEmpty) {
        throw Exception('Email cannot be empty');
      }
      if (password.trim().isEmpty) {
        throw Exception('Password cannot be empty');
      }

      return await _authService.signInWithEmailAndPassword(
        email.trim(), 
        password.trim()
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'invalid-email-domain':
          throw Exception(e.message ?? 'Invalid email domain');
        case 'user-not-found':
          throw Exception('No user found with this email address.');
        case 'wrong-password':
          throw Exception('Incorrect password. Please try again.');
        case 'invalid-email':
          throw Exception('Invalid email address format.');
        case 'user-disabled':
          throw Exception('This account has been disabled.');
        case 'too-many-requests':
          throw Exception('Too many failed attempts. Please try again later.');
        case 'network-request-failed':
          throw Exception('Network error. Please check your connection.');
        default:
          throw Exception('Login failed: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      // Handle other types of errors
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('An unexpected error occurred: ${e.toString()}');
      }
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        throw Exception('Email cannot be empty');
      }
      await _authService.resetPassword(email.trim());
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email-domain':
          throw Exception(e.message ?? 'Invalid email domain');
        case 'user-not-found':
          throw Exception('No user found with this email address.');
        case 'invalid-email':
          throw Exception('Invalid email address format.');
        default:
          throw Exception('Password reset failed: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('An unexpected error occurred: ${e.toString()}');
      }
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  User? get currentUser => _authService.currentUser;

  bool isUserLoggedIn() {
    return _authService.currentUser != null;
  }
}