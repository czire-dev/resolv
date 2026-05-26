import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resolv/features/auth/presentation/controllers/auth_controller.dart';
import 'package:resolv/models/user_model.dart';

/// Bridges Riverpod auth state to GoRouter's refreshListenable.
///
/// GoRouter calls redirect() whenever this notifier fires.
/// This notifier fires whenever auth state changes.
///
/// Pattern: AsyncNotifier (auth) → RouterNotifier → GoRouter redirect
class RouterNotifier extends AsyncNotifier<void> implements Listenable {
  // GoRouter calls this to register itself as a listener
  VoidCallback? _routerListener;

  @override
  Future<void> build() async {
    // Watch auth state — when it changes, this build() re-runs
    ref.listen<AsyncValue<UserModel?>>(authControllerProvider, (_, __) {
      // Auth state changed → tell GoRouter to re-evaluate redirects
      _routerListener?.call();
    });
  }

  // ── Listenable interface ───────────────────────────────

  @override
  void addListener(VoidCallback listener) {
    _routerListener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    _routerListener = null;
  }
}

final routerNotifierProvider = AsyncNotifierProvider<RouterNotifier, void>(RouterNotifier.new);
