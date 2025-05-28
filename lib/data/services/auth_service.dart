import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of allowed university domains
  final List<String> allowedDomains = [
    'utm.my',
    'edu.my',
    'edu',
    // Add more domains as needed
  ];

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

  // Simple register with email and password (without waiting for verification)
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      // Validate university email
      if (!isUniversityEmail(email)) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Please use a valid university email address to register.',
        );
      }

      // Create the user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification (but don't wait for it)
      await sendVerificationEmail();

      // Update display name immediately
      await result.user!.updateDisplayName(displayName);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Save user data to Firestore after email verification (call this from EmailVerificationScreen)
  Future<void> saveUserDataAfterVerification(
      String email, String displayName) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'displayName': displayName,
          'role': 'buyer', // Default role
          'dateCreated': FieldValue.serverTimestamp(),
          'universityName': _extractUniversityFromEmail(email),
        });
      }
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
    return allowedDomains.any((domain) => email.endsWith(domain));
  }

  // Extract university name from email
  String _extractUniversityFromEmail(String email) {
    final domain = email.split('@').last;
    if (domain.contains('utm.my')) return 'UTM';
    return domain.split('.').first.toUpperCase();
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

  // Resend the verification email
  Future<void> resendVerificationEmail() async {
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
