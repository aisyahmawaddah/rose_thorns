import '../services/auth_service.dart';

class AuthViewModel {
  final AuthService _authService = AuthService();

  // Login Method
  Future<bool> login(String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (error) {
      print('Login error: $error');
      return false;
    }
  }

  // Register Method with University Email Validation
  Future<bool> register(
      String email, String password, String displayName) async {
    // Check if the email is a university email before registering
    if (!_authService.isUniversityEmail(email)) {
      print('Please use your university email address to register.');
      return false; // Prevent registration if email is not from the university domain
    }

    try {
      await _authService.registerWithEmailAndPassword(
          email, password, displayName);
      return true;
    } catch (error) {
      print('Registration error: $error');
      return false;
    }
  }

  // Password Reset Method
  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (error) {
      print('Password reset error: $error');
      return false;
    }
  }

  // Logout Method
  Future<void> logout() async {
    await _authService.signOut();
  }

  // Check if User is Logged In
  bool isLoggedIn() => _authService.currentUser != null;

  // Get Current User ID
  String? getCurrentUserId() => _authService.currentUser?.uid;

  // Check if Email is a University Email
  bool isUniversityEmail(String email) => _authService.isUniversityEmail(email);
}
