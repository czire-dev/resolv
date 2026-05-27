/// ARCHIVED: Example UI demonstrating incident grouping (deduplication concept).
///
/// This screen shows how multiple reports can be grouped into a single incident
/// for deduplication purposes. It was originally created as a UI prototype and
/// is kept as a reference implementation.
///
/// ⚠️  DO NOT USE IN PRODUCTION — This file uses hardcoded mock data and is
/// not connected to any routing or real Firestore data.
///
/// Reference: See lib/features/report/user/presentation/screens/report_list_screen.dart
/// for the production-ready implementation connected to Firestore.
library;

// lib/features/report/user/presentation/screens/report_list_screen.dart
// RESOLV — Resident Report List Screen

import 'package:flutter/material.dart';
import 'package:resolv/core/themes/ui_constants.dart';
import 'package:resolv/features/report/admin/widgets/admin_widgets.dart';
import 'package:resolv/shared/widgets/badges.dart';
import 'package:resolv/shared/widgets/cards.dart';
import 'package:resolv/shared/widgets/layouts.dart';

// ─── Mock Data ────────────────────────────────────────────────────────────────

const _mockGroupedReports = [
  (
    incidentTitle: 'Damaged Road on Mabini Street',
    category: 'Infrastructure',
    status: 'inProgress',
    reportCount: 7,
    lastUpdated: '2 hours ago',
    aiGenerated: true,
    tags: ['pothole', 'road'],
    reports: [
      (
        id: 'r1',
        title: 'Large pothole near Mabini corner',
        description:
            'There is a very large pothole in front of the store that is causing accidents.',
        status: 'inProgress',
        submittedAt: 'May 20',
        address: '23 Mabini St.',
        imageUrl: null,
        isDuplicate: false,
      ),
      (
        id: 'r2',
        title: 'Road damage on Mabini St.',
        description:
            'The road has been cracking since last month. Very dangerous for motorcycles.',
        status: 'pending',
        submittedAt: 'May 18',
        address: '17 Mabini St.',
        imageUrl: null,
        isDuplicate: true,
      ),
    ],
  ),
  (
    incidentTitle: 'Overflowing Canal near Barangay Hall',
    category: 'Environment',
    status: 'underReview',
    reportCount: 12,
    lastUpdated: '30 minutes ago',
    aiGenerated: true,
    tags: ['flood', 'drainage'],
    reports: [
      (
        id: 'r3',
        title: 'Canal blocked with garbage',
        description:
            'The main canal is completely clogged and water is overflowing onto the street.',
        status: 'underReview',
        submittedAt: 'May 25',
        address: 'Brgy Hall Compound',
        imageUrl: null,
        isDuplicate: false,
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _expandedGroups = {0};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'My Reports',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Resolved'),
          ],
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ReportGroupList(
            groups: _mockGroupedReports,
            expandedGroups: _expandedGroups,
            onToggle: (i) => setState(() {
              if (_expandedGroups.contains(i)) {
                _expandedGroups.remove(i);
              } else {
                _expandedGroups.add(i);
              }
            }),
            onReportTap: (id) {},
          ),
          _ReportGroupList(
            groups: _mockGroupedReports
                .where((g) => g.status != 'resolved')
                .toList(),
            expandedGroups: _expandedGroups,
            onToggle: (i) => setState(() {
              if (_expandedGroups.contains(i)) {
                _expandedGroups.remove(i);
              } else {
                _expandedGroups.add(i);
              }
            }),
            onReportTap: (id) {},
          ),
          EmptyStateWidget(
            icon: Icons.check_circle_outline_rounded,
            title: 'No resolved reports yet',
            message:
                'Reports you submitted that have been resolved will appear here.',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: const Text('Report Issue'),
      ),
    );
  }
}

class _ReportGroupList extends StatelessWidget {
  final List groups;
  final Set<int> expandedGroups;
  final ValueChanged<int> onToggle;
  final ValueChanged<String> onReportTap;

  const _ReportGroupList({
    required this.groups,
    required this.expandedGroups,
    required this.onToggle,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.assignment_outlined,
        title: 'No reports found',
        message:
            'You haven\'t submitted any reports yet. Tap the button below to create one.',
        action: FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_rounded),
          label: const Text('Create Report'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(Sp.base),
      itemCount: groups.length,
      itemBuilder: (context, i) {
        final g = _mockGroupedReports[i];
        final isExpanded = expandedGroups.contains(i);

        return _IncidentGroupSection(
          title: g.incidentTitle,
          category: g.category,
          status: g.status,
          reportCount: g.reportCount,
          lastUpdated: g.lastUpdated,
          aiGenerated: g.aiGenerated,
          tags: List<String>.from(g.tags),
          reports: g.reports
              .map(
                (r) => (
                  id: r.id,
                  title: r.title,
                  description: r.description,
                  status: r.status,
                  submittedAt: r.submittedAt,
                  address: r.address,
                  imageUrl: r.imageUrl,
                  isDuplicate: r.isDuplicate,
                ),
              )
              .toList(),
          isExpanded: isExpanded,
          onToggle: () => onToggle(i),
          onReportTap: onReportTap,
        );
      },
    );
  }
}

// The key deduplication UI: incident group collapsible section
class _IncidentGroupSection extends StatelessWidget {
  final String title;
  final String category;
  final String status;
  final int reportCount;
  final String lastUpdated;
  final bool aiGenerated;
  final List<String> tags;
  final List reports;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onReportTap;

  const _IncidentGroupSection({
    required this.title,
    required this.category,
    required this.status,
    required this.reportCount,
    required this.lastUpdated,
    required this.aiGenerated,
    required this.tags,
    required this.reports,
    required this.isExpanded,
    required this.onToggle,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: Sp.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: Radii.card,
        boxShadow: AppShadows.card,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          // ── Dedup banner ──
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Sp.base,
              vertical: Sp.sm,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Radii.lg),
                topRight: Radius.circular(Radii.lg),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.call_merge_rounded,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: Sp.xs),
                Text(
                  '$reportCount reports merged into 1 incident',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (aiGenerated) const AiBadge(compact: true),
              ],
            ),
          ),

          // ── Incident header (tappable to expand/collapse) ──
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(Radii.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Sp.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CategoryChip(category: category),
                      const Spacer(),
                      StatusBadge(status: status, compact: true),
                      const SizedBox(width: Sp.sm),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
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
                  Row(
                    children: [
                      if (tags.isNotEmpty) ...[
                        ...tags
                            .take(2)
                            .map(
                              (t) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: TagChip(label: t),
                              ),
                            ),
                      ],
                      const Spacer(),
                      Text(lastUpdated, style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded reports ──
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(Sp.base, 0, Sp.base, Sp.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: theme.colorScheme.outlineVariant),
                  Padding(
                    padding: const EdgeInsets.only(bottom: Sp.sm),
                    child: Text(
                      'YOUR REPORTS IN THIS INCIDENT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  ...reports.map(
                    (r) => ReportCard(
                      id: r.id,
                      title: r.title,
                      description: r.description,
                      category: category,
                      status: r.status,
                      submittedAt: r.submittedAt,
                      address: r.address,
                      imageUrl: r.imageUrl,
                      isDuplicate: r.isDuplicate,
                      isLinkedToIncident: true,
                      onTap: () => onReportTap(r.id),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// REPORT DETAIL SCREEN (Resident)
// ═════════════════════════════════════════════════════════════════════════════

// lib/features/report/user/presentation/screens/report_detail_screen.dart

class ReportDetailScreen extends StatelessWidget {
  // Accepts a UI model — all data already provided
  final dynamic report; // ReportUiModel from router

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock enriched detail data
    const mockRemarks = [
      (
        status: 'pending',
        remark: 'Report received. Under initial review.',
        timeAgo: '3 days ago',
        author: 'System',
      ),
      (
        status: 'underReview',
        remark: 'Assigned to Barangay Engineering Office.',
        timeAgo: '2 days ago',
        author: 'Admin Reyes',
      ),
      (
        status: 'inProgress',
        remark: 'Repair crew dispatched. Work to begin this week.',
        timeAgo: '1 day ago',
        author: 'Admin Reyes',
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar with image ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: report.imageUrl != null
                  ? Image.network(
                      report.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _NoImagePlaceholder(),
                    )
                  : _NoImagePlaceholder(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Sp.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status + Category ──
                  Row(
                    children: [
                      CategoryChip(category: report.category?.name ?? 'Other'),
                      const SizedBox(width: Sp.sm),
                      StatusBadge(status: report.status?.name ?? 'pending'),
                    ],
                  ),
                  const SizedBox(height: Sp.md),

                  // ── Title ──
                  Text(
                    report.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Sp.sm),

                  // ── Meta ──
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report.address ?? 'Address not provided',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Submitted ${report.submittedAt}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.xl),

                  // ── Description ──
                  const SectionHeader(title: 'Description'),
                  Text(
                    report.description ?? '',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: Sp.xl),

                  // ── AI Analysis Panel ──
                  const SectionHeader(
                    title: 'AI Analysis',
                    subtitle: 'Automatically generated by RESOLV AI',
                  ),
                  const AIAnalysisPanelStub(),
                  const SizedBox(height: Sp.xl),

                  // ── Status Timeline ──
                  const SectionHeader(title: 'Status Timeline'),
                  StatusTimelineWidget(
                    items: mockRemarks
                        .map(
                          (r) => StatusTimelineItem(
                            status: r.status,
                            remark: r.remark,
                            timeAgo: r.timeAgo,
                            author: r.author,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: Sp.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Stub for AI panel when aiAnalysis may be null
class AIAnalysisPanelStub extends StatelessWidget {
  const AIAnalysisPanelStub({super.key});

  @override
  Widget build(BuildContext context) {
    return const AIAnalysisPanel(
      predictedCategory: 'Infrastructure',
      priority: 'High',
      confidence: 0.87,
      tags: ['pothole', 'road', 'hazard'],
      incidentSummary:
          'Multiple residents have reported significant road damage on Mabini Street, posing safety risks to pedestrians and motorists.',
    );
  }
}

class _NoImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: Sp.sm),
            Text('No image attached', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
