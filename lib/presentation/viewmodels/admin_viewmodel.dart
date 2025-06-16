import 'package:flutter/foundation.dart';
import 'package:koopon/data/repositories/admin_repository.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository = AdminRepository();

  // State variables
  Map<String, dynamic>? _currentUserInfo;
  Map<String, int>? _basicStats;
  Map<String, dynamic>? _sessionData;

  // Loading states
  bool _isLoading = false;
  bool _isInitializing = false;

  // Error states
  String? _errorMessage;
  bool _disposed = false;

  // Getters
  Map<String, dynamic>? get currentUserInfo => _currentUserInfo;
  Map<String, int>? get basicStats => _basicStats;
  Map<String, dynamic>? get sessionData => _sessionData;

  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;

  // Computed getters for UI
  String get adminDisplayName =>
      _currentUserInfo?['displayName'] ?? 'Admin User';
  String get adminEmail => _currentUserInfo?['email'] ?? 'Unknown';
  bool get isAdmin => _currentUserInfo?['role'] == 'admin';

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
        _currentUserInfo = _sessionData?['userInfo'];
        _basicStats = _sessionData?['stats'];
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

  // Quick admin check
  Future<bool> checkAdminStatus() async {
    try {
      print('AdminViewModel: Checking admin status...');
      final adminCheck = await _adminRepository.quickAdminCheck();
      print('AdminViewModel: Admin check result: $adminCheck');
      return adminCheck['isAdmin'] == true;
    } catch (e) {
      print('AdminViewModel: Error checking admin status - $e');
      return false;
    }
  }

  // Refresh user info
  Future<void> refreshUserInfo() async {
    if (_disposed) return;

    _setLoading(true);
    _clearError();

    try {
      print('AdminViewModel: Refreshing user info...');
      _currentUserInfo = await _adminRepository.getCurrentUserInfo();
      _safeNotifyListeners();
      print('AdminViewModel: User info refreshed');
    } catch (e) {
      print('AdminViewModel: Error refreshing user info - $e');
      _setError('Failed to refresh user info: ${e.toString()}');
    } finally {
      _setLoading(false);
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
        refreshUserInfo(),
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

  // Test admin functionality
  Future<Map<String, dynamic>> runAdminTests() async {
    try {
      print('AdminViewModel: Running admin tests...');
      final testResults = await _adminRepository.runAdminTests();
      print('AdminViewModel: Test results: $testResults');
      return testResults;
    } catch (e) {
      print('AdminViewModel: Error running tests - $e');
      return {
        'error': e.toString(),
        'overallSuccess': false,
      };
    }
  }

  // Validate admin setup
  Future<Map<String, dynamic>> validateSetup() async {
    try {
      print('AdminViewModel: Validating admin setup...');
      final validation = await _adminRepository.validateAdminSetup();
      print('AdminViewModel: Validation results: $validation');
      return validation;
    } catch (e) {
      print('AdminViewModel: Error validating setup - $e');
      return {
        'error': e.toString(),
        'overallValid': false,
      };
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      print('AdminViewModel: Logging out...');
      await _adminRepository.logout();

      // Clear local data
      _currentUserInfo = null;
      _basicStats = null;
      _sessionData = null;
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
      final connectionTest = await _adminRepository.testConnection();
      print('AdminViewModel: Connection test result: $connectionTest');
      return connectionTest;
    } catch (e) {
      print('AdminViewModel: Connection test failed - $e');
      return false;
    }
  }

  // Get simple dashboard data
  Future<void> loadDashboardData() async {
    if (_disposed) return;

    _setLoading(true);
    _clearError();

    try {
      print('AdminViewModel: Loading dashboard data...');
      final dashboardData = await _adminRepository.getSimpleDashboardData();

      if (dashboardData.containsKey('error')) {
        throw Exception(dashboardData['error']);
      }

      _currentUserInfo = dashboardData['userInfo'];
      _basicStats = dashboardData['stats'];

      _safeNotifyListeners();
      print('AdminViewModel: Dashboard data loaded successfully');
    } catch (e) {
      print('AdminViewModel: Error loading dashboard data - $e');
      _setError('Failed to load dashboard data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Debug current user
  Future<void> debugCurrentUser() async {
    try {
      print('AdminViewModel: Running debug for current user...');
      await _adminRepository.debugCurrentUser();
    } catch (e) {
      print('AdminViewModel: Error in debug - $e');
    }
  }

  // Create test admin (for development)
  Future<bool> createTestAdmin(String email, String password) async {
    try {
      print('AdminViewModel: Creating test admin: $email');
      final success =
          await _adminRepository.createTestAdminUser(email, password);
      print('AdminViewModel: Test admin creation result: $success');
      return success;
    } catch (e) {
      print('AdminViewModel: Error creating test admin - $e');
      return false;
    }
  }

  // Check if admin users exist
  Future<bool> checkAdminUsersExist() async {
    try {
      print('AdminViewModel: Checking if admin users exist...');
      final hasAdmins = await _adminRepository.hasAdminUsers();
      print('AdminViewModel: Admin users exist: $hasAdmins');
      return hasAdmins;
    } catch (e) {
      print('AdminViewModel: Error checking admin users - $e');
      return false;
    }
  }

  // Get current user role
  Future<String?> getCurrentUserRole() async {
    try {
      print('AdminViewModel: Getting current user role...');
      final role = await _adminRepository.getCurrentUserRole();
      print('AdminViewModel: Current user role: $role');
      return role;
    } catch (e) {
      print('AdminViewModel: Error getting user role - $e');
      return null;
    }
  }

  // Check if user is authenticated
  bool get isUserAuthenticated => _adminRepository.isUserAuthenticated;

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
    _currentUserInfo = null;
    _basicStats = null;
    _sessionData = null;
    _errorMessage = null;
    _isLoading = false;
    _isInitializing = false;
    _safeNotifyListeners();
    print('AdminViewModel: State reset');
  }
}
