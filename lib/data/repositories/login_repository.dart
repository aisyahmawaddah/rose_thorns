// login_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/services/login_service.dart';

class LoginRepository {
  final LoginService _loginService;
  
  LoginRepository({LoginService? loginService}) 
      : _loginService = loginService ?? LoginService();
  
  Future<UserCredential> login(String email, String password) async {
    try {
      return await _loginService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      // You can add additional error handling logic here if needed
      throw e;
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _loginService.resetPassword(email);
    } catch (e) {
      throw e;
    }
  }
  
  Future<void> logout() async {
    try {
      await _loginService.signOut();
    } catch (e) {
      throw e;
    }
  }
  
  User? get currentUser => _loginService.currentUser;
  
  bool isUserLoggedIn() {
    return _loginService.isUserLoggedIn();
  }
}