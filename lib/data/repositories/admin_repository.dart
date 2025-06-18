import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/services/admin_service.dart';
import 'package:koopon/data/models/login_model.dart'; // Updated import

class AdminRepository {
  final AdminService _adminService = AdminService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Simplified admin repository for testing

  /// Check if current user has admin privileges
  Future<bool> isCurrentUserAdmin() async {
    try {
      print('AdminRepository: Checking if current user is admin...');
      final isAdmin = await _adminService.isCurrentUserAdmin();
      print('AdminRepository: Admin check result: $isAdmin');
      return isAdmin;
    } catch (e) {
      print('AdminRepository: Error checking admin status - $e');
      return false;
    }
  }

  /// Get current admin/user information
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      print('AdminRepository: Getting current user info...');
      final userInfo = await _adminService.getCurrentUserInfo();
      if (userInfo != null) {
        print('AdminRepository: User info retrieved for: ${userInfo['email']}');
      } else {
        print('AdminRepository: No user info found');
      }
      return userInfo;
    } catch (e) {
      print('AdminRepository: Error getting current user info - $e');
      return null;
    }
  }

  /// Update admin's last login timestamp
  Future<void> updateAdminLastLogin() async {
    try {
      print('AdminRepository: Updating admin last login...');
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        print('AdminRepository: Last login updated successfully');
      }
    } catch (e) {
      print('AdminRepository: Error updating admin last login - $e');
    }
  }

  /// Get basic statistics (simplified for testing)
  Future<Map<String, int>> getBasicStats() async {
    try {
      print('AdminRepository: Getting basic statistics...');
      final stats = await _adminService.getBasicStats();
      print('AdminRepository: Stats retrieved: $stats');
      return stats;
    } catch (e) {
      print('AdminRepository: Error getting basic stats - $e');
      return {
        'totalUsers': 0,
        'totalBuyers': 0,
        'totalSellers': 0,
        'totalAdmins': 0,
      };
    }
  }

  /// Test repository connection and functionality
  Future<bool> testConnection() async {
    try {
      print('AdminRepository: Testing connection...');
      final connectionTest = await _adminService.testConnection();
      print('AdminRepository: Connection test result: $connectionTest');
      return connectionTest;
    } catch (e) {
      print('AdminRepository: Connection test failed - $e');
      return false;
    }
  }

  /// Initialize admin session
  Future<Map<String, dynamic>> initializeAdminSession() async {
    try {
      print('AdminRepository: Initializing admin session...');

      // Check if user is authenticated
      if (!_adminService.isUserAuthenticated()) {
        throw Exception('User not authenticated');
      }

      // Check admin privileges
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('User does not have admin privileges');
      }

      // Get user info
      final userInfo = await getCurrentUserInfo();
      if (userInfo == null) {
        throw Exception('Could not retrieve user information');
      }

      // Update last login
      await updateAdminLastLogin();

      // Get basic stats
      final stats = await getBasicStats();

      final sessionData = {
        'success': true,
        'userInfo': userInfo,
        'stats': stats,
        'sessionStarted': DateTime.now().toIso8601String(),
      };

      print('AdminRepository: Admin session initialized successfully');
      return sessionData;
    } catch (e) {
      print('AdminRepository: Error initializing admin session - $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get current user's role
  Future<String?> getCurrentUserRole() async {
    try {
      print('AdminRepository: Getting current user role...');
      final role = await _adminService.getCurrentUserRole();
      print('AdminRepository: Current user role: $role');
      return role;
    } catch (e) {
      print('AdminRepository: Error getting current user role - $e');
      return null;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      print('AdminRepository: Logging out user...');
      await _adminService.logout();
      print('AdminRepository: User logged out successfully');
    } catch (e) {
      print('AdminRepository: Error during logout - $e');
      rethrow;
    }
  }

  /// Check if any admin users exist in the system
  Future<bool> hasAdminUsers() async {
    try {
      print('AdminRepository: Checking if admin users exist...');
      final hasAdmins = await _adminService.hasAdminUsers();
      print('AdminRepository: Admin users exist: $hasAdmins');
      return hasAdmins;
    } catch (e) {
      print('AdminRepository: Error checking for admin users - $e');
      return false;
    }
  }

  /// Create a test admin user (for development/testing)
  Future<bool> createTestAdminUser(String email, String password) async {
    try {
      print('AdminRepository: Creating test admin user: $email');
      final success = await _adminService.createTestAdminUser(email, password);
      if (success) {
        print('AdminRepository: Test admin user created successfully');
      } else {
        print('AdminRepository: Failed to create test admin user');
      }
      return success;
    } catch (e) {
      print('AdminRepository: Error creating test admin user - $e');
      return false;
    }
  }

  /// Get authentication state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _adminService.currentUser;

  /// Check if user is authenticated
  bool get isUserAuthenticated => _adminService.isUserAuthenticated();

  /// Get all users - UPDATED TO USE LoginModel
  Future<List<LoginModel>> getAllUsers() async {
    try {
      print('AdminRepository: Fetching all users...');
      final querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      print('AdminRepository: Found ${querySnapshot.docs.length} documents');

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('AdminRepository: Processing user data: ${doc.id}');
        return LoginModel.fromFirestoreMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('AdminRepository: Error fetching users - $e');
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Update user data using LoginModel
  Future<bool> updateUser(LoginModel user) async {
    try {
      if (user.id == null) {
        throw Exception('User ID is required for update');
      }

      print('AdminRepository: Updating user: ${user.email}');

      await _firestore
          .collection('users')
          .doc(user.id!)
          .update(user.toFirestoreMap());

      print('AdminRepository: User updated successfully');
      return true;
    } catch (e) {
      print('AdminRepository: Error updating user - $e');
      return false;
    }
  }

  /// Delete/Deactivate user
  Future<bool> deactivateUser(String userId) async {
    try {
      print('AdminRepository: Deactivating user: $userId');
      final success = await _adminService.deactivateUser(userId);
      print('AdminRepository: User deactivation result: $success');
      return success;
    } catch (e) {
      print('AdminRepository: Error deactivating user - $e');
      return false;
    }
  }

  /// Get user by ID - returns LoginModel
  Future<LoginModel?> getUserById(String userId) async {
    try {
      print('AdminRepository: Getting user by ID: $userId');

      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        print('AdminRepository: User not found');
        return null;
      }

      final userData = doc.data() as Map<String, dynamic>;
      final user = LoginModel.fromFirestoreMap(userData, doc.id);

      print('AdminRepository: User retrieved: ${user.email}');
      return user;
    } catch (e) {
      print('AdminRepository: Error getting user by ID - $e');
      return null;
    }
  }

  // Debug and testing methods

  /// Run comprehensive admin tests
  Future<Map<String, dynamic>> runAdminTests() async {
    try {
      print('AdminRepository: Running comprehensive admin tests...');

      final testResults = await _adminService.runAdminTests();
      final userInfo = await getCurrentUserInfo();
      final stats = await getBasicStats();

      final results = {
        'timestamp': DateTime.now().toIso8601String(),
        'tests': testResults,
        'userInfo': userInfo,
        'stats': stats,
        'overallSuccess': testResults.values.every((result) => result == true),
      };

      print('AdminRepository: Test results: $results');
      return results;
    } catch (e) {
      print('AdminRepository: Error running admin tests - $e');
      return {
        'timestamp': DateTime.now().toIso8601String(),
        'error': e.toString(),
        'overallSuccess': false,
      };
    }
  }

  /// Debug current user information
  Future<void> debugCurrentUser() async {
    try {
      print('AdminRepository: === DEBUG USER INFO ===');
      final user = currentUser;
      if (user != null) {
        print('User ID: ${user.uid}');
        print('User Email: ${user.email}');
        print('User Display Name: ${user.displayName}');

        // Get Firestore user data
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final userData = doc.data() as Map<String, dynamic>;
          print('Firestore Role: ${userData['role']}');
          print('Firestore Display Name: ${userData['displayName']}');
          print('Firestore Active: ${userData['isActive']}');
        } else {
          print('No Firestore document found for user');
        }
      } else {
        print('No authenticated user found');
      }
      print('AdminRepository: === END DEBUG ===');
    } catch (e) {
      print('AdminRepository: Error in debug - $e');
    }
  }

  /// Validate admin setup
  Future<Map<String, dynamic>> validateAdminSetup() async {
    try {
      print('AdminRepository: Validating admin setup...');

      final validation = <String, dynamic>{};

      // Check 1: Firebase connection
      validation['firebaseConnection'] = await testConnection();

      // Check 2: User authentication
      validation['userAuthenticated'] = isUserAuthenticated;

      // Check 3: Admin users exist
      validation['adminUsersExist'] = await hasAdminUsers();

      // Check 4: Current user is admin (if authenticated)
      if (isUserAuthenticated) {
        validation['currentUserIsAdmin'] = await isCurrentUserAdmin();
        validation['currentUserRole'] = await getCurrentUserRole();
      }

      // Check 5: Basic stats retrieval
      final stats = await getBasicStats();
      validation['statsRetrievalWorking'] = stats.isNotEmpty;

      // Overall validation
      validation['overallValid'] = validation['firebaseConnection'] == true &&
          (validation['adminUsersExist'] == true ||
              validation['currentUserIsAdmin'] == true);

      validation['timestamp'] = DateTime.now().toIso8601String();

      print('AdminRepository: Validation results: $validation');
      return validation;
    } catch (e) {
      print('AdminRepository: Error validating admin setup - $e');
      return {
        'error': e.toString(),
        'overallValid': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Check if specific user is admin by ID
  Future<bool> checkIfUserIsAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return false;

      final userData = doc.data() as Map<String, dynamic>;
      return userData['role'] == 'admin';
    } catch (e) {
      print('AdminRepository: Error checking if user is admin - $e');
      return false;
    }
  }

  /// Quick admin status check
  Future<Map<String, dynamic>> quickAdminCheck() async {
    try {
      final user = currentUser;
      if (user == null) {
        return {
          'isAdmin': false,
          'reason': 'No authenticated user',
        };
      }

      final isAdmin = await isCurrentUserAdmin();
      final userRole = await getCurrentUserRole();

      return {
        'isAdmin': isAdmin,
        'userEmail': user.email,
        'userRole': userRole,
        'reason': isAdmin
            ? 'User has admin privileges'
            : 'User does not have admin role',
      };
    } catch (e) {
      return {
        'isAdmin': false,
        'reason': 'Error checking admin status: $e',
      };
    }
  }

  /// Get simplified dashboard data for testing
  Future<Map<String, dynamic>> getSimpleDashboardData() async {
    try {
      print('AdminRepository: Getting simple dashboard data...');

      final userInfo = await getCurrentUserInfo();
      final stats = await getBasicStats();
      final isAdmin = await isCurrentUserAdmin();

      final dashboardData = {
        'userInfo': userInfo,
        'stats': stats,
        'isAdmin': isAdmin,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      print('AdminRepository: Dashboard data retrieved successfully');
      return dashboardData;
    } catch (e) {
      print('AdminRepository: Error getting dashboard data - $e');
      return {
        'error': e.toString(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Create user with LoginModel
  Future<bool> createUser(LoginModel user, String password) async {
    try {
      print('AdminRepository: Creating new user: ${user.email}');

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user document in Firestore
        final userWithId = user.copyWith(id: userCredential.user!.uid);
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userWithId.toFirestoreMap());

        print('AdminRepository: User created successfully');
        return true;
      }

      return false;
    } catch (e) {
      print('AdminRepository: Error creating user - $e');
      return false;
    }
  }

  /// Search users by email or name
  Future<List<LoginModel>> searchUsers(String query) async {
    try {
      print('AdminRepository: Searching users with query: $query');

      final allUsers = await getAllUsers();

      final filteredUsers = allUsers.where((user) {
        final emailMatch =
            user.email.toLowerCase().contains(query.toLowerCase());
        final nameMatch =
            user.displayName?.toLowerCase().contains(query.toLowerCase()) ??
                false;
        return emailMatch || nameMatch;
      }).toList();

      print('AdminRepository: Found ${filteredUsers.length} matching users');
      return filteredUsers;
    } catch (e) {
      print('AdminRepository: Error searching users - $e');
      return [];
    }
  }

  /// Get users by role
  Future<List<LoginModel>> getUsersByRole(String role) async {
    try {
      print('AdminRepository: Getting users with role: $role');

      final allUsers = await getAllUsers();
      final filteredUsers =
          allUsers.where((user) => user.role == role).toList();

      print(
          'AdminRepository: Found ${filteredUsers.length} users with role $role');
      return filteredUsers;
    } catch (e) {
      print('AdminRepository: Error getting users by role - $e');
      return [];
    }
  }
}
