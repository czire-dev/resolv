// lib/features/profile/presentation/screens/profile_screen.dart
// RESOLV — Resident Profile Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resolv/core/themes/ui_constants.dart';
import 'package:resolv/features/auth/presentation/controllers/auth_controller.dart';
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
          colors: [
            theme.colorScheme.primary.withOpacity(0.08),
            theme.colorScheme.surface,
          ],
        ),
      ),
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
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
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
                child: const Icon(
                  Icons.edit_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: Sp.md),
          Text(
            displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(email, style: theme.textTheme.bodySmall),
          if (badge != null) ...[const SizedBox(height: Sp.sm), badge!],
        ],
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
    final color = destructive
        ? theme.colorScheme.error
        : (iconColor ?? theme.colorScheme.primary);

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(Sp.sm),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: Radii.button,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: destructive ? theme.colorScheme.error : null,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.bodySmall)
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                )
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileHeader(
              displayName: 'Juan dela Cruz',
              email: 'juan.delacruz@email.com',
            ),

            // ── Report Stats ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Report Statistics'),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          count: 8,
                          label: 'Submitted',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: Sp.sm),
                      Expanded(
                        child: _StatTile(
                          count: 5,
                          label: 'Resolved',
                          color: StatusColors.resolved,
                        ),
                      ),
                      const SizedBox(width: Sp.sm),
                      Expanded(
                        child: _StatTile(
                          count: 2,
                          label: 'Pending',
                          color: StatusColors.pending,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant,
                    indent: 56,
                  ),
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
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant,
                    indent: 56,
                  ),
                  SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Mode',
                    iconColor: const Color(0xFF6366F1),
                    trailing: Switch(value: false, onChanged: (_) {}),
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant,
                    indent: 56,
                  ),
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
                      message:
                          'Are you sure you want to log out of your account?',
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
  }
}

class _StatTile extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatTile({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Sp.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: Radii.card,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
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
        : _mockAnnouncements
              .where((a) => a.category == _selectedCategory)
              .toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Announcements',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
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
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
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
              padding: const EdgeInsets.symmetric(
                horizontal: Sp.base,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Radii.lg),
                  topRight: Radius.circular(Radii.lg),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.push_pin_rounded,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
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
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
