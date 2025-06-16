import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/models/user_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Simple admin authentication methods for testing

  /// Check if current user is admin - SIMPLIFIED VERSION
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('AdminService: No current user found');
        return false;
      }

      print('AdminService: Checking admin status for user: ${user.email}');

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        print('AdminService: User document does not exist in Firestore');
        return false;
      }

      final userData = doc.data() as Map<String, dynamic>;
      final userRole = userData['role'] ?? 'buyer';

      print('AdminService: User role found: $userRole');

      final isAdmin = userRole == 'admin';
      print('AdminService: Is admin: $isAdmin');

      return isAdmin;
    } catch (e) {
      print('AdminService: Error checking admin status - $e');
      return false;
    }
  }

  /// Get current user info (simplified)
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      final userData = doc.data() as Map<String, dynamic>;
      return {
        'id': user.uid,
        'email': user.email ?? '',
        'displayName':
            userData['displayName'] ?? user.displayName ?? 'Admin User',
        'role': userData['role'] ?? 'buyer',
        'lastLoginAt': DateTime.now(),
      };
    } catch (e) {
      print('AdminService: Error getting current user info - $e');
      return null;
    }
  }

  /// Update admin last login (simplified)
  Future<void> updateAdminLastLogin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      print('AdminService: Updated last login for admin: ${user.email}');
    } catch (e) {
      print('AdminService: Error updating admin last login - $e');
    }
  }

  /// Get basic stats for testing (simplified)
  Future<Map<String, int>> getBasicStats() async {
    try {
      // Get total users count
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;

      // Get buyers count
      final buyersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'buyer')
          .get();
      final totalBuyers = buyersSnapshot.docs.length;

      // Get sellers count
      final sellersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'seller')
          .get();
      final totalSellers = sellersSnapshot.docs.length;

      // Get admins count
      final adminsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();
      final totalAdmins = adminsSnapshot.docs.length;

      print(
          'AdminService: Stats retrieved - Users: $totalUsers, Buyers: $totalBuyers, Sellers: $totalSellers, Admins: $totalAdmins');

      return {
        'totalUsers': totalUsers,
        'totalBuyers': totalBuyers,
        'totalSellers': totalSellers,
        'totalAdmins': totalAdmins,
      };
    } catch (e) {
      print('AdminService: Error getting basic stats - $e');
      return {
        'totalUsers': 0,
        'totalBuyers': 0,
        'totalSellers': 0,
        'totalAdmins': 0,
      };
    }
  }

  /// Test connection to Firestore
  Future<bool> testConnection() async {
    try {
      await _firestore.collection('test').doc('connection').get();
      print('AdminService: Firestore connection test successful');
      return true;
    } catch (e) {
      print('AdminService: Firestore connection test failed - $e');
      return false;
    }
  }

  /// Create admin user (for testing purposes)
  Future<bool> createAdminUser(String email, String password) async {
    try {
      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Add user data to Firestore with admin role
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'role': 'admin',
          'displayName': 'Test Admin',
          'dateCreated': FieldValue.serverTimestamp(),
          'isActive': true,
        });

        print('AdminService: Admin user created successfully: $email');
        return true;
      }
      return false;
    } catch (e) {
      print('AdminService: Error creating admin user - $e');
      return false;
    }
  }

  /// Check if any admin users exist
  Future<bool> hasAdminUsers() async {
    try {
      final adminsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      final hasAdmins = adminsSnapshot.docs.isNotEmpty;
      print('AdminService: Admin users exist: $hasAdmins');
      return hasAdmins;
    } catch (e) {
      print('AdminService: Error checking for admin users - $e');
      return false;
    }
  }

  /// Get current user's role
  Future<String?> getCurrentUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      final userData = doc.data() as Map<String, dynamic>;
      final role = userData['role'] as String?;

      print('AdminService: Current user role: $role');
      return role;
    } catch (e) {
      print('AdminService: Error getting current user role - $e');
      return null;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _auth.signOut();
      print('AdminService: User logged out successfully');
    } catch (e) {
      print('AdminService: Error during logout - $e');
      rethrow;
    }
  }

  /// Check if user is authenticated
  bool isUserAuthenticated() {
    final user = _auth.currentUser;
    final isAuth = user != null;
    print('AdminService: User authenticated: $isAuth');
    return isAuth;
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Debug methods for testing

  /// Print current user info for debugging
  Future<void> debugCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('DEBUG: No current user');
        return;
      }

      print('DEBUG: Current user:');
      print('  - UID: ${user.uid}');
      print('  - Email: ${user.email}');
      print('  - Email verified: ${user.emailVerified}');
      print('  - Display name: ${user.displayName}');

      final userInfo = await getCurrentUserInfo();
      if (userInfo != null) {
        print('  - Firestore role: ${userInfo['role']}');
        print('  - Firestore display name: ${userInfo['displayName']}');
      } else {
        print('  - No Firestore document found');
      }
    } catch (e) {
      print('DEBUG: Error getting user info - $e');
    }
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    // TODO: Implement the logic to update the user's role in your backend or database.
    // Return true if successful, false otherwise.
    // Example placeholder:
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<List<Object>> getAllUsers() async {
    try {
      // Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user');
        return [];
      }

      print("📍 Fetching users from Firestore...");
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('❌ Error fetching users: $e');
      return [];
    }
  }

  Future<bool> deactivateUser(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isActive': false});
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Test admin operations
  Future<Map<String, bool>> runAdminTests() async {
    final results = <String, bool>{};

    try {
      // Test 1: Connection
      results['connection'] = await testConnection();

      // Test 2: Authentication
      results['authentication'] = isUserAuthenticated();

      // Test 3: Admin check
      results['adminCheck'] = await isCurrentUserAdmin();

      // Test 4: Basic stats
      final stats = await getBasicStats();
      results['statsRetrieval'] = stats.isNotEmpty;

      // Test 5: User info
      final userInfo = await getCurrentUserInfo();
      results['userInfo'] = userInfo != null;

      print('AdminService: Test results: $results');
      return results;
    } catch (e) {
      print('AdminService: Error running tests - $e');
      return results;
    }
  }
}
