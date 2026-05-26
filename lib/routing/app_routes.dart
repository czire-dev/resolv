import 'package:resolv/core/enums/user_role.dart';

/// All route path constants for RESOLV.
///
/// Usage:
///   context.go(AppRoutes.login);
///   context.push(AppRoutes.adminReportDetail);
///
/// Path parameters use the :param syntax for GoRouter.
/// Build full paths with named helpers below.
abstract final class AppRoutes {
  // ── Auth ──────────────────────────────────────────────
  static const String login          = '/auth/login';
  static const String register       = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';

  // ── Resident ──────────────────────────────────────────
  static const String userReports       = '/user/reports';
  static const String userReportDetail  = '/user/reports/:id';
  static const String createReport      = '/user/create-report';

  // ── Admin ─────────────────────────────────────────────
  static const String adminReports      = '/admin/reports';
  static const String adminReportDetail = '/admin/reports/:reportId';

  // ── Helpers: build concrete paths with parameters ─────

  /// e.g. AppRoutes.userReportPath('abc123') → '/user/reports/abc123'
  static String userReportPath(String id) => '/user/reports/$id';

  /// e.g. AppRoutes.adminReportPath('abc123') → '/admin/reports/abc123'
  static String adminReportPath(String reportId) => '/admin/reports/$reportId';

  // ── Role-based home routes ────────────────────────────

  /// The landing page after login, based on role.
  /// Used by redirect logic — single source of truth.
  static String homeForRole(UserRole role) {
    return switch (role) {
      UserRole.admin    => adminReports,
      UserRole.user => userReports,
    };
  }
}