import 'package:flutter/material.dart';
import '../utils/auth_theme.dart';

/// Footer row with a prompt label and a tappable action link.
/// Used at the bottom of auth forms for screen-to-screen navigation.
///
/// Example: "Don't have an account?  Sign Up"
class AuthFooterNavigation extends StatelessWidget {
  const AuthFooterNavigation({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onActionTap,
  });

  final String promptText;
  final String actionText;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          promptText,
          style: text.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AuthTheme.spacingXs),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            actionText,
            style: text.bodyMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// A standalone link button used for secondary actions (e.g. "Forgot Password?").
class AuthTextButton extends StatelessWidget {
  const AuthTextButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AuthTheme.spacingXs),
        child: Text(
          label,
          style: text.bodyMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
