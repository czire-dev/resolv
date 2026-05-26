// lib/core/ui/ui_constants.dart
// RESOLV — Design System Constants

import 'package:flutter/material.dart';

/// ── Spacing ────────────────────────────────────────────────────────────────
abstract final class Sp {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// ── Border Radii ──────────────────────────────────────────────────────────
abstract final class Radii {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;

  static BorderRadius card = BorderRadius.circular(lg);
  static BorderRadius chip = BorderRadius.circular(full);
  static BorderRadius button = BorderRadius.circular(md);
  static BorderRadius dialog = BorderRadius.circular(xl);
}

/// ── Status Colors ─────────────────────────────────────────────────────────
abstract final class StatusColors {
  // Report / Incident statuses
  static const Color pending = Color(0xFFF59E0B); // amber
  static const Color underReview = Color(0xFF6366F1); // indigo
  static const Color inProgress = Color(0xFF3B82F6); // blue
  static const Color resolved = Color(0xFF10B981); // emerald
  static const Color rejected = Color(0xFF6B7280); // gray

  static const Color pendingBg = Color(0xFFFEF3C7);
  static const Color underReviewBg = Color(0xFFEEF2FF);
  static const Color inProgressBg = Color(0xFFEFF6FF);
  static const Color resolvedBg = Color(0xFFD1FAE5);
  static const Color rejectedBg = Color(0xFFF3F4F6);
}

/// ── Priority Colors ───────────────────────────────────────────────────────
abstract final class PriorityColors {
  static const Color critical = Color(0xFFDC2626); // red
  static const Color high = Color(0xFFF97316); // orange
  static const Color medium = Color(0xFFF59E0B); // amber
  static const Color low = Color(0xFF10B981); // green

  static const Color criticalBg = Color(0xFFFEE2E2);
  static const Color highBg = Color(0xFFFFF7ED);
  static const Color mediumBg = Color(0xFFFEF3C7);
  static const Color lowBg = Color(0xFFD1FAE5);
}

/// ── Category Colors ───────────────────────────────────────────────────────
abstract final class CategoryColors {
  static const Color infrastructure = Color(0xFF6366F1);
  static const Color environment = Color(0xFF10B981);
  static const Color safety = Color(0xFFEF4444);
  static const Color utilities = Color(0xFFF59E0B);
  static const Color health = Color(0xFF8B5CF6);
  static const Color other = Color(0xFF6B7280);

  static const Color infrastructureBg = Color(0xFFEEF2FF);
  static const Color environmentBg = Color(0xFFD1FAE5);
  static const Color safetyBg = Color(0xFFFEE2E2);
  static const Color utilitiesBg = Color(0xFFFEF3C7);
  static const Color healthBg = Color(0xFFEDE9FE);
  static const Color otherBg = Color(0xFFF3F4F6);
}

/// ── Elevation / Shadow ────────────────────────────────────────────────────
abstract final class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevated = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.10),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
