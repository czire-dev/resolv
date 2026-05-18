import 'package:flutter/material.dart';

/// Design tokens for the auth feature.
/// Consumes ThemeData where possible; defines auth-specific tokens here.
class AuthTheme {
  AuthTheme._();

  // ── Spacing ───────────────────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ── Border Radius ─────────────────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusButton = 14.0;

  // ── Sizing ────────────────────────────────────────────────────────────────
  static const double buttonHeight = 52.0;
  static const double fieldHeight = 56.0;
  static const double logoSize = 56.0;

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> buttonShadow(BuildContext context) => [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // ── Animation Durations ───────────────────────────────────────────────────
  static const Duration fadeIn = Duration(milliseconds: 400);
  static const Duration stagger = Duration(milliseconds: 80);

  // ── Input Decoration ─────────────────────────────────────────────────────
  static InputDecoration fieldDecoration({
    required BuildContext context,
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      hintStyle: text.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant.withOpacity(0.5),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      errorMaxLines: 2,
      filled: true,
      fillColor: colors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: colors.outlineVariant, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: colors.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: colors.error, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
    );
  }
}
