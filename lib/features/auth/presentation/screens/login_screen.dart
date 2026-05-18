import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/routing/app_route.dart';
import '../controllers/login_controller.dart';
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

/// Login screen — renders the email/password auth form.
///
/// TODO: Replace [_controller.onSubmit] callback with Riverpod auth controller.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.onNavigateToRegister, this.onNavigateToForgotPassword});

  /// TODO: Replace with GoRouter navigation.
  final VoidCallback? onNavigateToRegister;
  final VoidCallback? onNavigateToForgotPassword;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late final LoginController _controller;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
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
    _passwordFocus.dispose();
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
                title: 'Welcome\nback.',
                subtitle: 'Sign in to your account to continue.',
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

                    // ── Email Field ─────────────────────────────────────
                    AuthTextField(
                      controller: _controller.emailController,
                      label: 'Email address',
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                      autofillHints: const [AutofillHints.email],
                      onChanged: _controller.onEmailChanged,
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                      errorText: _controller.emailError,
                      validator: AuthValidators.validateEmail,
                      enabled: !state.isLoading,
                    ),
                    const SizedBox(height: AuthTheme.spacingMd),

                    // ── Password Field ──────────────────────────────────
                    PasswordField(
                      controller: _controller.passwordController,
                      label: 'Password',
                      isVisible: state.isPasswordVisible,
                      onToggleVisibility: _controller.togglePasswordVisibility,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onChanged: _controller.onPasswordChanged,
                      onFieldSubmitted: (_) => _controller.onSubmit(ref, context),
                      errorText: _controller.passwordError,
                      validator: AuthValidators.validatePassword,
                      enabled: !state.isLoading,
                    ),
                    const SizedBox(height: AuthTheme.spacingSm),

                    // ── Forgot Password ─────────────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: AuthTextButton(
                        label: 'Forgot password?',
                        onTap: () {
                          context.go(AppRoute.forgotPassword);
                        },
                      ),
                    ),
                    const SizedBox(height: AuthTheme.spacingLg),

                    // ── Login Button ────────────────────────────────────
                    AuthButton(
                      label: 'Sign In',
                      isLoading: state.isLoading,
                      enabled: _controller.canSubmit,
                      onPressed: () => _controller.onSubmit(ref, context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AuthTheme.spacingXl),

              // ── Register Navigation ───────────────────────────────────────
              Center(
                child: AuthFooterNavigation(
                  promptText: "Don't have an account?",
                  actionText: 'Sign Up',
                  onActionTap: () {
                    context.go(AppRoute.register);
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
