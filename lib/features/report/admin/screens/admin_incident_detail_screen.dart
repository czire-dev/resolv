// lib/features/report/admin/screens/admin_incident_detail_screen.dart
// RESOLV — Admin Incident Detail Screen (core of the system)

import 'package:flutter/material.dart';
import 'package:resolv/core/themes/ui_constants.dart';
import 'package:resolv/features/report/admin/widgets/admin_widgets.dart';
import 'package:resolv/shared/widgets/badges.dart';
import 'package:resolv/shared/widgets/layouts.dart';

// ─── Mock Data ────────────────────────────────────────────────────────────────

final _mockLinkedReports = [
  (
    id: 'r1',
    title: 'Large pothole near Mabini corner',
    description: 'There is a very large pothole causing accidents.',
    status: 'inProgress',
    submittedAt: 'May 20',
    address: '23 Mabini St.',
    submittedBy: 'Juan dela Cruz',
    isDuplicate: false,
  ),
  (
    id: 'r2',
    title: 'Road damage — cracking since last month',
    description: 'The road has been cracking. Very dangerous for motorcycles.',
    status: 'pending',
    submittedAt: 'May 18',
    address: '17 Mabini St.',
    submittedBy: 'Maria Santos',
    isDuplicate: true,
  ),
  (
    id: 'r3',
    title: 'Multiple potholes blocking lane',
    description: 'Several potholes are blocking the right lane completely.',
    status: 'pending',
    submittedAt: 'May 15',
    address: '5 Mabini St.',
    submittedBy: 'Jose Garcia',
    isDuplicate: true,
  ),
];

final _mockTimeline = [
  (
    status: 'pending',
    remark: 'Incident created from 3 merged reports.',
    timeAgo: '3 days ago',
    author: 'AI System',
  ),
  (
    status: 'underReview',
    remark: 'Assigned to Barangay Engineering Office for inspection.',
    timeAgo: '2 days ago',
    author: 'Admin Reyes',
  ),
  (
    status: 'inProgress',
    remark: 'Engineering team dispatched. Work begins this week.',
    timeAgo: '1 day ago',
    author: 'Admin Reyes',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

class AdminIncidentDetailScreen extends StatefulWidget {
  // In production this would be an IncidentModel passed via router
  final String incidentId;

  const AdminIncidentDetailScreen({super.key, this.incidentId = 'i1'});

  @override
  State<AdminIncidentDetailScreen> createState() =>
      _AdminIncidentDetailScreenState();
}

class _AdminIncidentDetailScreenState extends State<AdminIncidentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── Sliver header ──
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            forceElevated: innerBoxIsScrolled,
            actions: [
              IconButton(
                onPressed: () => _showAdminActions(context),
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(background: _IncidentHeroHeader()),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                const Tab(text: 'Overview'),
                Tab(text: 'Reports (${_mockLinkedReports.length})'),
                const Tab(text: 'Timeline'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [_OverviewTab(), _LinkedReportsTab(), _TimelineTab()],
        ),
      ),
      bottomNavigationBar: _AdminActionBar(),
    );
  }

  void _showAdminActions(BuildContext context) {
    ActionBottomSheet.show(
      context,
      title: 'Incident Actions',
      actions: [
        BottomSheetAction(
          label: 'Mark as Resolved',
          icon: Icons.check_circle_rounded,
          color: StatusColors.resolved,
          onTap: () {},
        ),
        BottomSheetAction(
          label: 'Change Priority',
          icon: Icons.flag_rounded,
          onTap: () {},
        ),
        BottomSheetAction(
          label: 'Add Remark',
          icon: Icons.comment_rounded,
          onTap: () {},
        ),
        BottomSheetAction(
          label: 'Close Incident',
          icon: Icons.archive_rounded,
          color: theme.colorScheme.error,
          onTap: () {},
        ),
      ],
    );
  }

  ThemeData get theme => Theme.of(context);
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _IncidentHeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(Sp.base, 80, Sp.base, Sp.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              const CategoryChip(category: 'Infrastructure'),
              const SizedBox(width: Sp.sm),
              const AiBadge(),
              const Spacer(),
              const PriorityBadge(priority: 'High'),
            ],
          ),
          const SizedBox(height: Sp.sm),
          Text(
            'Damaged Road on Mabini Street',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: Sp.xs),
          const StatusBadge(status: 'inProgress'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OVERVIEW TAB
// ─────────────────────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Sp.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Incident Summary Panel
          IncidentSummaryPanel(
            reportCount: _mockLinkedReports.length,
            firstReportDate: 'May 15, 2026',
            lastUpdated: '1 day ago',
            category: 'Infrastructure',
            aiGenerated: true,
          ),
          const SizedBox(height: Sp.base),

          // AI Analysis
          const SectionHeader(title: 'AI Analysis'),
          const AIAnalysisPanel(
            predictedCategory: 'Infrastructure',
            priority: 'High',
            confidence: 0.91,
            tags: ['pothole', 'road', 'hazard', 'mabini'],
            incidentSummary:
                'Multiple residents have reported severe road deterioration on Mabini Street. The damage appears to span several blocks, presenting a significant safety risk to motorists and pedestrians.',
          ),
          const SizedBox(height: Sp.xxxl),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LINKED REPORTS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _LinkedReportsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(Sp.base),
      children: [
        // Deduplication explanation card
        Container(
          padding: const EdgeInsets.all(Sp.md),
          margin: const EdgeInsets.only(bottom: Sp.base),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: Radii.card,
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.25),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.call_merge_rounded,
                size: 20,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(width: Sp.sm),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(
                      context,
                    ).style.copyWith(fontSize: 12),
                    children: [
                      TextSpan(
                        text: '${_mockLinkedReports.length} reports ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const TextSpan(
                        text:
                            'were merged into this incident by the AI deduplication system. Duplicate reports are marked below.',
                        style: TextStyle(color: Color(0xFF4338CA)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        ..._mockLinkedReports.asMap().entries.map(
          (entry) => _LinkedReportCard(
            index: entry.key + 1,
            report: entry.value,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _LinkedReportCard extends StatelessWidget {
  final int index;
  final dynamic report;
  final VoidCallback onTap;

  const _LinkedReportCard({
    required this.index,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: Sp.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: Radii.card,
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: AppShadows.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(Sp.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Sp.sm),
                  Expanded(
                    child: Text(
                      report.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: Sp.sm),
                  StatusBadge(status: report.status, compact: true),
                ],
              ),
              const SizedBox(height: Sp.xs),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Sp.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          report.submittedBy,
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(width: Sp.sm),
                        Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            report.address,
                            style: theme.textTheme.labelSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (report.isDuplicate)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: Radii.chip,
                            ),
                            child: const Text(
                              'DUPLICATE',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6366F1),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TIMELINE TAB
// ─────────────────────────────────────────────────────────────────────────────

class _TimelineTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Sp.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Status Timeline',
            subtitle: 'All updates merged chronologically',
          ),
          StatusTimelineWidget(
            items: _mockTimeline
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN ACTION BAR
// ─────────────────────────────────────────────────────────────────────────────

class _AdminActionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        Sp.base,
        Sp.sm,
        Sp.base,
        Sp.sm + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        boxShadow: AppShadows.elevated,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showAddRemarkSheet(context),
              icon: const Icon(Icons.comment_rounded, size: 16),
              label: const Text('Add Remark'),
            ),
          ),
          const SizedBox(width: Sp.sm),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () => _showStatusUpdateSheet(context),
              icon: const Icon(Icons.update_rounded, size: 16),
              label: const Text('Update Status'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRemarkSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          Sp.base,
          Sp.base,
          Sp.base,
          Sp.base + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: Sp.base),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: Radii.chip,
                ),
              ),
            ),
            Text('Add Remark', style: theme.textTheme.titleMedium),
            const SizedBox(height: Sp.md),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the action taken or update...',
                border: OutlineInputBorder(borderRadius: Radii.card),
              ),
            ),
            const SizedBox(height: Sp.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Submit Remark'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateSheet(BuildContext context) {
    final statuses = [
      (
        'pending',
        'Pending',
        StatusColors.pending,
        Icons.hourglass_empty_rounded,
      ),
      (
        'underReview',
        'Under Review',
        StatusColors.underReview,
        Icons.manage_search_rounded,
      ),
      (
        'inProgress',
        'In Progress',
        StatusColors.inProgress,
        Icons.construction_rounded,
      ),
      (
        'resolved',
        'Resolved',
        StatusColors.resolved,
        Icons.check_circle_rounded,
      ),
      ('rejected', 'Rejected', StatusColors.rejected, Icons.cancel_rounded),
    ];

    ActionBottomSheet.show(
      context,
      title: 'Update Incident Status',
      actions: statuses
          .map(
            (s) => BottomSheetAction(
              label: s.$2,
              icon: s.$4,
              color: s.$3,
              onTap: () {},
            ),
          )
          .toList(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ADMIN REPORT DETAIL SCREEN
// ═════════════════════════════════════════════════════════════════════════════

// lib/features/report/admin/screens/admin_report_detail_screen.dart

class AdminReportDetailScreen extends StatelessWidget {
  final dynamic report; // ReportModel from router

  const AdminReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(
              'Report Detail',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            pinned: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new_rounded),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Sp.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status + Category row ──
                  Row(
                    children: [
                      const CategoryChip(category: 'Infrastructure'),
                      const SizedBox(width: Sp.sm),
                      const StatusBadge(status: 'inProgress'),
                      const SizedBox(width: Sp.sm),
                      const PriorityBadge(priority: 'High'),
                    ],
                  ),
                  const SizedBox(height: Sp.md),

                  // ── Title ──
                  const Text(
                    'Large pothole near Mabini corner',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: Sp.sm),

                  // ── Submitter info ──
                  _InfoRow(icon: Icons.person_rounded, text: 'Juan dela Cruz'),
                  const SizedBox(height: Sp.xs),
                  _InfoRow(
                    icon: Icons.location_on_rounded,
                    text: '23 Mabini Street, Marulete',
                  ),
                  const SizedBox(height: Sp.xs),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    text: 'Submitted May 20, 2026',
                  ),

                  // ── Linked Incident pill ──
                  const SizedBox(height: Sp.sm),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sp.md,
                        vertical: Sp.xs,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: Radii.chip,
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.link_rounded,
                            size: 14,
                            color: Color(0xFF6366F1),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Linked to: Damaged Road on Mabini Street',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 14,
                            color: Color(0xFF6366F1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Sp.xl),

                  // ── Image ──
                  ClipRRect(
                    borderRadius: Radii.card,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      color: theme.colorScheme.surfaceContainerLow,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: Sp.sm),
                            Text(
                              'No image attached',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Sp.xl),

                  // ── Description ──
                  const SectionHeader(title: 'Description'),
                  Text(
                    'There is a very large pothole in front of the store at 23 Mabini Street. '
                    'It is causing accidents — two motorcyclists have already fallen. '
                    'The pothole has been there for over 3 weeks and is getting worse with the rain.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: Sp.xl),

                  // ── AI Analysis ──
                  const SectionHeader(
                    title: 'AI Analysis',
                    subtitle: 'Automatically classified and prioritized',
                  ),
                  const AIAnalysisPanel(
                    predictedCategory: 'Infrastructure',
                    priority: 'High',
                    confidence: 0.91,
                    tags: ['pothole', 'road', 'hazard', 'accident'],
                    incidentSummary:
                        'Report describes severe road damage posing immediate safety risks. Classifying as Infrastructure — High priority based on safety impact and duration.',
                  ),
                  const SizedBox(height: Sp.xl),

                  // ── Admin Status Controls ──
                  const SectionHeader(title: 'Admin Controls'),
                  _AdminStatusDropdown(),
                  const SizedBox(height: Sp.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ReportAdminActionBar(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
      ],
    );
  }
}

class _AdminStatusDropdown extends StatefulWidget {
  @override
  State<_AdminStatusDropdown> createState() => _AdminStatusDropdownState();
}

class _AdminStatusDropdownState extends State<_AdminStatusDropdown> {
  String _selected = 'inProgress';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Sp.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: Radii.card,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Update Status', style: theme.textTheme.titleSmall),
          const SizedBox(height: Sp.sm),
          DropdownButtonFormField<String>(
            value: _selected,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: Radii.button),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Sp.md,
                vertical: Sp.sm,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(
                value: 'underReview',
                child: Text('Under Review'),
              ),
              DropdownMenuItem(value: 'inProgress', child: Text('In Progress')),
              DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            onChanged: (v) => setState(() => _selected = v!),
          ),
        ],
      ),
    );
  }
}

class _ReportAdminActionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        Sp.base,
        Sp.sm,
        Sp.base,
        Sp.sm + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        boxShadow: AppShadows.elevated,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.flag_rounded, size: 16),
              label: const Text('Flag'),
            ),
          ),
          const SizedBox(width: Sp.sm),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.comment_rounded, size: 16),
              label: const Text('Remark'),
            ),
          ),
          const SizedBox(width: Sp.sm),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Resolve'),
            ),
          ),
        ],
      ),
    );
  }
}
