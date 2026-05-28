import 'package:flutter/material.dart';

class WorkInProgressScreenArgs {
  const WorkInProgressScreenArgs({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

/// A reusable placeholder screen for features that are not yet implemented.
class WorkInProgressScreen extends StatelessWidget {
  const WorkInProgressScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth > 520 ? 420.0 : constraints.maxWidth - 32;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 144,
                        height: 144,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.45),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 108,
                              height: 108,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Icon(icon, size: 56, color: colorScheme.primary),
                            Positioned(
                              right: 18,
                              bottom: 18,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(0.25),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.access_time_rounded,
                                  size: 18,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Coming Soon',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: 160,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Back'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
