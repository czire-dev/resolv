// lib/features/home/presentation/screens/home_screen.dart
// RESOLV — Resident Home Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/core/themes/ui_constants.dart';
import 'package:resolv/features/report/providers/incident_providers.dart';
import 'package:resolv/routing/app_routes.dart';
import 'package:resolv/shared/widgets/cards.dart';
import 'package:resolv/shared/widgets/layouts.dart';

const _announcements = [
  (
    title: 'Community Clean-Up Drive This Saturday',
    preview: 'Join us for the monthly clean-up drive at Barangay Plaza.',
    date: 'May 25, 2026',
    pinned: true,
  ),
  (
    title: 'Water Interruption Notice',
    preview: 'Scheduled maintenance on May 28 from 8AM–5PM.',
    date: 'May 24, 2026',
    pinned: false,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar / Header ──
            SliverToBoxAdapter(child: _HomeHeader()),
            // ── Search Bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Sp.base,
                  0,
                  Sp.base,
                  Sp.base,
                ),
                child: SearchBarWidget(
                  hintText: 'Search reports, incidents...',
                  onFilterTap: () {},
                ),
              ),
            ),
            // ── Hero Banner ──
            SliverToBoxAdapter(child: _HeroBanner()),
            // ── Quick Actions ──
            SliverToBoxAdapter(child: _QuickActionsSection()),
            // ── My Report Status ──
            SliverToBoxAdapter(child: _MyReportStatusSection()),
            // ── Recent Incidents ──
            SliverToBoxAdapter(child: _RecentIncidentsSection()),
            // ── Announcements Preview ──
            SliverToBoxAdapter(child: _AnnouncementsPreviewSection()),
            const SliverToBoxAdapter(child: SizedBox(height: Sp.xxxl)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.base, Sp.base, Sp.base, Sp.md),
      child: Row(
        children: [
          // Logo + greeting
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: Radii.button,
                ),
                child: const Center(
                  child: Text(
                    'R',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Sp.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESOLV',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Mabuhay Maruleño! 👋',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Notification
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(borderRadius: Radii.button),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO BANNER
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.base, vertical: Sp.sm),
      child: Container(
        padding: const EdgeInsets.all(Sp.base),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
          borderRadius: Radii.card,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community\nReporting Made Easy',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: Sp.sm),
                  Text(
                    'Your reports help shape a better Marulete.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: Sp.md),
                  Row(
                    children: [
                      _HeroButton(
                        label: 'View Reports',
                        icon: Icons.list_alt_rounded,
                        onTap: () {
                          context.go(AppRoutes.userReports);
                        },
                      ),
                      const SizedBox(width: Sp.sm),
                      _HeroButton(
                        label: 'Report Issue',
                        icon: Icons.add_circle_outline_rounded,
                        filled: true,
                        onTap: () {
                          context.go(AppRoutes.createReport);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: Sp.md),
            Icon(
              Icons.location_city_rounded,
              size: 72,
              color: Colors.white.withOpacity(0.15),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _HeroButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.sm),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: Radii.button,
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: filled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: filled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK ACTIONS
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.base, Sp.base, Sp.base, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Actions'),
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.add_circle_rounded,
                  label: 'Create\nReport',
                  color: theme.colorScheme.primary,
                  bgColor: theme.colorScheme.primary.withOpacity(0.1),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: Sp.sm),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.campaign_rounded,
                  label: 'News &\nAnnouncements',
                  color: const Color(0xFF6366F1),
                  bgColor: const Color(0xFFEEF2FF),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: Sp.sm),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.bar_chart_rounded,
                  label: 'My\nReports',
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFFD1FAE5),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: Sp.sm),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.help_outline_rounded,
                  label: 'Help &\nFAQ',
                  color: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFFEF3C7),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Sp.md, horizontal: Sp.xs),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: Radii.card,
          boxShadow: AppShadows.card,
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(Sp.sm),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: Radii.button,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: Sp.sm),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MY REPORT STATUS
// ─────────────────────────────────────────────────────────────────────────────

class _MyReportStatusSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.base, Sp.xl, Sp.base, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'My Report Summary',
            action: TextButton(onPressed: () {}, child: const Text('View all')),
          ),
          Row(
            children: [
              Expanded(
                child: _StatusCountTile(
                  count: 2,
                  label: 'Pending',
                  color: StatusColors.pending,
                  bg: StatusColors.pendingBg,
                ),
              ),
              const SizedBox(width: Sp.sm),
              Expanded(
                child: _StatusCountTile(
                  count: 1,
                  label: 'In Progress',
                  color: StatusColors.inProgress,
                  bg: StatusColors.inProgressBg,
                ),
              ),
              const SizedBox(width: Sp.sm),
              Expanded(
                child: _StatusCountTile(
                  count: 5,
                  label: 'Resolved',
                  color: StatusColors.resolved,
                  bg: StatusColors.resolvedBg,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCountTile extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color bg;

  const _StatusCountTile({
    required this.count,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Sp.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: Radii.card,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECENT INCIDENTS
// ─────────────────────────────────────────────────────────────────────────────

class _RecentIncidentsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(recentIncidentsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.base, Sp.xl, Sp.base, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recent Incidents',
            subtitle: 'Grouped from community reports',
            action: TextButton(onPressed: () {}, child: const Text('See all')),
          ),
          incidentsAsync.when(
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(vertical: Sp.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.symmetric(vertical: Sp.lg),
              child: Center(
                child: Text(
                  'Failed to load incidents',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
            data: (incidents) {
              if (incidents.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: Sp.lg),
                  child: Center(
                    child: Text(
                      'No recent incidents',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              }
              return Column(
                children: incidents
                    .map(
                      (incident) => IncidentCard(
                        id: incident.id,
                        title: incident.title,
                        category: incident.category.name,
                        priority: incident.priority.name,
                        status: incident.status.name,
                        reportCount: incident.reportIds.length,
                        lastUpdated: _formatTime(incident.updatedAt),
                        aiGenerated: incident.aiGenerated,
                        tags: incident.tags,
                        onTap: () {},
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else {
      return dateTime.toString().split(' ')[0];
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANNOUNCEMENTS PREVIEW
// ─────────────────────────────────────────────────────────────────────────────

class _AnnouncementsPreviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.base, Sp.xl, Sp.base, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Announcements',
            action: TextButton(onPressed: () {}, child: const Text('See all')),
          ),
          ..._announcements.map(
            (a) => Container(
              margin: const EdgeInsets.only(bottom: Sp.sm),
              padding: const EdgeInsets.all(Sp.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: Radii.card,
                border: Border.all(color: theme.colorScheme.outlineVariant),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (a.pinned) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: Radii.chip,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.push_pin_rounded,
                                size: 10,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'PINNED',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Sp.sm),
                      ],
                      const Spacer(),
                      Text(a.date, style: theme.textTheme.labelSmall),
                    ],
                  ),
                  const SizedBox(height: Sp.xs),
                  Text(a.title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    a.preview,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
