import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/features/auth/presentation/controllers/auth_controller.dart';
import 'package:resolv/routing/app_route.dart';
import '../states/auth_ui_state.dart';
import '../utils/auth_validators.dart';

/// Manages local UI state for the Login screen.
/// No backend logic here — pure form & UI state management.
///
/// TODO: Replace [_onLoginSubmit] stub with Riverpod auth controller call
/// once the auth domain layer is implemented.
///
class LoginController extends ChangeNotifier {
  // ── Form ──────────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ── UI State ──────────────────────────────────────────────────────────────
  AuthUiState _state = const AuthUiState();
  AuthUiState get state => _state;

  // ── Inline validation flags ───────────────────────────────────────────────
  bool _emailTouched = false;
  bool _passwordTouched = false;

  String? get emailError =>
      _emailTouched ? AuthValidators.validateEmail(emailController.text) : null;

  String? get passwordError =>
      _passwordTouched ? AuthValidators.validatePassword(passwordController.text) : null;

  bool get canSubmit =>
      !_state.isLoading &&
      AuthValidators.validateEmail(emailController.text) == null &&
      AuthValidators.validatePassword(passwordController.text) == null;

  // ── Listeners ─────────────────────────────────────────────────────────────

  void onEmailChanged(String _) {
    _emailTouched = true;
    _clearErrorIfPresent();
    notifyListeners();
  }

  void onPasswordChanged(String _) {
    _passwordTouched = true;
    _clearErrorIfPresent();
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

  void togglePasswordVisibility() {
    _state = _state.copyWith(isPasswordVisible: !_state.isPasswordVisible);
    notifyListeners();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> onSubmit(WidgetRef ref, BuildContext context) async {
    _emailTouched = true;
    _passwordTouched = true;

    if (!formKey.currentState!.validate()) {
      _state = _state.copyWith(status: AuthStatus.validationError);
      notifyListeners();
      return;
    }

    // TODO: Connect to Riverpod auth controller.
    // Example: ref.read(authControllerProvider.notifier).login(email, password)
    _setLoading();

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(emailController.text.trim(), passwordController.text);

      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
        setAuthError(authState.error?.toString() ?? 'Login failed. Please try again.');
        return;
      }

      _state = _state.copyWith(status: AuthStatus.success);
      notifyListeners();
      context.go(AppRoute.reportList);
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
