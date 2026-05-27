import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/core/themes/ui_constants.dart';
import 'package:resolv/features/report/admin/widgets/admin_report_card.dart';
import 'package:resolv/features/report/providers/ai_providers.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/routing/app_routes.dart';
import 'package:resolv/shared/widgets/cards.dart';
import 'package:resolv/shared/widgets/layouts.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String _incidentFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportsAsync = ref.watch(reportsStreamProvider);
    final incidentsAsync =
        ref.watch(incidentsStreamProvider((category: null, status: null)));
    final openIncidentsAsync = ref.watch(openIncidentsStreamProvider);
    final duplicateReportsAsync = ref.watch(duplicateReportsStreamProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _AdminHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(Sp.base, 0, Sp.base, Sp.base),
                child: SearchBarWidget(
                  hintText: 'Search incidents, reports...',
                  onFilterTap: () {},
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _DeduplicationSystemBanner(
                reportsAsync: reportsAsync,
                incidentsAsync: incidentsAsync,
              ),
            ),
            SliverToBoxAdapter(
              child: _KpiSection(
                reportsAsync: reportsAsync,
                incidentsAsync: incidentsAsync,
                openIncidentsAsync: openIncidentsAsync,
                duplicateReportsAsync: duplicateReportsAsync,
              ),
            ),
            SliverToBoxAdapter(
              child: _ReportsListSection(reportsAsync: reportsAsync),
            ),
            SliverToBoxAdapter(
              child: _IncidentListSection(
                incidentsAsync: incidentsAsync,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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
            onPressed: () => context.go(AppRoutes.profile),
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

class _DeduplicationSystemBanner extends StatelessWidget {
  final AsyncValue<List<ReportModel>> reportsAsync;
  final AsyncValue<List<IncidentModel>> incidentsAsync;

  const _DeduplicationSystemBanner({
    required this.reportsAsync,
    required this.incidentsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final groupedReports = _data(reportsAsync)
            ?.where((r) => r.incidentId.trim().isNotEmpty)
            .length ??
        0;
    final incidentCount = _data(incidentsAsync)?.length ?? 0;

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
              child:
                  const Icon(Icons.call_merge_rounded, color: Colors.white, size: 28),
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
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                          text: '$groupedReports reports',
                          style: const TextStyle(
                            color: Color(0xFFA5B4FC),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const TextSpan(
                          text: ' automatically grouped into ',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        TextSpan(
                          text: '$incidentCount incidents',
                          style: const TextStyle(
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
            const Icon(Icons.auto_awesome_rounded,
                color: Color(0xFFA5B4FC), size: 20),
          ],
        ),
      ),
    );
  }
}

class _KpiSection extends StatelessWidget {
  final AsyncValue<List<ReportModel>> reportsAsync;
  final AsyncValue<List<IncidentModel>> incidentsAsync;
  final AsyncValue<List<IncidentModel>> openIncidentsAsync;
  final AsyncValue<List<ReportModel>> duplicateReportsAsync;

  const _KpiSection({
    required this.reportsAsync,
    required this.incidentsAsync,
    required this.openIncidentsAsync,
    required this.duplicateReportsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final reports = _data(reportsAsync) ?? const <ReportModel>[];
    final incidents = _data(incidentsAsync) ?? const <IncidentModel>[];
    final openIncidents = _data(openIncidentsAsync) ?? const <IncidentModel>[];
    final duplicateReports =
      _data(duplicateReportsAsync) ?? const <ReportModel>[];

    final pendingReports =
        reports.where((r) => r.status.name == 'pending').length;
    final highPriority = reports
        .where((r) => (r.aiAnalysis?.priority.toLowerCase() ?? '') == 'high')
        .length;

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
                value: '${openIncidents.length}',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEEF2FF),
                subtitle: 'Across all categories',
              ),
              DashboardMetricCard(
                label: 'Pending Reports',
                value: '$pendingReports',
                icon: Icons.hourglass_empty_rounded,
                color: StatusColors.pending,
                bgColor: StatusColors.pendingBg,
                subtitle: 'Awaiting triage',
              ),
              DashboardMetricCard(
                label: 'High Priority',
                value: '$highPriority',
                icon: Icons.priority_high_rounded,
                color: PriorityColors.critical,
                bgColor: PriorityColors.criticalBg,
                subtitle: 'Needs immediate action',
              ),
              DashboardMetricCard(
                label: 'AI Grouped',
                value: '${duplicateReports.length}',
                icon: Icons.auto_awesome_rounded,
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFEDE9FE),
                subtitle: '${incidents.length} incidents tracked',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportsListSection extends StatelessWidget {
  final AsyncValue<List<ReportModel>> reportsAsync;

  const _ReportsListSection({required this.reportsAsync});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.base, Sp.xl, Sp.base, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Reports',
            subtitle: 'Real-time feed from Firestore',
          ),
          reportsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(Sp.base),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => ErrorStateWidget(message: error.toString()),
            data: (reports) {
              if (reports.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.description_outlined,
                  title: 'No reports yet',
                  message: 'Incoming reports will appear here in real-time.',
                );
              }

              return Column(
                children: reports
                    .map(
                      (report) => AdminReportCard(
                        report: report,
                        onTap: () => context.push(
                          AppRoutes.adminReportPath(report.id),
                        ),
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
}

class _IncidentListSection extends StatelessWidget {
  final AsyncValue<List<IncidentModel>> incidentsAsync;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _IncidentListSection({
    required this.incidentsAsync,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Critical', 'High', 'Active', 'Monitoring'];
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.base, Sp.xl, Sp.base, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Active Incidents',
            subtitle: 'Grouped from multiple community reports',
          ),
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
          incidentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(Sp.base),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => ErrorStateWidget(message: error.toString()),
            data: (incidents) {
              final filtered = _applyIncidentFilter(incidents, selectedFilter);

              if (filtered.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.folder_open_rounded,
                  title: 'No incidents found',
                  message: 'No incidents match the selected filter.',
                );
              }

              return Column(
                children: filtered
                    .map(
                      (incident) => IncidentCard(
                        id: incident.id,
                        title: incident.title,
                        category: incident.category.label,
                        priority: incident.priority.name,
                        status: incident.status.name,
                        reportCount: incident.reportCount,
                        lastUpdated: _timeAgo(incident.updatedAt),
                        aiGenerated: incident.aiGenerated,
                        tags: incident.tags,
                        onTap: () => context.push(
                          AppRoutes.adminIncidentDetail(incident.id),
                        ),
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

  List<IncidentModel> _applyIncidentFilter(
    List<IncidentModel> incidents,
    String filter,
  ) {
    if (filter == 'All') return incidents;

    final normalized = filter.toLowerCase();
    return incidents.where((incident) {
      if (normalized == 'active' || normalized == 'monitoring') {
        return incident.status.name == normalized;
      }
      return incident.priority.name == normalized;
    }).toList();
  }
}

String _timeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

T? _data<T>(AsyncValue<T> value) {
  return value.maybeWhen(data: (data) => data, orElse: () => null);
}
