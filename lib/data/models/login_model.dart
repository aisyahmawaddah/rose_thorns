class LoginModel {
  final String email;
  final String password;
  final String? errorMessage;
  final bool isLoading;

  const LoginModel({
    this.email = '',
    this.password = '',
    this.errorMessage,
    this.isLoading = false,
  });

  // Create a copy of this model with updated fields
  LoginModel copyWith({
    String? email,
    String? password,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
  }) {
    return LoginModel(
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Helper method to check if there's an error
  bool get hasError => errorMessage?.isNotEmpty == true;

  @override
  String toString() {
    return 'LoginModel(email: $email, password: [HIDDEN], errorMessage: $errorMessage, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginModel &&
        other.email == email &&
        other.password == password &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return email.hashCode ^
        password.hashCode ^
        errorMessage.hashCode ^
        isLoading.hashCode;
  }

  
}