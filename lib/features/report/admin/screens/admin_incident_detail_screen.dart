import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/core/enums/incident_enums.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/core/themes/ui_constants.dart';
import 'package:resolv/features/report/admin/widgets/admin_widgets.dart';
import 'package:resolv/features/ai/providers/ai_providers.dart';
import 'package:resolv/features/report/providers/incident_providers.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/routing/app_routes.dart';
import 'package:resolv/shared/widgets/badges.dart';
import 'package:resolv/shared/widgets/layouts.dart';

class AdminIncidentDetailScreen extends ConsumerStatefulWidget {
  final String incidentId;

  const AdminIncidentDetailScreen({super.key, required this.incidentId});

  @override
  ConsumerState<AdminIncidentDetailScreen> createState() =>
      _AdminIncidentDetailScreenState();
}

class _AdminIncidentDetailScreenState
    extends ConsumerState<AdminIncidentDetailScreen>
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
    final incidentsAsync =
        ref.watch(incidentsStreamProvider((category: null, status: null)));
    final reportsAsync = ref.watch(reportsStreamProvider);

    return incidentsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Incident Detail')),
        body: ErrorStateWidget(message: error.toString()),
      ),
      data: (incidents) {
        final incident = _findIncident(incidents, widget.incidentId);
        if (incident == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Incident Detail')),
            body: const EmptyStateWidget(
              icon: Icons.warning_amber_outlined,
              title: 'Incident not found',
              message: 'This incident may have been removed.',
            ),
          );
        }

        return reportsAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Scaffold(
            appBar: AppBar(title: const Text('Incident Detail')),
            body: ErrorStateWidget(message: error.toString()),
          ),
          data: (reports) {
            final linkedReports = reports
                .where((r) => r.incidentId == incident.id)
                .toList()
              ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              body: SafeArea(
                top: false,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 180,
                      forceElevated: innerBoxIsScrolled,
                      actions: [
                        IconButton(
                          onPressed: () => _showAdminActions(context, incident),
                          icon: const Icon(Icons.more_vert_rounded),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: _IncidentHeroHeader(incident: incident),
                      ),
                      bottom: TabBar(
                        controller: _tabController,
                        tabs: [
                          const Tab(text: 'Overview'),
                          Tab(text: 'Reports (${linkedReports.length})'),
                          const Tab(text: 'Timeline'),
                        ],
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      // Ensure each tab accounts for bottom action bar spacing
                      Padding(
                        padding: EdgeInsets.only(bottom: 88 + MediaQuery.of(context).padding.bottom),
                        child: _OverviewTab(incident: incident, linkedReports: linkedReports),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 88 + MediaQuery.of(context).padding.bottom),
                        child: _LinkedReportsTab(linkedReports: linkedReports),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 88 + MediaQuery.of(context).padding.bottom),
                        child: _TimelineTab(incident: incident, linkedReports: linkedReports),
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: _AdminActionBar(
                onUpdateStatus: () => _showStatusUpdateSheet(context, incident),
              ),
            );
          },
        );
      },
    );
  }

  IncidentModel? _findIncident(List<IncidentModel> incidents, String id) {
    final matches = incidents.where((incident) => incident.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  void _showAdminActions(BuildContext context, IncidentModel incident) {
    final theme = Theme.of(context);

    ActionBottomSheet.show(
      context,
      title: 'Incident Actions',
      actions: [
        BottomSheetAction(
          label: 'Mark as Resolved',
          icon: Icons.check_circle_rounded,
          color: StatusColors.resolved,
          onTap: () => _updateIncidentStatus(incident, IncidentStatus.resolved),
        ),
        BottomSheetAction(
          label: 'Mark as Monitoring',
          icon: Icons.visibility_rounded,
          onTap: () => _updateIncidentStatus(incident, IncidentStatus.monitoring),
        ),
        BottomSheetAction(
          label: 'Set as Active',
          icon: Icons.bolt_rounded,
          onTap: () => _updateIncidentStatus(incident, IncidentStatus.active),
        ),
        BottomSheetAction(
          label: 'Close Incident',
          icon: Icons.archive_rounded,
          color: theme.colorScheme.error,
          onTap: () => _updateIncidentStatus(incident, IncidentStatus.resolved),
        ),
      ],
    );
  }

  void _showStatusUpdateSheet(BuildContext context, IncidentModel incident) {
    final statuses = [
      (
        IncidentStatus.active,
        'Active',
        StatusColors.inProgress,
        Icons.construction_rounded,
      ),
      (
        IncidentStatus.monitoring,
        'Monitoring',
        StatusColors.underReview,
        Icons.manage_search_rounded,
      ),
      (
        IncidentStatus.resolved,
        'Resolved',
        StatusColors.resolved,
        Icons.check_circle_rounded,
      ),
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
              onTap: () => _updateIncidentStatus(incident, s.$1),
            ),
          )
          .toList(),
    );
  }

  Future<void> _updateIncidentStatus(
    IncidentModel incident,
    IncidentStatus newStatus,
  ) async {
    final result = await ref.read(incidentRepositoryProvider).updateIncidentStatus(
          incidentId: incident.id,
          newStatus: newStatus,
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Incident status updated'
              : (result.error?.message ?? 'Failed to update incident'),
        ),
      ),
    );
  }
}

class _IncidentHeroHeader extends StatelessWidget {
  final IncidentModel incident;

  const _IncidentHeroHeader({required this.incident});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Reduce fixed top padding and make layout flexible to avoid overflow in small heights
    final topPad = 40.0;
    return Container(
      padding: EdgeInsets.fromLTRB(Sp.base, topPad, Sp.base, Sp.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CategoryChip(category: incident.category.label),
              const SizedBox(width: Sp.sm),
              if (incident.aiGenerated) const AiBadge(),
              const Spacer(),
              PriorityBadge(priority: incident.priority.name),
            ],
          ),
          const SizedBox(height: Sp.sm),
          // Make the title flexible so it can shrink inside small FlexibleSpaceBar heights
          Flexible(
            child: Text(
              incident.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: Sp.xs),
          StatusBadge(status: _statusLabel(incident.status), compact: true),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final IncidentModel incident;
  final List<ReportModel> linkedReports;

  const _OverviewTab({required this.incident, required this.linkedReports});

  @override
  Widget build(BuildContext context) {
    final firstReportAt = linkedReports.isEmpty
        ? incident.createdAt
        : linkedReports.last.submittedAt;
    final summarySource =
        linkedReports.isEmpty ? null : linkedReports.first.aiAnalysis;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Sp.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IncidentSummaryPanel(
            reportCount: incident.reportCount,
            firstReportDate:
                '${firstReportAt.month}/${firstReportAt.day}/${firstReportAt.year}',
            lastUpdated: _timeAgo(incident.updatedAt),
            category: incident.category.label,
            aiGenerated: incident.aiGenerated,
          ),
          const SizedBox(height: Sp.base),
          const SectionHeader(title: 'AI Analysis'),
          AIAnalysisPanel(
            predictedCategory:
                summarySource?.predictedCategory ?? incident.category.label,
            priority: summarySource?.priority ?? incident.priority.name,
            confidence: summarySource?.confidence ?? 0.0,
            tags: summarySource?.tags ?? incident.tags,
            incidentSummary:
                summarySource?.incidentSummary ?? 'No AI summary available.',
          ),
          const SizedBox(height: Sp.xxxl),
        ],
      ),
    );
  }
}

class _LinkedReportsTab extends StatelessWidget {
  final List<ReportModel> linkedReports;

  const _LinkedReportsTab({required this.linkedReports});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Sp.base),
      children: [
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
                    style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
                    children: [
                      TextSpan(
                        text: '${linkedReports.length} reports ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const TextSpan(
                        text: 'are linked to this incident in Firestore.',
                        style: TextStyle(color: Color(0xFF4338CA)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (linkedReports.isEmpty)
          const EmptyStateWidget(
            icon: Icons.description_outlined,
            title: 'No linked reports',
            message: 'Reports linked to this incident will appear here.',
          )
        else
          ...linkedReports.asMap().entries.map(
                (entry) => _LinkedReportCard(
                  index: entry.key + 1,
                  report: entry.value,
                  onTap: () => context.push(
                    AppRoutes.adminReportPath(entry.value.id),
                  ),
                ),
              ),
      ],
    );
  }
}

class _LinkedReportCard extends StatelessWidget {
  final int index;
  final ReportModel report;
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
                  StatusBadge(status: report.status.name, compact: true),
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
                          report.submittedByName,
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

class _TimelineTab extends StatelessWidget {
  final IncidentModel incident;
  final List<ReportModel> linkedReports;

  const _TimelineTab({required this.incident, required this.linkedReports});

  @override
  Widget build(BuildContext context) {
    final timelineItems = <StatusTimelineItem>[
      StatusTimelineItem(
        status: _statusLabel(incident.status),
        remark: 'Incident record updated in Firestore.',
        timeAgo: _timeAgo(incident.updatedAt),
        author: 'Admin',
      ),
      ...linkedReports
          .expand(
            (report) => report.remarks.map(
              (remark) => StatusTimelineItem(
                status: remark.status,
                remark: remark.remark,
                timeAgo: _timeAgo(remark.updatedAt),
                author: report.submittedByName,
              ),
            ),
          )
          ,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Sp.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Status Timeline',
            subtitle: 'All updates merged chronologically',
          ),
          StatusTimelineWidget(items: timelineItems),
        ],
      ),
    );
  }
}

class _AdminActionBar extends StatelessWidget {
  final VoidCallback onUpdateStatus;

  const _AdminActionBar({required this.onUpdateStatus});

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
              icon: const Icon(Icons.comment_rounded, size: 16),
              label: const Text('Remarks'),
            ),
          ),
          const SizedBox(width: Sp.sm),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: onUpdateStatus,
              icon: const Icon(Icons.update_rounded, size: 16),
              label: const Text('Update Status'),
            ),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(IncidentStatus status) {
  switch (status) {
    case IncidentStatus.active:
      return 'inProgress';
    case IncidentStatus.monitoring:
      return 'underReview';
    case IncidentStatus.resolved:
      return 'resolved';
  }
}

String _timeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
