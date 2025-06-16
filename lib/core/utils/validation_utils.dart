// lib/core/utils/validation_utils.dart
class ValidationUtils {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Card number is required';
    }
    
    final digitsOnly = value.replaceAll(' ', '');
    if (digitsOnly.length != 16) {
      return 'Card number must be 16 digits';
    }
    return null;
  }

  static String? validateExpiryDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expiry date is required';
    }
    
    if (value.length != 5 || !value.contains('/')) {
      return 'Enter date as MM/YY';
    }
    
    final parts = value.split('/');
    if (parts.length != 2) {
      return 'Enter date as MM/YY';
    }
    
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null || month < 1 || month > 12) {
      return 'Enter a valid date';
    }
    
    final now = DateTime.now();
    final expiryDate = DateTime(2000 + year, month);
    
    if (expiryDate.isBefore(DateTime(now.year, now.month))) {
      return 'Card has expired';
    }
    
    return null;
  }

  static String? validateCVC(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CVC is required';
    }
    
    if (value.length != 3) {
      return 'CVC must be 3 digits';
    }
    return null;
  }
}