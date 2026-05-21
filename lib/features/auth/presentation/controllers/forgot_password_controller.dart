import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resolv/features/auth/repositories/auth_repository.dart';
import '../states/auth_ui_state.dart';
import '../utils/auth_validators.dart';

/// Manages local UI state for the Forgot Password screen.
///
/// TODO: Connect [onSubmit] to Riverpod auth controller once backend is ready.
class ForgotPasswordController extends ChangeNotifier {
  // ── Form ──────────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  // ── UI State ──────────────────────────────────────────────────────────────
  AuthUiState _state = const AuthUiState();
  AuthUiState get state => _state;

  bool _emailTouched = false;

  String? get emailError =>
      _emailTouched ? AuthValidators.validateEmail(emailController.text) : null;

  bool get canSubmit =>
      !_state.isLoading && AuthValidators.validateEmail(emailController.text) == null;

  // ── Listeners ─────────────────────────────────────────────────────────────

  void onEmailChanged(String _) {
    _emailTouched = true;
    _clearErrorIfPresent();
    notifyListeners();
  }

  void onEmailUnfocus() {
    _emailTouched = true;
    notifyListeners();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> onSubmit(WidgetRef ref, BuildContext context) async {
    _emailTouched = true;

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _state = _state.copyWith(status: AuthStatus.validationError);
      notifyListeners();
      return;
    }

    // TODO: Connect to Riverpod auth controller.
    // Example: ref.read(authControllerProvider.notifier)
    //            .sendPasswordResetEmail(emailController.text.trim())
    _setLoading();

    try {
      print('Email: ${emailController.text.trim()}');
      final result = await ref
          .read(authRepositoryProvider)
          .sendPasswordResetEmail(emailController.text.trim());
      print('Result: $result');
      if (result.isSuccess) {
        _setSuccess();
      } else {
        setAuthError(result.error?.message ?? "Failed to send reset email. Please try again.");
      }
    } catch (e) {
      print('Error sending password reset email: $e');
      setUnexpectedError("An unexpected error occurred. Please try again.");
      return;
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

  void _setSuccess() {
    _state = _state.copyWith(status: AuthStatus.success);
    notifyListeners();
  }

  void _setIdle() {
    _state = _state.copyWith(status: AuthStatus.idle);
    notifyListeners();
  }

  void _clearErrorIfPresent() {
    if (_state.hasError) clearError();
  }

  /// TODO: Remove once backend is integrated.
  Future<void> _simulateNetworkDelay() => Future.delayed(const Duration(milliseconds: 1200));

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
