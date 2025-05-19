// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      // Validate university email
      if (!isUniversityEmail(email)) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Please use your university email address to register.',
        );
      }

      // Create the user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user profile to Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'role': 'buyer', // Default role
        'dateCreated': FieldValue.serverTimestamp(),
        'universityName': _extractUniversityFromEmail(email),
      });

      // Update display name
      await result.user!.updateDisplayName(displayName);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Check if email is a university email
  bool isUniversityEmail(String email) {
    // Add your university domain validation logic here
    return email.endsWith('.edu.my') ||
        email.endsWith('.edu') ||
        email.contains('utm.my');
  }

  // Extract university name from email
  String _extractUniversityFromEmail(String email) {
    // Basic extraction logic - can be improved
    final domain = email.split('@').last;
    if (domain.contains('utm.my')) return 'UTM';
    // Add more universities as needed
    return domain.split('.').first.toUpperCase();
  }

  // Check if the current user's email is verified
  bool isEmailVerified() {
    User? user = _auth.currentUser;
    return user != null ? user.emailVerified : false;
  }

  // Send verification email to the user
  Future<void> sendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      rethrow;
    }
  }
}
