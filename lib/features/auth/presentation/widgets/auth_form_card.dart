import 'package:flutter/material.dart';
import '../utils/auth_theme.dart';

/// Subtle visual section divider used to separate the branding
/// header from the form body in auth screens.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AuthTheme.spacingLg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AuthTheme.radiusLg),
        boxShadow: AuthTheme.cardShadow,
        border: Border.all(
          color: colors.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
