import 'package:flutter/material.dart';
import '../utils/auth_theme.dart';

/// Animated inline error banner displayed at the top of auth forms.
/// Appears when auth or unexpected errors occur.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AnimatedSlide(
      offset: Offset.zero,
      duration: AuthTheme.fadeIn,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AuthTheme.spacingMd,
          vertical: AuthTheme.spacingMd - 2,
        ),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(AuthTheme.radiusMd),
          border: Border.all(
            color: colors.error.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colors.onErrorContainer,
              size: 18,
            ),
            const SizedBox(width: AuthTheme.spacingSm + 2),
            Expanded(
              child: Text(
                message,
                style: text.bodySmall?.copyWith(
                  color: colors.onErrorContainer,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: AuthTheme.spacingXs),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: colors.onErrorContainer.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Success banner for positive feedback (e.g. password reset email sent).
class SuccessBanner extends StatelessWidget {
  const SuccessBanner({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AuthTheme.spacingMd,
        vertical: AuthTheme.spacingMd - 2,
      ),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AuthTheme.radiusMd),
        border: Border.all(
          color: colors.primary.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: colors.onPrimaryContainer,
            size: 18,
          ),
          const SizedBox(width: AuthTheme.spacingSm + 2),
          Expanded(
            child: Text(
              message,
              style: text.bodySmall?.copyWith(
                color: colors.onPrimaryContainer,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
