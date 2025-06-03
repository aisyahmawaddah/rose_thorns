// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Validate UTM Graduate email
      if (!isUTMGraduateEmail(email)) {
        throw FirebaseAuthException(
          code: 'invalid-email-domain',
          message: 'Only @graduate.utm.my email addresses are allowed.',
        );
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      
      // Ensure user document exists after successful login
      await ensureUserDocument(result.user!);
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  bool isUniversityEmail(String email) {
    // Example: check if email ends with '.edu'
    return email.toLowerCase().endsWith('.edu');
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      // Validate UTM Graduate email
      if (!isUTMGraduateEmail(email)) {
        throw FirebaseAuthException(
          code: 'invalid-email-domain',
          message: 'Only @graduate.utm.my email addresses are allowed for registration.',
        );
      }

      // Create the user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name in Firebase Auth
      await result.user!.updateDisplayName(displayName);

      // Send email verification
      await result.user!.sendEmailVerification();

      // Create user document in Firestore
      await createUserDocument(
        user: result.user!,
        displayName: displayName,
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Create user document in Firestore
  Future<void> createUserDocument({
    required User user,
    String? displayName,
    String? profileImageUrl,
  }) async {
    try {
      final userData = {
        'email': user.email ?? '',
        'displayName': displayName ?? user.displayName ?? user.email?.split('@')[0] ?? 'Unknown',
        'profileImageUrl': profileImageUrl ?? user.photoURL,
        'role': 'graduate_student', // Specific role for UTM graduate students
        'universityName': 'UTM', // Universiti Teknologi Malaysia
        'studentType': 'Graduate', // Graduate student type
        'emailVerified': user.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _usersCollection.doc(user.uid).set(userData, SetOptions(merge: true));
      print('User document created/updated successfully');
    } catch (e) {
      print('Error creating user document: $e');
      throw Exception('Failed to create user document: ${e.toString()}');
    }
  }

  // Ensure user document exists (for existing users)
  Future<void> ensureUserDocument(User user) async {
    try {
      final doc = await _usersCollection.doc(user.uid).get();
      if (!doc.exists) {
        await createUserDocument(user: user);
      } else {
        // Update email verification status if changed
        await _usersCollection.doc(user.uid).update({
          'emailVerified': user.emailVerified,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error ensuring user document: $e');
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get user display name with fallback logic
  Future<String> getUserDisplayName(String userId) async {
    try {
      // First, try to get from Firestore
      final userData = await getUserData(userId);
      if (userData != null) {
        final displayName = userData['displayName'];
        if (displayName != null && displayName.toString().trim().isNotEmpty) {
          return displayName;
        }
        
        final email = userData['email'];
        if (email != null) {
          return email.split('@')[0];
        }
      }

      // If Firestore doesn't have the data, try Firebase Auth
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        if (currentUser.displayName != null && currentUser.displayName!.trim().isNotEmpty) {
          return currentUser.displayName!;
        }
        if (currentUser.email != null) {
          return currentUser.email!.split('@')[0];
        }
      }

      return 'Unknown User';
    } catch (e) {
      print('Error getting user display name: $e');
      return 'Unknown User';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? profileImageUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) {
        updateData['displayName'] = displayName;
        // Also update in Firebase Auth
        await _auth.currentUser?.updateDisplayName(displayName);
      }
      
      if (profileImageUrl != null) {
        updateData['profileImageUrl'] = profileImageUrl;
        // Also update in Firebase Auth
        await _auth.currentUser?.updatePhotoURL(profileImageUrl);
      }

      await _usersCollection.doc(userId).update(updateData);
      print('User profile updated successfully');
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      // Validate UTM Graduate email
      if (!isUTMGraduateEmail(email)) {
        throw FirebaseAuthException(
          code: 'invalid-email-domain',
          message: 'Only @graduate.utm.my email addresses are supported.',
        );
      }

      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Check if email is UTM Graduate email (only @graduate.utm.my allowed)
  bool isUTMGraduateEmail(String email) {
    return email.toLowerCase().endsWith('@graduate.utm.my');
  }

  // Legacy method name for backward compatibility
  bool isUTMEmail(String email) {
    return isUTMGraduateEmail(email);
  }

  // Validate email format and domain
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email) && isUTMGraduateEmail(email);
  }

  // Check if current user's email is verified
  bool isEmailVerified() {
    User? user = _auth.currentUser;
    return user != null ? user.emailVerified : false;
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('Email verification sent');
      }
    } catch (e) {
      print('Error sending email verification: $e');
      throw Exception('Failed to send email verification: ${e.toString()}');
    }
  }

  // Reload user to check latest email verification status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
      
      // Update Firestore with latest verification status
      final user = _auth.currentUser;
      if (user != null) {
        await _usersCollection.doc(user.uid).update({
          'emailVerified': user.emailVerified,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error reloading user: $e');
    }
  }

  // Check if user document exists
  Future<bool> userDocumentExists(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user document: $e');
      return false;
    }
  }

  // Get current user display name
  String get currentUserDisplayName {
    final user = _auth.currentUser;
    if (user == null) return 'Unknown';
    
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!;
    } else if (user.email != null) {
      return user.email!.split('@')[0];
    }
    return 'Unknown';
  }

  // Extract student ID from UTM Graduate email (if needed)
  String? extractStudentId(String email) {
    if (!isUTMGraduateEmail(email)) return null;
    
    // UTM Graduate emails usually follow pattern: studentid@graduate.utm.my
    final username = email.split('@')[0];
    
    // Check if it looks like a student ID (contains numbers)
    if (RegExp(r'\d').hasMatch(username)) {
      return username.toUpperCase();
    }
    
    return null;
  }

  // Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user changes stream
  Stream<User?> get userChanges => _auth.userChanges();
}