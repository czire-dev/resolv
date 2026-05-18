import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/routing/app_route.dart';
import '../controllers/register_controller.dart';
import '../utils/auth_theme.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_footer_navigation.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/error_banner.dart';
import '../widgets/password_field.dart';

/// Register screen — collects full name, email, password, and confirm password.
///
/// TODO: Replace [_controller.onSubmit] with Riverpod auth controller call.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.onNavigateToLogin});

  /// TODO: Replace with GoRouter navigation.
  final VoidCallback? onNavigateToLogin;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late final RegisterController _controller;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = RegisterController();
    _controller.addListener(_onStateChanged);

    _fadeController = AnimationController(vsync: this, duration: AuthTheme.fadeIn);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  void _onStateChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    _fadeController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return AuthScaffold(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              const AuthHeader(
                title: 'Create your\naccount.',
                subtitle: 'Join your barangay\'s reporting system.',
              ),
              const SizedBox(height: AuthTheme.spacingXl),

              // ── Form Card ────────────────────────────────────────────────
              AuthFormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Error Banner ────────────────────────────────────
                    if (state.hasError && state.errorMessage != null) ...[
                      ErrorBanner(message: state.errorMessage!, onDismiss: _controller.clearError),
                      const SizedBox(height: AuthTheme.spacingMd),
                    ],

                    // ── Display Name ───────────────────────────────────────
                    AuthTextField(
                      controller: _controller.displayNameController,
                      label: 'Display name',
                      hint: 'Juan dela Cruz',
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      onChanged: _controller.onNameChanged,
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                      errorText: _controller.nameError,
                      validator: AuthValidators.validateDisplayName,
                      enabled: !state.isLoading,
                    ),
                    const SizedBox(height: AuthTheme.spacingMd),

                    // ── Email ───────────────────────────────────────────
                    AuthTextField(
                      controller: _controller.emailController,
                      label: 'Email address',
                      hint: 'you@example.com',
                      prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      focusNode: _emailFocus,
                      autofillHints: const [AutofillHints.email],
                      onChanged: _controller.onEmailChanged,
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                      errorText: _controller.emailError,
                      validator: AuthValidators.validateEmail,
                      enabled: !state.isLoading,
                    ),
                    const SizedBox(height: AuthTheme.spacingMd),

                    // ── Password ────────────────────────────────────────
                    PasswordField(
                      controller: _controller.passwordController,
                      label: 'Password',
                      isVisible: state.isPasswordVisible,
                      onToggleVisibility: _controller.togglePasswordVisibility,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: _controller.onPasswordChanged,
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmFocus),
                      errorText: _controller.passwordError,
                      validator: AuthValidators.validatePasswordStrength,
                      showStrengthIndicator: true,
                      strengthScore: _controller.passwordStrength,
                      enabled: !state.isLoading,
                    ),
                    const SizedBox(height: AuthTheme.spacingMd),

                    // ── Confirm Password ────────────────────────────────
                    PasswordField(
                      controller: _controller.confirmPasswordController,
                      label: 'Confirm password',
                      isVisible: state.isConfirmPasswordVisible,
                      onToggleVisibility: _controller.toggleConfirmPasswordVisibility,
                      focusNode: _confirmFocus,
                      textInputAction: TextInputAction.done,
                      onChanged: _controller.onConfirmPasswordChanged,
                      onFieldSubmitted: (_) => _controller.onSubmit(ref, context),
                      errorText: _controller.confirmPasswordError,
                      validator: (v) => AuthValidators.validateConfirmPassword(
                        v,
                        _controller.passwordController.text,
                      ),
                      enabled: !state.isLoading,
                    ),
                    const SizedBox(height: AuthTheme.spacingXl),

                    // ── Register Button ─────────────────────────────────
                    AuthButton(
                      label: 'Create Account',
                      isLoading: state.isLoading,
                      enabled: _controller.canSubmit,
                      onPressed: () => _controller.onSubmit(ref, context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AuthTheme.spacingXl),

              // ── Login Navigation ──────────────────────────────────────────
              Center(
                child: AuthFooterNavigation(
                  promptText: 'Already have an account?',
                  actionText: 'Sign In',
                  onActionTap: () {
                    context.go(AppRoute.login);
                  },
                ),
              ),
              const SizedBox(height: AuthTheme.spacingMd),
            ],
          ),
        ),
      ),
    );
  }
}
