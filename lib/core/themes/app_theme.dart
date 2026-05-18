import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App-wide theme configuration.
/// Emerald green primary on clean neutral surfaces.
/// Extend with additional sub-themes as the app grows.
class AppTheme {
  AppTheme._();

  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color _emerald = Color(0xFFD72D27); // Primary
  static const Color _emeraldLight = Color(0xFF10B981); // Primary variant
  static const Color _emeraldDark = Color(0xFF047857); // Pressed state

  static const Color _surfaceWhite = Color(0xFFFFFFFF);
  static const Color _surfaceGray50 = Color(0xFFF9FAFB);
  static const Color _surfaceGray100 = Color(0xFFF3F4F6);
  static const Color _onSurface = Color(0xFF111827);
  static const Color _onSurfaceVariant = Color(0xFF6B7280);
  static const Color _outline = Color(0xFFD1D5DB);
  static const Color _error = Color(0xFFDC2626);

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _emerald,
      onPrimary: _surfaceWhite,
      primaryContainer: const Color(0xFFD1FAE5),
      onPrimaryContainer: const Color(0xFF064E3B),
      secondary: _emeraldLight,
      onSecondary: _surfaceWhite,
      secondaryContainer: const Color(0xFFECFDF5),
      onSecondaryContainer: const Color(0xFF065F46),
      tertiary: const Color(0xFF0284C7),
      onTertiary: _surfaceWhite,
      tertiaryContainer: const Color(0xFFE0F2FE),
      onTertiaryContainer: const Color(0xFF0C4A6E),
      error: _error,
      onError: _surfaceWhite,
      errorContainer: const Color(0xFFFEE2E2),
      onErrorContainer: const Color(0xFF7F1D1D),
      surface: _surfaceGray50,
      onSurface: _onSurface,
      surfaceContainerLowest: _surfaceWhite,
      surfaceContainerLow: _surfaceGray100,
      surfaceContainer: const Color(0xFFE5E7EB),
      surfaceContainerHigh: const Color(0xFFD1D5DB),
      surfaceContainerHighest: const Color(0xFF9CA3AF),
      onSurfaceVariant: _onSurfaceVariant,
      outline: _outline,
      outlineVariant: const Color(0xFFE5E7EB),
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: _onSurface,
      onInverseSurface: _surfaceWhite,
      inversePrimary: _emeraldLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _surfaceGray50,
      fontFamily: 'Nunito', // TODO: Add Nunito or preferred font via pubspec.
      textTheme: _buildTextTheme(colorScheme),
      inputDecorationTheme: const InputDecorationTheme(filled: true),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(elevation: 0)),
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceGray50,
        foregroundColor: _onSurface,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colors) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
        letterSpacing: -1,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: colors.onSurface),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: colors.onSurface),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
        letterSpacing: 0.1,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colors.onSurfaceVariant,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colors.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}
