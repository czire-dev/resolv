// lib/features/profile/presentation/screens/profile_screen.dart
// RESOLV — Resident Profile Screen

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/core/enums/user_role.dart';
import 'package:resolv/core/themes/ui_constants.dart';
import 'package:resolv/features/auth/presentation/controllers/auth_controller.dart';
import 'package:resolv/features/ai/providers/ai_providers.dart';
import 'package:resolv/models/user_model.dart';
import 'package:resolv/routing/app_routes.dart';
import 'package:resolv/shared/widgets/badges.dart';
import 'package:resolv/shared/widgets/layouts.dart';
// ─────────────────────────────────────────────────────────────────────────────
// PROFILE HEADER WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? profilePictureUrl;
  final Widget? badge;

  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.email,
    this.profilePictureUrl,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Sp.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.colorScheme.primary.withOpacity(0.08), theme.colorScheme.surface],
        ),
      ),
      child: Center(
        child: Column(
          children: [
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: profilePictureUrl != null
                      ? NetworkImage(profilePictureUrl!)
                      : null,
                  child: profilePictureUrl == null
                      ? Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit_rounded, size: 12, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: Sp.md),
            Text(
              displayName,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(email, style: theme.textTheme.bodySmall),
            if (badge != null) ...[const SizedBox(height: Sp.sm), badge!],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS TILE
// ─────────────────────────────────────────────────────────────────────────────

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool destructive;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive ? theme.colorScheme.error : (iconColor ?? theme.colorScheme.primary);

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(Sp.sm),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: Radii.button),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: destructive ? theme.colorScheme.error : null,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle!, style: theme.textTheme.bodySmall) : null,
      trailing:
          trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant)
              : null),
      shape: RoundedRectangleBorder(borderRadius: Radii.button),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESIDENT PROFILE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        body: Center(child: Text('Unable to load profile: $error')),
      ),
      data: (user) {
        final displayName = user?.displayName ?? 'Resident';
        final email = user?.email ?? 'No email available';

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                final router = GoRouter.of(context);
                if (router.canPop()) {
                  router.pop();
                } else {
                  router.go(AppRoutes.homeForRole(user?.role ?? UserRole.user));
                }
              },
            ),
            title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded))],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(displayName: displayName, email: email),
                const SizedBox(height: Sp.xl),
                _ProfileStatisticsSection(
                  user: user,
                  creationDate: FirebaseAuth.instance.currentUser?.metadata.creationTime,
                ),
                const SizedBox(height: Sp.xl),

                // ── Account Settings ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sp.base),
                  child: Text(
                    'ACCOUNT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: Sp.sm),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: Sp.base),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: Radii.card,
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: Icons.person_rounded,
                        title: 'Edit Profile',
                        subtitle: 'Update your name and photo',
                        onTap: () {},
                      ),
                      Divider(height: 1, color: theme.colorScheme.outlineVariant, indent: 56),
                      SettingsTile(
                        icon: Icons.lock_rounded,
                        title: 'Change Password',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Sp.xl),

                // ── Preferences ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sp.base),
                  child: Text(
                    'PREFERENCES',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: Sp.sm),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: Sp.base),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: Radii.card,
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: Icons.notifications_rounded,
                        title: 'Notifications',
                        subtitle: 'Manage alert preferences',
                        onTap: () {},
                      ),
                      Divider(height: 1, color: theme.colorScheme.outlineVariant, indent: 56),
                      SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        title: 'Dark Mode',
                        iconColor: const Color(0xFF6366F1),
                        trailing: Switch(value: false, onChanged: (_) {}),
                      ),
                      Divider(height: 1, color: theme.colorScheme.outlineVariant, indent: 56),
                      SettingsTile(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        subtitle: 'Filipino / English',
                        iconColor: const Color(0xFF10B981),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Sp.xl),

                // ── Logout ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sp.base),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: Radii.card,
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: SettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'Log Out',
                      destructive: true,
                      onTap: () {
                        ConfirmationDialog.show(
                          context,
                          title: 'Log Out',
                          message: 'Are you sure you want to log out of your account?',
                          confirmLabel: 'Log Out',
                          isDangerous: true,
                          onConfirm: () {
                            ref.read(authControllerProvider.notifier).signOut();
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: Sp.xxxl),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileStatisticsSection extends ConsumerWidget {
  final UserModel? user;
  final DateTime? creationDate;

  const _ProfileStatisticsSection({required this.user, required this.creationDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = user;
    if (currentUser == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sp.base),
        child: Text('Unable to load profile statistics.'),
      );
    }

    final userReportsAsync = ref.watch(userReportsStreamProvider(currentUser.id));
    final allReportsAsync = ref.watch(reportsStreamProvider);
    final activeIncidentsAsync = ref.watch(incidentsStreamProvider((category: null, status: 'active')));
    final monitoringIncidentsAsync = ref.watch(incidentsStreamProvider((category: null, status: 'monitoring')));
    final usersAsync = ref.watch(usersStreamProvider);

    if (currentUser.role == UserRole.admin) {
      final isLoading = allReportsAsync.isLoading || activeIncidentsAsync.isLoading || monitoringIncidentsAsync.isLoading || usersAsync.isLoading;
      final hasError = allReportsAsync.hasError || activeIncidentsAsync.hasError || monitoringIncidentsAsync.hasError || usersAsync.hasError;
      if (isLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: Sp.base),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (hasError) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.base),
          child: Text('Unable to load admin statistics.'),
        );
      }

      final allReports = allReportsAsync.value ?? [];
      final resolvedCount = allReports.where((r) => r.status == ReportStatus.resolved).length;
      final aiLinkedIncidentsCount = allReports.where((r) => r.incidentId.isNotEmpty).map((r) => r.incidentId).toSet().length;
      final totalReports = allReports.length;
      final totalUsers = usersAsync.value?.length ?? 0;
      final activeIncidents = activeIncidentsAsync.value?.length ?? 0;
      final monitoringIncidents = monitoringIncidentsAsync.value?.length ?? 0;

      final stats = [
        _StatCardData(
          count: totalReports,
          label: 'Total reports',
          color: theme.colorScheme.primary,
          icon: Icons.description_outlined,
        ),
        _StatCardData(
          count: activeIncidents,
          label: 'Active incidents',
          color: Colors.blueAccent,
          icon: Icons.warning_amber_rounded,
        ),
        _StatCardData(
          count: resolvedCount,
          label: 'Reports resolved',
          color: StatusColors.resolved,
          icon: Icons.check_circle_outline_rounded,
        ),
        _StatCardData(
          count: monitoringIncidents,
          label: 'Monitoring incidents',
          color: Colors.orangeAccent,
          icon: Icons.manage_search_rounded,
        ),
        _StatCardData(
          count: totalUsers,
          label: 'Total users',
          color: theme.colorScheme.secondary,
          icon: Icons.people_alt_outlined,
        ),
        _StatCardData(
          count: aiLinkedIncidentsCount,
          label: 'AI-linked incidents',
          color: Colors.teal,
          icon: Icons.auto_awesome_outlined,
        ),
      ];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sp.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Report Statistics'),
            _ResponsiveStatsGrid(stats: stats),
          ],
        ),
      );
    }

    final isLoading = userReportsAsync.isLoading;
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: Sp.base),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (userReportsAsync.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sp.base),
        child: Text('Unable to load report statistics.'),
      );
    }

    final reports = userReportsAsync.value ?? [];
    final totalReports = reports.length;
    final resolvedCount = reports.where((r) => r.status == ReportStatus.resolved).length;
    final pendingCount = reports.where((r) => r.status == ReportStatus.pending).length;
    final activeIncidentsCount = reports.where((r) => r.incidentId.isNotEmpty).map((r) => r.incidentId).toSet().length;
    final latestReport = reports.isNotEmpty ? reports.first.submittedAt : null;
    final createdAtLabel = creationDate != null ? _profileFormatDate(creationDate!) : 'Unknown';
    final latestReportLabel = latestReport != null ? _profileFormatDate(latestReport) : 'No reports yet';

    final stats = [
      _StatCardData(
        count: totalReports,
        label: 'Submitted',
        color: theme.colorScheme.primary,
        icon: Icons.description_outlined,
      ),
      _StatCardData(
        count: pendingCount,
        label: 'Pending',
        color: StatusColors.pending,
        icon: Icons.hourglass_empty_rounded,
      ),
      _StatCardData(
        count: resolvedCount,
        label: 'Resolved',
        color: StatusColors.resolved,
        icon: Icons.check_circle_outline_rounded,
      ),
      _StatCardData(
        count: activeIncidentsCount,
        label: 'Active incidents',
        color: Colors.blueAccent,
        icon: Icons.warning_amber_rounded,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Report Statistics'),
          _ResponsiveStatsGrid(stats: stats),
          const SizedBox(height: Sp.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = constraints.maxWidth >= 720 ? (constraints.maxWidth - Sp.sm) / 2 : constraints.maxWidth;

              return Wrap(
                alignment: WrapAlignment.center,
                spacing: Sp.sm,
                runSpacing: Sp.sm,
                children: [
                  SizedBox(
                    width: tileWidth,
                    child: _ProfileDetailTile(label: 'Account created', value: createdAtLabel),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _ProfileDetailTile(label: 'Last report', value: latestReportLabel),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ResponsiveStatsGrid extends StatelessWidget {
  final List<_StatCardData> stats;

  const _ResponsiveStatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: Sp.sm,
      mainAxisSpacing: Sp.sm,
      childAspectRatio: 1.35,
      children: [
        for (final stat in stats)
          _StatTile(
            count: stat.count,
            label: stat.label,
            color: stat.color,
            icon: stat.icon,
          ),
      ],
    );
  }
}

class _StatCardData {
  final int count;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCardData({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });
}

class _ProfileDetailTile extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileDetailTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Sp.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: Radii.card,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Sp.xs),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;

  const _StatTile({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.all(Sp.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: Radii.card,
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: Sp.sm),
          Text(
            '$count',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

String _profileFormatDate(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
}

// ═════════════════════════════════════════════════════════════════════════════
// ANNOUNCEMENTS SCREEN
// ═════════════════════════════════════════════════════════════════════════════

// lib/features/announcements/presentation/screens/announcements_screen.dart

const _announcementCategories = [
  'All',
  'Health',
  'Infrastructure',
  'Safety',
  'Events',
  'Utilities',
];

const _mockAnnouncements = [
  (
    title: 'Community Clean-Up Drive This Saturday',
    preview:
        'Join us for the monthly barangay-wide clean-up drive at the Barangay Plaza on May 31.',
    date: 'May 25, 2026',
    category: 'Events',
    pinned: true,
    imageUrl: null,
  ),
  (
    title: 'Water Interruption Notice — May 28',
    preview:
        'Scheduled maintenance will cause water supply interruption from 8AM to 5PM. Affected areas: Zones 3–6.',
    date: 'May 24, 2026',
    category: 'Utilities',
    pinned: false,
    imageUrl: null,
  ),
  (
    title: 'Free Medical Mission on June 5',
    preview:
        'The Barangay Health Center will conduct a free medical mission with dental, EENT, and general consultations.',
    date: 'May 22, 2026',
    category: 'Health',
    pinned: false,
    imageUrl: null,
  ),
  (
    title: 'Street Lighting Upgrade Project',
    preview:
        'LED street lights will be installed along Mabini Street and Rizal Avenue starting June 1.',
    date: 'May 20, 2026',
    category: 'Infrastructure',
    pinned: false,
    imageUrl: null,
  ),
];

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _selectedCategory == 'All'
        ? _mockAnnouncements
        : _mockAnnouncements.where((a) => a.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Announcements', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          // ── Category filter chips ──
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Sp.base),
              itemCount: _announcementCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: Sp.sm),
              itemBuilder: (context, i) {
                final cat = _announcementCategories[i];
                final selected = cat == _selectedCategory;
                return FilterChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: theme.colorScheme.primary.withOpacity(0.15),
                  checkmarkColor: theme.colorScheme.primary,
                  side: BorderSide(
                    color: selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                  ),
                );
              },
            ),
          ),

          // ── Announcement list ──
          Expanded(
            child: filtered.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.campaign_outlined,
                    title: 'No announcements',
                    message: 'There are no announcements in this category.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(Sp.base),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final a = filtered[i];
                      return _AnnouncementCard(
                        title: a.title,
                        preview: a.preview,
                        date: a.date,
                        category: a.category,
                        pinned: a.pinned,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final String title;
  final String preview;
  final String date;
  final String category;
  final bool pinned;

  const _AnnouncementCard({
    required this.title,
    required this.preview,
    required this.date,
    required this.category,
    required this.pinned,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: Sp.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: Radii.card,
        boxShadow: AppShadows.card,
        border: Border.all(
          color: pinned
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outlineVariant,
          width: pinned ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          if (pinned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Sp.base, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Radii.lg),
                  topRight: Radius.circular(Radii.lg),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.push_pin_rounded, size: 12, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    'PINNED ANNOUNCEMENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(Sp.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CategoryChip(category: category),
                    const Spacer(),
                    Text(date, style: theme.textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: Sp.sm),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: Sp.xs),
                Text(
                  preview,
                  style: theme.textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Sp.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Read more'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
