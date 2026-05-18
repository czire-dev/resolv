/// Represents all possible UI states for auth screens.
/// Backend logic (Riverpod providers, Firebase) will be wired to these states later.
enum AuthStatus {
  idle,
  loading,
  success,
  validationError,
  authError,
  unexpectedError,
}

class AuthUiState {
  final AuthStatus status;
  final String? errorMessage;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  const AuthUiState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get hasError =>
      status == AuthStatus.authError || status == AuthStatus.unexpectedError;
  bool get isSuccess => status == AuthStatus.success;

  AuthUiState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool clearError = false,
  }) {
    return AuthUiState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }
}
