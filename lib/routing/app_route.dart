import 'package:go_router/go_router.dart';
import 'package:resolv/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:resolv/features/auth/presentation/screens/login_screen.dart';
import 'package:resolv/features/auth/presentation/screens/register_screen.dart';

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
  ],
);

class AppRoute {
  AppRoute._();

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';

  // TODO: Add protected routes here with redirect logic.
  static const String home = '/home';
}
