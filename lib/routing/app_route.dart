import 'package:go_router/go_router.dart';
import 'package:resolv/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:resolv/features/auth/presentation/screens/login_screen.dart';
import 'package:resolv/features/auth/presentation/screens/register_screen.dart';
import 'package:resolv/features/report/user/presentation/screens/create_report_screen.dart';
import 'package:resolv/features/report/user/presentation/screens/report_detail_screen.dart';
import 'package:resolv/features/report/user/presentation/screens/report_list_screen.dart';
import 'package:resolv/features/report/user/repositories/report_mock_data.dart';

/// Routing placeholder for auth screens.
///
/// TODO: Implement full routing with GoRouter once available.
/// Suggested route structure:
///
///   /auth/login           → LoginScreen
///   /auth/register        → RegisterScreen
///   /auth/forgot-password → ForgotPasswordScreen
///   /home                 → HomeScreen (post-auth)
///
/// Example GoRouter setup:
///
final router = GoRouter(
  initialLocation: '/auth/login',
  routes: [
    GoRoute(path: '/auth/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/auth/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(
      path: '/auth/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(path: '/user/create-report', builder: (context, state) => const CreateReportScreen()),
    GoRoute(path: '/user/reports', builder: (context, state) => const ReportListScreen()),
    GoRoute(
      path: '/user/reports/:id',
      builder: (context, state) {
        final reportId = state.pathParameters['id']!;
        for (var element in kMockReports) {
          if (element.id == reportId) {
            return ReportDetailScreen(report: element);
          }
        }
        // Handle case where report is not found
        return ReportDetailScreen(report: kMockReports.first);
      },
    ),
  ],
);

class AppRoute {
  AppRoute._();

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String createReport = '/user/create-report';
  static const String reportList = '/user/reports';
  static const String reportDetail = '/user/reports/:id';

  // TODO: Add protected routes here with redirect logic.
  static const String home = '/home';
}
