import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koopon/data/models/login_model.dart';
import 'package:koopon/data/services/login_service.dart';
import 'package:koopon/data/repositories/login_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginRepository _repository;
  final LoginService _loginService = LoginService();

  LoginViewModel({LoginRepository? repository})
      : _repository = repository ?? LoginRepository();

  LoginModel _state = const LoginModel(email: '', password: '');

  LoginModel get state => _state;

  // Update email
  void updateEmail(String email) {
    _state = _state.copyWith(email: email, errorMessage: null);
    notifyListeners();
  }

  // Update password
  void updatePassword(String password) {
    _state = _state.copyWith(password: password, errorMessage: null);
    notifyListeners();
  }

  // Perform login
  Future<bool> login(String email, String password) async {
    try {
      await _loginService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (error) {
      print('Login error: $error');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword() async {
    if (_state.email.isEmpty) {
      _state = _state.copyWith(errorMessage: 'Please enter your email.');
      notifyListeners();
      return false;
    }

    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      await _repository.resetPassword(_state.email);
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return true;
    } catch (e) {
      String errorMessage = 'Failed to send reset link.';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format.';
            break;
          default:
            errorMessage =
                e.message ?? 'Failed to send reset link. Please try again.';
        }
      }

      _state = _state.copyWith(isLoading: false, errorMessage: errorMessage);
      notifyListeners();
      return false;
    }
  }

  // Check if form is valid
  bool isFormValid() {
    return _state.email.isNotEmpty && _state.password.isNotEmpty;
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _repository.isUserLoggedIn();
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (e) {
      _state = _state.copyWith(errorMessage: 'Logout failed: ${e.toString()}');
      notifyListeners();
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _repository.currentUser;
  }
}
