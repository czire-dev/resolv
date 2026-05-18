import 'package:flutter/material.dart';
import '../utils/auth_theme.dart';

/// Primary CTA button for auth screens.
/// Transitions between idle and loading states.
class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isActive = enabled && !isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: AuthTheme.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AuthTheme.radiusButton),
        boxShadow: isActive ? AuthTheme.buttonShadow(context) : [],
      ),
      child: SizedBox(
        width: double.infinity,
        height: AuthTheme.buttonHeight,
        child: FilledButton(
          onPressed: isActive ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            disabledBackgroundColor: colors.primary.withOpacity(0.45),
            foregroundColor: colors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AuthTheme.radiusButton),
            ),
            elevation: 0,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.onPrimary.withOpacity(0.9),
                    ),
                  )
                : Text(
                    key: const ValueKey('label'),
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isActive
                              ? colors.onPrimary
                              : colors.onPrimary.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
