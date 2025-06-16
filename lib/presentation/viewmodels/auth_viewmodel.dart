import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/repositories/login_repository.dart';
import 'package:koopon/data/services/auth_service.dart';

class AuthViewModel {
  final AuthService _authService = AuthService();

  Future<bool> login(String email, String password) => _authService
          .signInWithEmailAndPassword(email, password)
          .then((_) => true)
          .catchError((error) {
        print('Login error: $error');
        return false;
      });

  Future<bool> register(String email, String password, String displayName) =>
      _authService
          .registerWithEmailAndPassword(email, password, displayName)
          .then((_) => true)
          .catchError((error) {
        print('Registration error: $error');
        return false;
      });

  Future<bool> resetPassword(String email) =>
      _authService.resetPassword(email).then((_) => true).catchError((error) {
        print('Password reset error: $error');
        return false;
      });

 Future<UserCredential> signIn(String email, String password) async {
    // Implement your sign-in logic here, e.g., call your repository and handle authentication
    // Return true if sign-in is successful, otherwise throw an error or return false
    try {
      // Example: Replace with your actual repository call
      final result = await LoginRepository().login(email, password);
      // You may want to set user state here
      return result; // Assume result is a bool for success
    } catch (e) {
      rethrow;
    }
  }

   Future<bool> checkAdminRole() async {
    // TODO: Replace this with your actual admin check logic.
    // Example: Check user role from Firebase, API, or local storage.
    // For now, always return false.
    return false;
  }
  
  Future<void> logout() => _authService.signOut();

  bool isLoggedIn() => _authService.currentUser != null;

  String? getCurrentUserId() => _authService.currentUser?.uid;

  bool isUniversityEmail(String email) => _authService.isUniversityEmail(email);
}
