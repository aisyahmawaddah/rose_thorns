import 'package:firebase_auth/firebase_auth.dart';

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Validate inputs before making the call
      if (email.isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Email and password cannot be empty',
        );
      }

      // Direct Firebase Auth call
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('Login service: User signed in successfully - ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Login service FirebaseAuth error: ${e.code} - ${e.message}');
      rethrow; // Let the repository handle the specific error codes
    } catch (e) {
      print('Login service unexpected error: ${e.toString()}');
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Email cannot be empty',
        );
      }
      
      await _auth.sendPasswordResetEmail(email: email.trim());
      print('Login service: Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      print('Login service reset password error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Login service reset password unexpected error: ${e.toString()}');
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('Login service: User signed out successfully');
    } catch (e) {
      print('Login service sign out error: ${e.toString()}');
      throw FirebaseAuthException(
        code: 'sign-out-failed',
        message: 'Failed to sign out: ${e.toString()}',
      );
    }
  }

  // Get current user
  User? get currentUser {
    final user = _auth.currentUser;
    print('Login service: Current user - ${user?.email ?? 'No user'}');
    return user;
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    final isLoggedIn = _auth.currentUser != null;
    print('Login service: User logged in - $isLoggedIn');
    return isLoggedIn;
  }

  // Get auth state stream for listening to auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user changes stream for listening to user property changes
  Stream<User?> get userChanges => _auth.userChanges();
}