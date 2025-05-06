import '../services/auth_service.dart';

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

  Future<void> logout() => _authService.signOut();

  bool isLoggedIn() => _authService.currentUser != null;

  String? getCurrentUserId() => _authService.currentUser?.uid;

  bool isUniversityEmail(String email) => _authService.isUniversityEmail(email);
}
