import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/models/login_model.dart'; // Updated import

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
      };
    } catch (e) {
      print('AdminService: Error getting current user info - $e');
      return null;
    }
  }

  /// Get basic stats
  Future<Map<String, int>> getBasicStats() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();

      int totalUsers = usersSnapshot.docs.length;
      int totalBuyers = 0;
      int totalSellers = 0;
      int totalAdmins = 0;

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final role = data['role'] ?? 'buyer';

        switch (role) {
          case 'buyer':
            totalBuyers++;
            break;
          case 'seller':
            totalSellers++;
            break;
          case 'admin':
            totalAdmins++;
            break;
        }
      }

      return {
        'totalUsers': totalUsers,
        'totalBuyers': totalBuyers,
        'totalSellers': totalSellers,
        'totalAdmins': totalAdmins,
      };
    } catch (e) {
      print('AdminService: Error getting basic stats - $e');
      return {};
    }
  }

  /// Test connection
  Future<bool> testConnection() async {
    try {
      await _firestore.collection('test').limit(1).get();
      return true;
    } catch (e) {
      print('AdminService: Connection test failed - $e');
      return false;
    }
  }

  /// Create test admin user
  Future<bool> createTestAdminUser(String email, String password) async {
    try {
      // Check if user already exists
      final existingUser = await _auth.fetchSignInMethodsForEmail(email);
      if (existingUser.isNotEmpty) {
        print('AdminService: User already exists: $email');
        return false;
      }

      // Create user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Save to Firestore with admin role
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

  /// Get all users - UPDATED TO USE LoginModel
  Future<List<LoginModel>> getAllUsers() async {
    try {
      // Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user');
        return [];
      }

      print("📍 Fetching users from Firestore...");

      // Try without ordering first to avoid permission issues
      final querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      print("📍 Found ${querySnapshot.docs.length} users");

      // Convert documents to LoginModel objects
      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print("Processing user: ${data['email']} with role: ${data['role']}");
        return LoginModel.fromFirestoreMap(data, doc.id);
      }).toList();

      print("✅ Successfully loaded ${users.length} users");
      return users;
    } catch (e) {
      print('❌ Error fetching users: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  /// Deactivate user
  Future<bool> deactivateUser(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isActive': false});
      return true;
    } catch (e) {
      print('AdminService: Error deactivating user - $e');
      return false;
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
  User? get currentUser => _auth.currentUser;

  /// Debug current user in Firestore
  Future<void> debugCurrentUserInFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No authenticated user');
        return;
      }

      print('🔍 DEBUG: Current user UID: ${user.uid}');
      print('🔍 DEBUG: Current user email: ${user.email}');

      // Check if user document exists in Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        print('✅ User document found in Firestore:');
        print('   - Email: ${userData['email']}');
        print('   - Role: ${userData['role']}');
        print('   - Display Name: ${userData['displayName']}');
        print('   - Is Active: ${userData['isActive']}');
        print('   - Created At: ${userData['dateCreated']}');

        // Check if role is admin
        if (userData['role'] == 'admin') {
          print('✅ User has admin role!');
        } else {
          print(
              '❌ User does NOT have admin role. Current role: ${userData['role']}');
          print(
              '🔧 To fix: Update this user\'s role to "admin" in Firestore console');
        }
      } else {
        print('❌ User document does NOT exist in Firestore!');
        print('🔧 To fix: Create user document in Firestore with admin role');
      }
    } catch (e) {
      print('❌ Error debugging user: $e');
    }
  }

  /// Fix current user admin role
  Future<bool> fixCurrentUserAdminRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No authenticated user to fix');
        return false;
      }

      print('🔧 Fixing admin role for user: ${user.email}');

      // Set/update user document with admin role
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'role': 'admin',
        'displayName': user.displayName ?? 'Admin User',
        'dateCreated': FieldValue.serverTimestamp(),
        'isActive': true,
      }, SetOptions(merge: true)); // Use merge to keep existing data

      print('✅ User role set to admin successfully!');
      return true;
    } catch (e) {
      print('❌ Error fixing admin role: $e');
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
