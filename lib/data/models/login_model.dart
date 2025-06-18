import 'package:cloud_firestore/cloud_firestore.dart';

class LoginModel {
  final String email;
  final String password;
  final String? errorMessage;
  final bool isLoading;

  // Extended fields for user data from Firestore
  final String? id;
  final String? displayName;
  final String? universityName;
  final String? role;
  final DateTime? dateCreated;
  final bool? isActive;

  const LoginModel({
    this.email = '',
    this.password = '',
    this.errorMessage,
    this.isLoading = false,
    // Extended fields
    this.id,
    this.displayName,
    this.universityName,
    this.role = 'buyer',
    this.dateCreated,
    this.isActive = true,
  });

  // Create a copy of this model with updated fields
  LoginModel copyWith({
    String? email,
    String? password,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
    // Extended fields
    String? id,
    String? displayName,
    String? universityName,
    String? role,
    DateTime? dateCreated,
    bool? isActive,
  }) {
    return LoginModel(
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
      // Extended fields
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      universityName: universityName ?? this.universityName,
      role: role ?? this.role,
      dateCreated: dateCreated ?? this.dateCreated,
      isActive: isActive ?? this.isActive,
    );
  }

  // Convert Firestore document to LoginModel (for user data)
  static LoginModel fromFirestoreMap(Map<String, dynamic> data, String id) {
    try {
      return LoginModel(
        id: id,
        email: data['email'] ?? '',
        displayName: data['displayName'],
        universityName: data['universityName'],
        role: data['role'] ?? 'buyer',
        dateCreated: data['dateCreated'] != null
            ? (data['dateCreated'] as Timestamp).toDate()
            : null,
        isActive: data['isActive'] ?? true,
        // Login fields set to defaults for user data
        password: '', // Not stored for security
        isLoading: false,
      );
    } catch (e) {
      print('Error creating LoginModel from Firestore map: $e');
      // Return a default LoginModel instead of null
      return LoginModel(
        id: id,
        email: data['email'] ?? 'unknown@example.com',
        displayName: 'Unknown User',
        role: 'buyer',
        isActive: true,
      );
    }
  }

  // Convert LoginModel to map for Firestore (for user data)
  Map<String, dynamic> toFirestoreMap() {
    return {
      'email': email,
      'displayName': displayName,
      'universityName': universityName,
      'role': role,
      'dateCreated': dateCreated != null
          ? Timestamp.fromDate(dateCreated!)
          : FieldValue.serverTimestamp(),
      'isActive': isActive,
    };
  }

  // Helper method to check if there's an error
  bool get hasError => errorMessage?.isNotEmpty == true;

  // Helper method to check if this is a user data model (has ID)
  bool get isUserData => id != null;

  // Helper method to check if this is a login state model
  bool get isLoginState => id == null;

  @override
  String toString() {
    if (isUserData) {
      return 'LoginModel(id: $id, email: $email, role: $role, displayName: $displayName, isActive: $isActive)';
    } else {
      return 'LoginModel(email: $email, password: [HIDDEN], errorMessage: $errorMessage, isLoading: $isLoading)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginModel &&
        other.email == email &&
        other.password == password &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading &&
        other.id == id &&
        other.displayName == displayName &&
        other.universityName == universityName &&
        other.role == role &&
        other.dateCreated == dateCreated &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return email.hashCode ^
        password.hashCode ^
        errorMessage.hashCode ^
        isLoading.hashCode ^
        id.hashCode ^
        displayName.hashCode ^
        universityName.hashCode ^
        role.hashCode ^
        dateCreated.hashCode ^
        isActive.hashCode;
  }
}
