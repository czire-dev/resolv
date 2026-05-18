import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/routing/app_route.dart';
import '../controllers/forgot_password_controller.dart';
import '../states/auth_ui_state.dart';
import '../utils/auth_theme.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/error_banner.dart';

/// Forgot Password screen — collects email and triggers a reset email.
///
/// TODO: Connect [_controller.onSubmit] to Riverpod auth controller.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late final ForgotPasswordController _controller;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = ForgotPasswordController();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return AuthScaffold(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Back Button ───────────────────────────────────────────────
            _BackButton(onTap: () => context.go(AppRoute.login)),
            const SizedBox(height: AuthTheme.spacingLg),

            // ── Header ────────────────────────────────────────────────────
            const AuthHeader(
              title: 'Reset your\npassword.',
              subtitle: 'Enter your email and we\'ll send you instructions to reset your password.',
            ),
            const SizedBox(height: AuthTheme.spacingXl),

            // ── Content ───────────────────────────────────────────────────
            AnimatedSwitcher(
              duration: AuthTheme.fadeIn,
              child: state.isSuccess
                  ? _SuccessView(
                      key: const ValueKey('success'),
                      email: _controller.emailController.text.trim(),
                      onBackToLogin: () => context.go(AppRoute.login),
                    )
                  : _FormView(key: const ValueKey('form'), controller: _controller, state: state),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form View ─────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  const _FormView({super.key, required this.controller, required this.state});

  final ForgotPasswordController controller;
  final AuthUiState state;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: AuthFormCard(
        child: Column(
          children: [
            // ── Error Banner ──────────────────────────────────────────────
            if (state.hasError && state.errorMessage != null) ...[
              ErrorBanner(message: state.errorMessage!, onDismiss: controller.clearError),
              const SizedBox(height: AuthTheme.spacingMd),
            ],

            // ── Email Field ───────────────────────────────────────────────
            AuthTextField(
              controller: controller.emailController,
              label: 'Email address',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
              autofillHints: const [AutofillHints.email],
              onChanged: controller.onEmailChanged,
              onFieldSubmitted: (_) => controller.onSubmit(),
              errorText: controller.emailError,
              validator: AuthValidators.validateEmail,
              enabled: !state.isLoading,
            ),
            const SizedBox(height: AuthTheme.spacingXl),

            // ── Submit Button ─────────────────────────────────────────────
            AuthButton(
              label: 'Send Reset Link',
              isLoading: state.isLoading,
              enabled: controller.canSubmit,
              onPressed: controller.onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Success View ──────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({super.key, required this.email, required this.onBackToLogin});

  final String email;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AuthFormCard(
      child: Column(
        children: [
          // ── Icon ──────────────────────────────────────────────────────────
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
            child: Icon(Icons.mark_email_read_outlined, color: colors.primary, size: 28),
          ),
          const SizedBox(height: AuthTheme.spacingMd),

          // ── Text ──────────────────────────────────────────────────────────
          Text(
            'Check your email',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AuthTheme.spacingSm),
          Text(
            'We sent password reset instructions to\n$email',
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AuthTheme.spacingXl),

          // ── Back to Login ─────────────────────────────────────────────────
          AuthButton(label: 'Back to Sign In', onPressed: onBackToLogin),
        ],
      ),
    );
  }
}

// ── Back Button ───────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AuthTheme.radiusSm + 2),
          border: Border.all(color: colors.outlineVariant, width: 1),
        ),
        child: Icon(Icons.arrow_back_rounded, color: colors.onSurface, size: 20),
      ),
    );
  }
}
