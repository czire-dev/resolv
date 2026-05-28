// lib/routing/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/core/enums/user_role.dart';
import 'package:resolv/features/auth/presentation/controllers/auth_controller.dart';
import 'package:resolv/features/profile/presentation/screens/profile_screen.dart';
import 'package:resolv/features/report/admin/screens/admin_dashboard_screen.dart';
import 'package:resolv/features/report/admin/screens/admin_report_detail_screen.dart';
import 'package:resolv/features/report/admin/screens/admin_incident_detail_screen.dart';
import 'package:resolv/features/report/user/screens/home_screen.dart';
import 'package:resolv/features/report/user/screens/incident_list_screen.dart';
import 'package:resolv/features/report/user/screens/incident_detail_screen.dart';
import 'package:resolv/shared/screens/work_in_progress_screen.dart';
import '../features/report/providers/user_report_providers.dart';
import 'package:resolv/features/report/user/screens/create_report_screen.dart';
import 'package:resolv/features/report/user/screens/report_detail_screen.dart';
import 'package:resolv/features/report/user/screens/report_list_screen.dart';
import 'package:resolv/features/auth/presentation/screens/login_screen.dart';
import 'package:resolv/features/auth/presentation/screens/register_screen.dart';
import 'package:resolv/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/models/report_ui_model.dart';
import 'package:resolv/routing/app_routes.dart';
import 'package:resolv/routing/router_notifier.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider.notifier);

  final router = GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true, // remove before production
    // refreshListenable: GoRouter re-runs redirect() whenever this fires.
    // RouterNotifier fires whenever auth state changes.
    refreshListenable: notifier,
    redirect: (context, state) {
      // Read current auth state — NEVER watch inside redirect (not a widget)
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      // ── 1. Auth still loading ──────────────────────────
      // Don't redirect yet. Let the splash/loading state render.
      // Returning null means "stay where you are".
      if (authState.isLoading || authState.hasError) return null;

      final user = authState.value;
      final isAuthenticated = user != null;

      print('User: ${user?.email}, Role: ${user?.role}, Location: $location');

      // Convenience flags
      final isOnAuthRoute = location.startsWith('/auth');
      final isOnAdminRoute = location.startsWith('/admin');
      final isOnUserRoute = location.startsWith('/user');

      // ── 2. Unauthenticated → protect all non-auth routes ──
      if (!isAuthenticated) {
        // Already on an auth screen — let them stay (avoids redirect loop)
        if (isOnAuthRoute) return null;
        // Trying to access any protected route → send to login
        return AppRoutes.login;
      }

      // ── 3. Authenticated → prevent access to auth screens ──
      // A logged-in user navigating to /auth/login should be bounced
      // to their role's home screen.
      if (isAuthenticated && isOnAuthRoute) {
        return AppRoutes.homeForRole(user.role);
      }

      // ── 4. Role guard: residents cannot access /admin/* ──
      if (isAuthenticated && isOnAdminRoute && user.role != UserRole.admin) {
        // Resident trying to access admin → send them to their own home
        return AppRoutes.userHome;
      }

      // ── 5. Role guard: admins landing on /user/* ──────────
      // Optional but clean: redirect admins away from resident screens.
      // Remove this block if you want admins to browse as residents too.
      if (isAuthenticated && isOnUserRoute && user.role == UserRole.admin) {
        return AppRoutes.adminReports;
      }

      // ── 6. Everything else: no redirect needed ────────────
      return null;
    },

    routes: [
      // ── Auth routes (unauthenticated) ──────────────────
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(path: AppRoutes.profile, builder: (context, state) => const ProfileScreen()),

      // ── Resident routes ────────────────────────────────
      GoRoute(path: AppRoutes.userHome, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.userIncidents,
        builder: (context, state) => const UserAllIncidentsScreen(),
        routes: [
          GoRoute(
            path: ':incidentId',
            builder: (context, state) {
              final incidentId = state.pathParameters['incidentId']!;
              return UserIncidentDetailScreen(incidentId: incidentId);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.userReports,
        builder: (context, state) => const ReportListScreen(),
        routes: [
          GoRoute(
            // Nested under /user/reports — full path: /user/reports/:id
            path: ':id',
            builder: (context, state) {
              final reportId = state.pathParameters['id']!;
              final report = state.extra as ReportUiModel?;

              if (report != null) return ReportDetailScreen(report: report);

              final future = ref.read(reportRepositoryProvider).fetchReportById(reportId);

              return FutureBuilder<Result<ReportModel>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Scaffold(
                      body: SafeArea(child: Center(child: CircularProgressIndicator())),
                    );
                  }

                  final result = snapshot.data;
                  if (result == null || result.isFailure || result.data == null) {
                    return Scaffold(
                      body: SafeArea(
                        child: Center(child: Text(result?.error?.message ?? 'Report not found')),
                      ),
                    );
                  }

                  final fetchedReport = result.data!;
                  final uiReport = ReportUiModel(
                    id: fetchedReport.id,
                    title: fetchedReport.title,
                    description: fetchedReport.description,
                    category: fetchedReport.category,
                    status: fetchedReport.status,
                    submittedAt: fetchedReport.submittedAt,
                    submittedByName: fetchedReport.submittedByName,
                    address: fetchedReport.address,
                    imageUrl: fetchedReport.imageUrl,
                    updatedAt: fetchedReport.updatedAt,
                  );

                  return ReportDetailScreen(report: uiReport);
                },
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createReport,
        builder: (context, state) =>
            CreateReportScreen(onSubmitSuccess: () => {context.go(AppRoutes.userReports)}),
      ),

      // ── Admin routes ───────────────────────────────────
      GoRoute(
        path: AppRoutes.adminReports,
        // builder: (context, state) => const AdminReportListScreen(),
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            // Full path: /admin/reports/:reportId
            path: ':reportId',
            builder: (context, state) {
              final reportId = state.pathParameters['reportId']!;
              return AdminReportDetailScreen(reportId: reportId);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.adminAllReports,
        builder: (context, state) => const AdminReportsScreen(),
      ),

      // ── Admin Incident routes ───────────────────────────
      GoRoute(
        path: AppRoutes.adminIncidents,
        builder: (context, state) => const Scaffold(
          body: SafeArea(child: Center(child: Text('Incident List - Coming Soon'))),
        ),
        routes: [
          GoRoute(
            // Full path: /admin/incidents/:incidentId
            path: ':incidentId',
            builder: (context, state) {
              final incidentId = state.pathParameters['incidentId']!;
              return AdminIncidentDetailScreen(incidentId: incidentId);
            },
          ),
        ],
      ),

      // ── Work In Progress ───────────────────────────────
      GoRoute(
        path: AppRoutes.workInProgress,
        builder: (context, state) {
          final args = state.extra is WorkInProgressScreenArgs
              ? state.extra as WorkInProgressScreenArgs
              : null;

          return WorkInProgressScreen(
            title: args?.title ?? 'Work In Progress',
            description:
                args?.description ?? 'This feature is being polished and will be available soon.',
            icon: args?.icon ?? Icons.construction_outlined,
          );
        },
      ),
    ],
  );

  // Dispose the router when the provider is disposed
  ref.onDispose(router.dispose);

  return router;
});
