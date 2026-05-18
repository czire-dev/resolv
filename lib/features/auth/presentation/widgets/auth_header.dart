import 'package:flutter/material.dart';
import '../utils/auth_theme.dart';

/// Displays the app logo, screen title, and subtitle.
/// Designed to sit at the top of every auth screen.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── App Logo Mark ─────────────────────────────────────────────────
        _LogoMark(primaryColor: colors.primary),
        const SizedBox(height: AuthTheme.spacingXl),

        // ── Screen Title ──────────────────────────────────────────────────
        Text(
          title,
          style: text.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AuthTheme.spacingXs + 2),
          Text(
            subtitle!,
            style: text.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Minimal geometric logo mark for the Barangay app.
class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AuthTheme.logoSize,
      height: AuthTheme.logoSize,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(AuthTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.location_city_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
