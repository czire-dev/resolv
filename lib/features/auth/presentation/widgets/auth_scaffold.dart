import 'package:flutter/material.dart';
import '../utils/auth_theme.dart';

/// Base scaffold shared by all auth screens.
/// Provides keyboard-safe scrolling, consistent background, and safe areas.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AuthTheme.spacingLg,
              vertical: AuthTheme.spacingXl,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
