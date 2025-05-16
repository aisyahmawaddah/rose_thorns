// login_viewmodel.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koopon/data/models/login_model.dart';
import 'package:koopon/data/repositories/login_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginRepository _repository;
  
  LoginViewModel({LoginRepository? repository}) 
      : _repository = repository ?? LoginRepository();
  
  LoginModel _state = LoginModel(email: '', password: '');
  
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
  
  // Reset error message
  void resetError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }
  
  // Perform login
  Future<bool> login() async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();
    
    try {
      await _repository.login(_state.email, _state.password);
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return true;
    } catch (e) {
      String errorMessage = 'Login failed';
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          default:
            errorMessage = e.message ?? 'Login failed. Please try again.';
        }
      }
      
      _state = _state.copyWith(isLoading: false, errorMessage: errorMessage);
      notifyListeners();
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
      _state = _state.copyWith(
        isLoading: false, 
        errorMessage: 'Failed to send reset link. Please check your email and try again.'
      );
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
}