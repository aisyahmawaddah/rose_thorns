import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/services/admin_service.dart';

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
      await _adminService.updateAdminLastLogin();
      print('AdminRepository: Last login updated successfully');
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
      final success = await _adminService.createAdminUser(email, password);
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
  Stream<User?> get authStateChanges => _adminService.authStateChanges;

  /// Get current user
  User? get currentUser => _adminService.getCurrentUser();

  /// Check if user is authenticated
  bool get isUserAuthenticated => _adminService.isUserAuthenticated();

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
      await _adminService.debugCurrentUser();
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

  Future<bool> checkIfUserIsAdmin(String userId) async {
    // TODO: Replace this with your actual admin check logic, e.g., Firestore lookup
    // Example using Firebase Firestore:
    // final doc = await FirebaseFirestore.instance.collection('admins').doc(userId).get();
    // return doc.exists;

    // Placeholder: always returns false (not admin)
    return false;
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
}
