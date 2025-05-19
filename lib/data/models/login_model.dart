
class LoginModel {
  final String email;
  final String password;
  final String? errorMessage;
  final bool isLoading;

  LoginModel({
    required this.email,
    required this.password,
    this.errorMessage,
    this.isLoading = false,
  });

  // Create a copy of this model with updated fields
  LoginModel copyWith({
    String? email,
    String? password,
    String? errorMessage,
    bool? isLoading,
  }) {
    return LoginModel(
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}