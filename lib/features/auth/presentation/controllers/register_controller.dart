import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/features/auth/presentation/controllers/auth_controller.dart';
import 'package:resolv/routing/app_route.dart';
import '../states/auth_ui_state.dart';
import '../utils/auth_validators.dart';

/// Manages local UI state for the Register screen.
///
/// TODO: Connect [onSubmit] to Riverpod auth controller once backend is ready.
class RegisterController extends ChangeNotifier {
  // ── Form ──────────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ── UI State ──────────────────────────────────────────────────────────────
  AuthUiState _state = const AuthUiState();
  AuthUiState get state => _state;

  // ── Inline validation flags ───────────────────────────────────────────────
  bool _nameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmTouched = false;

  // ── Inline errors ─────────────────────────────────────────────────────────

  String? get nameError =>
      _nameTouched ? AuthValidators.validateDisplayName(displayNameController.text) : null;

  String? get emailError =>
      _emailTouched ? AuthValidators.validateEmail(emailController.text) : null;

  String? get passwordError =>
      _passwordTouched ? AuthValidators.validatePasswordStrength(passwordController.text) : null;

  String? get confirmPasswordError => _confirmTouched
      ? AuthValidators.validateConfirmPassword(
          confirmPasswordController.text,
          passwordController.text,
        )
      : null;

  int get passwordStrength => AuthValidators.passwordStrengthScore(passwordController.text);

  bool get canSubmit =>
      !_state.isLoading &&
      AuthValidators.validateDisplayName(displayNameController.text) == null &&
      AuthValidators.validateEmail(emailController.text) == null &&
      AuthValidators.validatePasswordStrength(passwordController.text) == null &&
      AuthValidators.validateConfirmPassword(
            confirmPasswordController.text,
            passwordController.text,
          ) ==
          null;

  // ── Listeners ─────────────────────────────────────────────────────────────

  void onNameChanged(String _) {
    _nameTouched = true;
    _clearErrorIfPresent();
    notifyListeners();
  }

  void onEmailChanged(String _) {
    _emailTouched = true;
    _clearErrorIfPresent();
    notifyListeners();
  }

  void onPasswordChanged(String _) {
    _passwordTouched = true;
    if (_confirmTouched) notifyListeners(); // Re-validate confirm too.
    _clearErrorIfPresent();
    notifyListeners();
  }

  void onConfirmPasswordChanged(String _) {
    _confirmTouched = true;
    _clearErrorIfPresent();
    notifyListeners();
  }

  void onNameUnfocus() {
    _nameTouched = true;
    notifyListeners();
  }

  void onEmailUnfocus() {
    _emailTouched = true;
    notifyListeners();
  }

  void onPasswordUnfocus() {
    _passwordTouched = true;
    notifyListeners();
  }

  void onConfirmUnfocus() {
    _confirmTouched = true;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _state = _state.copyWith(isPasswordVisible: !_state.isPasswordVisible);
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _state = _state.copyWith(isConfirmPasswordVisible: !_state.isConfirmPasswordVisible);
    notifyListeners();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> onSubmit(WidgetRef ref, BuildContext context) async {
    _nameTouched = true;
    _emailTouched = true;
    _passwordTouched = true;
    _confirmTouched = true;

    if (!formKey.currentState!.validate()) {
      _state = _state.copyWith(status: AuthStatus.validationError);
      notifyListeners();
      return;
    }

    // TODO: Connect to Riverpod auth controller.
    // Example: ref.read(authControllerProvider.notifier).register(
    //   displayName: displayNameController.text.trim(),
    //   email: emailController.text.trim(),
    //   password: passwordController.text,
    // )
    _setLoading();

    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            displayNameController.text.trim(),
            emailController.text.trim(),
            passwordController.text,
          );
      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
        setAuthError(authState.error?.toString() ?? 'Registration failed. Please try again.');
        return;
      }

      _state = _state.copyWith(status: AuthStatus.success);
      notifyListeners();
      context.go(AppRoute.login);
    } catch (e) {
      setUnexpectedError(e.toString());
    } finally {
      if (_state.status == AuthStatus.loading) _setIdle();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void setAuthError(String message) {
    _state = _state.copyWith(status: AuthStatus.authError, errorMessage: message);
    notifyListeners();
  }

  void setUnexpectedError(String message) {
    _state = _state.copyWith(status: AuthStatus.unexpectedError, errorMessage: message);
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(status: AuthStatus.idle, clearError: true);
    notifyListeners();
  }

  void _setLoading() {
    _state = _state.copyWith(status: AuthStatus.loading, clearError: true);
    notifyListeners();
  }

  void _setIdle() {
    _state = _state.copyWith(status: AuthStatus.idle);
    notifyListeners();
  }

  void _clearErrorIfPresent() {
    if (_state.hasError) clearError();
  }

  @override
  void dispose() {
    displayNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
