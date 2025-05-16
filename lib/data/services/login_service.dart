// login_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
    } catch (e) {
      throw e;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}