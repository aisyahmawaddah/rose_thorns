import 'package:flutter/foundation.dart';
import 'package:koopon/data/repositories/admin_repository.dart';
import 'package:koopon/data/models/login_model.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository = AdminRepository();

  // State variables
  LoginModel? _currentUser;
  Map<String, int>? _basicStats;
  Map<String, dynamic>? _sessionData;
  List<LoginModel> _users = [];

  // Loading states
  bool _isLoading = false;
  bool _isInitializing = false;

  // Error states
  String? _errorMessage;
  bool _disposed = false;

  // Getters
  LoginModel? get currentUser => _currentUser;
  List<LoginModel> get users => _users;
  Map<String, int>? get basicStats => _basicStats;
  Map<String, dynamic>? get sessionData => _sessionData;

  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;

  // Computed getters for UI
  String get adminDisplayName => _currentUser?.displayName ?? 'Admin User';
  String get adminEmail => _currentUser?.email ?? 'Unknown';
  bool get isAdmin => _currentUser?.role == 'admin';

  int get totalUsers => _basicStats?['totalUsers'] ?? 0;
  int get totalBuyers => _basicStats?['totalBuyers'] ?? 0;
  int get totalSellers => _basicStats?['totalSellers'] ?? 0;
  int get totalAdmins => _basicStats?['totalAdmins'] ?? 0;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _safeNotifyListeners();
    }
  }

  void _setInitializing(bool initializing) {
    if (_isInitializing != initializing) {
      _isInitializing = initializing;
      _safeNotifyListeners();
    }
  }

  void _setError(String? error) {
    _errorMessage = error;
    _safeNotifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      _safeNotifyListeners();
    }
  }

  // Initialize admin session
  Future<void> initialize() async {
    if (_disposed) return;

    print('AdminViewModel: Starting initialization...');
    _setInitializing(true);
    _clearError();

    try {
      // Initialize admin session
      _sessionData = await _adminRepository.initializeAdminSession();

      if (_sessionData?['success'] == true) {
        final userInfo = _sessionData?['userInfo'];
        if (userInfo != null) {
          _currentUser = LoginModel.fromFirestoreMap(
              userInfo as Map<String, dynamic>, userInfo['id'] as String);
        }
        _basicStats = _sessionData?['stats'];

        // Load initial users list
        await loadUsers();

        print('AdminViewModel: Initialization successful');
      } else {
        throw Exception(
            _sessionData?['error'] ?? 'Failed to initialize admin session');
      }
    } catch (e) {
      print('AdminViewModel: Initialization failed - $e');
      _setError('Failed to initialize admin dashboard: ${e.toString()}');
    } finally {
      _setInitializing(false);
    }
  }

  Future<void> verifyAdminAccess() async {
    try {
      print('🔍 Verifying admin access...');
      final isAdmin = await _adminRepository.isCurrentUserAdmin();
      print('👤 Admin status: $isAdmin');

      if (!isAdmin) {
        throw Exception('Access denied: User is not an admin');
      }
    } catch (e) {
      print('❌ Admin verification failed: $e');
      _setError(e.toString());
      throw e;
    }
  }

  // Load all users
  Future<void> loadUsers() async {
    if (_disposed) return;

    _setLoading(true);
    _clearError();

    try {
      await verifyAdminAccess(); // Add this verification step

      print('📚 Loading users...');
      final users = await _adminRepository.getAllUsers();
      _users = users;
      print('✅ Loaded ${users.length} users');

      _safeNotifyListeners();
    } catch (e) {
      print('❌ Error loading users: $e');
      _setError('Failed to load users: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> isCurrentUserAdmin() async {
    // TODO: Implement actual admin check logic.
    // For now, return true for demonstration.
    return true;
  }

  Future<void> debugAdminAccess() async {
    try {
      _setLoading(true);
      print('\n🔍 Starting Admin Access Debug:');

      // Check authentication
      final currentUser = _adminRepository.currentUser;
      print('📱 Current user: ${currentUser?.email ?? 'Not logged in'}');

      // Verify admin status
      final isAdmin = await _adminRepository.isCurrentUserAdmin();
      print('👑 Is admin: $isAdmin');

      // Try loading users
      print('🔄 Attempting to load users...');
      await loadUsers();

      print('✅ Debug complete\n');
    } catch (e) {
      print('❌ Debug error: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Add to AdminViewModel
  Future<void> debugUserFetch() async {
    print('\n🔍 DEBUG: Starting User Fetch Diagnostic');
    try {
      // Check Firebase Auth state
      final authUser = _adminRepository.currentUser;
      print('📱 Auth State: ${authUser?.email ?? 'Not logged in'}');

      // Check admin status
      final isAdmin = await _adminRepository.isCurrentUserAdmin();
      print('👑 Is Admin: $isAdmin');

      // Try fetching users
      print('🔄 Attempting to fetch users...');
      final users = await _adminRepository.getAllUsers();
      print('📊 Fetch Result: ${users.length} users found');

      if (users.isNotEmpty) {
        print('\n📋 User List:');
        for (var user in users) {
          print('  • ${user.email} (${user.role})');
        }
      }

      // Check Firestore connection
      final testConnection = await _adminRepository.testConnection();
      print('🔌 Firestore Connection: ${testConnection ? 'OK' : 'Failed'}');
    } catch (e, stackTrace) {
      print('❌ Error during debug: $e');
      print('📜 Stack trace: $stackTrace');
    }
    print('🔍 DEBUG: End of Diagnostic\n');
  }

  // Search users
  Future<List<LoginModel>> searchUsers(String query) async {
    try {
      print('AdminViewModel: Searching users with query: $query');
      return await _adminRepository.searchUsers(query);
    } catch (e) {
      print('AdminViewModel: Error searching users - $e');
      return [];
    }
  }

  // Get users by role
  Future<List<LoginModel>> getUsersByRole(String role) async {
    try {
      print('AdminViewModel: Getting users by role: $role');
      return await _adminRepository.getUsersByRole(role);
    } catch (e) {
      print('AdminViewModel: Error getting users by role - $e');
      return [];
    }
  }

  // Update user
  Future<bool> updateUser(LoginModel user) async {
    try {
      print('AdminViewModel: Updating user: ${user.email}');
      final success = await _adminRepository.updateUser(user);
      if (success) {
        await loadUsers(); // Refresh users list
      }
      return success;
    } catch (e) {
      print('AdminViewModel: Error updating user - $e');
      return false;
    }
  }

  // Create new user
  Future<bool> createUser(LoginModel user, String password) async {
    try {
      print('AdminViewModel: Creating new user: ${user.email}');
      final success = await _adminRepository.createUser(user, password);
      if (success) {
        await loadUsers(); // Refresh users list
      }
      return success;
    } catch (e) {
      print('AdminViewModel: Error creating user - $e');
      return false;
    }
  }

  // Deactivate user
  Future<bool> deactivateUser(String userId) async {
    try {
      print('AdminViewModel: Deactivating user: $userId');
      final success = await _adminRepository.deactivateUser(userId);
      if (success) {
        await loadUsers(); // Refresh users list
      }
      return success;
    } catch (e) {
      print('AdminViewModel: Error deactivating user - $e');
      return false;
    }
  }

  // Get user by ID
  Future<LoginModel?> getUserById(String userId) async {
    try {
      print('AdminViewModel: Getting user by ID: $userId');
      return await _adminRepository.getUserById(userId);
    } catch (e) {
      print('AdminViewModel: Error getting user by ID - $e');
      return null;
    }
  }

  // Refresh basic statistics
  Future<void> refreshStats() async {
    if (_disposed) return;

    _setLoading(true);
    _clearError();

    try {
      print('AdminViewModel: Refreshing statistics...');
      _basicStats = await _adminRepository.getBasicStats();
      _safeNotifyListeners();
      print('AdminViewModel: Statistics refreshed: $_basicStats');
    } catch (e) {
      print('AdminViewModel: Error refreshing stats - $e');
      _setError('Failed to refresh statistics: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    if (_disposed) return;

    _setLoading(true);
    _clearError();

    try {
      print('AdminViewModel: Refreshing all data...');

      await Future.wait([
        loadUsers(),
        refreshStats(),
      ]);

      print('AdminViewModel: All data refreshed successfully');
    } catch (e) {
      print('AdminViewModel: Error refreshing all data - $e');
      _setError('Failed to refresh data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      print('AdminViewModel: Logging out...');
      await _adminRepository.logout();

      // Clear local data
      _currentUser = null;
      _basicStats = null;
      _sessionData = null;
      _users.clear();
      _clearError();

      _safeNotifyListeners();
      print('AdminViewModel: Logout successful');
    } catch (e) {
      print('AdminViewModel: Error during logout - $e');
      _setError('Failed to logout: ${e.toString()}');
    }
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      print('AdminViewModel: Testing connection...');
      return await _adminRepository.testConnection();
    } catch (e) {
      print('AdminViewModel: Connection test failed - $e');
      return false;
    }
  }

  // Validate setup
  Future<Map<String, dynamic>> validateSetup() async {
    try {
      print('AdminViewModel: Validating admin setup...');
      return await _adminRepository.validateAdminSetup();
    } catch (e) {
      print('AdminViewModel: Error validating setup - $e');
      return {
        'error': e.toString(),
        'overallValid': false,
      };
    }
  }

  // Get formatted stats for display
  Map<String, String> get formattedStats {
    return {
      'Total Users': totalUsers.toString(),
      'Buyers': totalBuyers.toString(),
      'Sellers': totalSellers.toString(),
      'Admins': totalAdmins.toString(),
    };
  }

  // Get session info for display
  Map<String, String> get sessionInfo {
    if (_sessionData == null) return {};

    return {
      'Session Started': _sessionData?['sessionStarted'] ?? 'Unknown',
      'Admin Status': isAdmin ? 'Verified' : 'Not Admin',
      'Email': adminEmail,
      'Display Name': adminDisplayName,
    };
  }

  // Reset view model state
  void reset() {
    _currentUser = null;
    _basicStats = null;
    _sessionData = null;
    _users.clear();
    _errorMessage = null;
    _isLoading = false;
    _isInitializing = false;
    _safeNotifyListeners();
    print('AdminViewModel: State reset');
  }
}
