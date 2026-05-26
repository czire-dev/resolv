// lib/features/report/admin/screens/admin_dashboard_screen.dart
// RESOLV — Admin Dashboard (highest priority screen)
// Emphasizes the AI-powered deduplication system

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/core/themes/ui_constants.dart';
import 'package:resolv/shared/widgets/cards.dart';
import 'package:resolv/shared/widgets/layouts.dart';

// ─── Mock KPI Data ────────────────────────────────────────────────────────────

const _kpiData = (
  activeIncidents: 14,
  pendingReports: 31,
  highPriority: 5,
  aiGrouped: 27,
);

const _mockIncidents = [
  (
    id: 'i1',
    title: 'Flooded Streets — Zone 4 & 5',
    category: 'Environment',
    priority: 'Critical',
    status: 'underReview',
    reportCount: 12,
    lastUpdated: '30m ago',
    aiGenerated: true,
    tags: ['flood', 'drainage', 'urgent'],
  ),
  (
    id: 'i2',
    title: 'Damaged Road — Mabini Street',
    category: 'Infrastructure',
    priority: 'High',
    status: 'inProgress',
    reportCount: 7,
    lastUpdated: '2h ago',
    aiGenerated: true,
    tags: ['pothole', 'road'],
  ),
  (
    id: 'i3',
    title: 'Broken Street Lamp — Rizal Ave',
    category: 'Utilities',
    priority: 'Medium',
    status: 'pending',
    reportCount: 3,
    lastUpdated: '1d ago',
    aiGenerated: false,
    tags: ['lighting'],
  ),
  (
    id: 'i4',
    title: 'Stray Dogs near Elementary School',
    category: 'Safety',
    priority: 'High',
    status: 'pending',
    reportCount: 5,
    lastUpdated: '4h ago',
    aiGenerated: true,
    tags: ['safety', 'animal'],
  ),
];

// Needs review = raw reports AI hasn't grouped yet
const _needsReview = [
  (
    id: 'r10',
    title: 'Garbage uncollected for 3 weeks',
    address: '9 Bonifacio St.',
    category: 'Environment',
    submittedAt: '1h ago',
  ),
  (
    id: 'r11',
    title: 'Pothole near school gate',
    address: '42 Mabini St.',
    category: 'Infrastructure',
    submittedAt: '3h ago',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _incidentFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Admin Header ──
            SliverToBoxAdapter(child: _AdminHeader()),

            // ── Search ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Sp.base,
                  0,
                  Sp.base,
                  Sp.base,
                ),
                child: SearchBarWidget(
                  hintText: 'Search incidents, reports...',
                  onFilterTap: () {},
                ),
              ),
            ),

            // ── AI Deduplication Banner ──
            SliverToBoxAdapter(child: _DeduplicationSystemBanner()),

            // ── KPI Cards ──
            SliverToBoxAdapter(child: _KpiSection()),

            // ── Needs Review Queue ──
            SliverToBoxAdapter(child: _NeedsReviewSection()),

            // ── Incident List ──
            SliverToBoxAdapter(
              child: _IncidentListSection(
                selectedFilter: _incidentFilter,
                onFilterChanged: (f) => setState(() => _incidentFilter = f),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: Sp.xxxl)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _AdminHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.base, Sp.base, Sp.base, Sp.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: Sp.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RESOLV Admin',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: Radii.chip,
                    ),
                    child: Text(
                      'ADMIN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('Admin Reyes', style: theme.textTheme.labelSmall),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: Radii.button),
            ),
          ),
          const SizedBox(width: Sp.sm),
          IconButton(
            onPressed: () {
              context.go('/profile');
            },
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                'R',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: Radii.button),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DEDUPLICATION SYSTEM BANNER  ← CORE CONCEPT CALLOUT
// ─────────────────────────────────────────────────────────────────────────────

class _DeduplicationSystemBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.base, 0, Sp.base, Sp.base),
      child: Container(
        padding: const EdgeInsets.all(Sp.base),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          ),
          borderRadius: Radii.card,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Sp.md),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: Radii.button,
              ),
              child: const Icon(
                Icons.call_merge_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'AI Deduplication Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: Sp.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: Radii.chip,
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${_kpiData.aiGrouped} reports',
                          style: TextStyle(
                            color: Color(0xFFA5B4FC),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: ' automatically grouped into ',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        TextSpan(
                          text: '${_kpiData.activeIncidents} incidents',
                          style: TextStyle(
                            color: Color(0xFFA5B4FC),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFA5B4FC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _KpiSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.base, 0, Sp.base, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Dashboard Overview'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: Sp.sm,
            mainAxisSpacing: Sp.sm,
            childAspectRatio: 1.4,
            children: [
              DashboardMetricCard(
                label: 'Active Incidents',
                value: '${_kpiData.activeIncidents}',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEEF2FF),
                subtitle: 'Across all categories',
              ),
              DashboardMetricCard(
                label: 'Pending Reports',
                value: '${_kpiData.pendingReports}',
                icon: Icons.hourglass_empty_rounded,
                color: StatusColors.pending,
                bgColor: StatusColors.pendingBg,
                subtitle: 'Awaiting triage',
              ),
              DashboardMetricCard(
                label: 'High Priority',
                value: '${_kpiData.highPriority}',
                icon: Icons.priority_high_rounded,
                color: PriorityColors.critical,
                bgColor: PriorityColors.criticalBg,
                subtitle: 'Needs immediate action',
              ),
              DashboardMetricCard(
                label: 'AI Grouped',
                value: '${_kpiData.aiGrouped}',
                icon: Icons.auto_awesome_rounded,
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFEDE9FE),
                subtitle: 'By deduplication AI',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEEDS REVIEW SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _NeedsReviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.base, Sp.xl, Sp.base, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Needs Review',
            subtitle: 'Unmatched reports — possible new incidents',
            action: TextButton(onPressed: () {}, child: const Text('View all')),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: Radii.card,
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.4),
              ),
            ),
            child: Column(
              children: _needsReview.map((r) {
                final isLast = r == _needsReview.last;
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(Sp.sm),
                        decoration: BoxDecoration(
                          color: StatusColors.pendingBg,
                          borderRadius: Radii.button,
                        ),
                        child: const Icon(
                          Icons.pending_actions_rounded,
                          size: 18,
                          color: StatusColors.pending,
                        ),
                      ),
                      title: Text(
                        r.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${r.category} · ${r.submittedAt}',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sp.sm,
                          ),
                          minimumSize: const Size(0, 30),
                          side: const BorderSide(color: StatusColors.pending),
                          foregroundColor: StatusColors.pending,
                        ),
                        child: const Text(
                          'Review',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: const Color(0xFFF59E0B).withOpacity(0.2),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INCIDENT LIST SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _IncidentListSection extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _IncidentListSection({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Critical', 'High', 'In Progress', 'Pending'];
    final theme = Theme.of(context);

    final filtered = selectedFilter == 'All'
        ? _mockIncidents
        : _mockIncidents
              .where(
                (i) =>
                    i.priority.toLowerCase() == selectedFilter.toLowerCase() ||
                    i.status.toLowerCase().replaceAll(' ', '') ==
                        selectedFilter.toLowerCase().replaceAll(' ', ''),
              )
              .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.base, Sp.xl, Sp.base, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Active Incidents',
            subtitle: 'Grouped from multiple community reports',
            action: TextButton(onPressed: () {}, child: const Text('View all')),
          ),

          // Filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: Sp.xs),
              itemBuilder: (context, i) {
                final f = filters[i];
                final selected = f == selectedFilter;
                return ChoiceChip(
                  label: Text(f, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (_) => onFilterChanged(f),
                  selectedColor: theme.colorScheme.primary.withOpacity(0.15),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                  side: BorderSide(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
          const SizedBox(height: Sp.md),

          // Cards
          if (filtered.isEmpty)
            const EmptyStateWidget(
              icon: Icons.folder_open_rounded,
              title: 'No incidents found',
              message: 'No incidents match the selected filter.',
            )
          else
            ...filtered.map(
              (i) => IncidentCard(
                id: i.id,
                title: i.title,
                category: i.category,
                priority: i.priority,
                status: i.status,
                reportCount: i.reportCount,
                lastUpdated: i.lastUpdated,
                aiGenerated: i.aiGenerated,
                tags: List<String>.from(i.tags),
                onTap: () {
                  // TODO: navigate to incident detail screen
                },
              ),
            ),
        ],
      ),
    );
  }
}
