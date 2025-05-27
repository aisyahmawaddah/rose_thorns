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
      throw e;
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
          message: 'Please use a valid university email address to register.',
        );
      }

      // Create the user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await sendVerificationEmail();

      // Wait for the user to verify their email before proceeding
      bool emailVerified = await waitForEmailVerification();
      if (!emailVerified) {
        throw FirebaseAuthException(
            code: 'email-not-verified',
            message: 'Please verify your email address.');
      }

      // Add user profile to Firestore after email verification
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
      throw e;
    }
  }

  // Wait for email verification
  Future<bool> waitForEmailVerification() async {
    while (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
      await Future.delayed(Duration(seconds: 3)); // Check every 3 seconds
      await _auth.currentUser!.reload(); // Reload user to update emailVerified
    }
    return _auth.currentUser!.emailVerified;
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
      throw e;
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
      throw e;
    }
  }
}
