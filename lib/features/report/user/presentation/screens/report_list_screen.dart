import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/features/auth/presentation/controllers/auth_controller.dart';
import 'package:resolv/features/report/providers/user_report_providers.dart';
import 'package:resolv/features/report/user/presentation/widgets/report_filter.dart';
import 'package:resolv/features/report/user/repositories/report_mock_data.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/models/report_ui_model.dart';
import 'package:resolv/routing/app_routes.dart';
import '../widgets/report_card.dart';
import '../widgets/report_empty_state.dart';

/// Displays the authenticated user's submitted reports.
/// Supports status filtering via [ReportFilterBar].
/// TODO: Connect [onNavigateToCreate] and [onNavigateToDetail] to GoRouter.
class ReportListScreen extends ConsumerStatefulWidget {
  const ReportListScreen({
    super.key,
    this.onNavigateToCreate,
    this.onNavigateToDetail,
  });

  final VoidCallback? onNavigateToCreate;
  final ValueChanged<ReportUiModel>? onNavigateToDetail;

  @override
  ConsumerState<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends ConsumerState<ReportListScreen> {
  ReportStatus? _activeFilter;

  List<ReportUiModel> _mapReports(List<ReportModel> reports) {
    return reports
        .map(
          (report) => ReportUiModel(
            id: report.id,
            title: report.title,
            description: report.description,
            category: report.category,
            status: report.status,
            submittedAt: report.submittedAt,
            submittedByName: report.submittedByName,
            address: report.address,
            imageUrl: report.imageUrl,
            updatedAt: report.updatedAt,
          ),
        )
        .toList();
  }

  List<ReportUiModel> _filteredReports(List<ReportUiModel> reports) {
    return _activeFilter == null
        ? reports
        : reports.where((report) => report.status == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final reportsAsync = ref.watch(reportControllerProvider);

    return reportsAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.surface,
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Failed to load reports: $error',
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
      data: (reports) {
        final uiReports = _mapReports(reports ?? const <ReportModel>[]);
        final filteredReports = _filteredReports(uiReports);

        return Scaffold(
          backgroundColor: colors.surface,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── App Bar ───────────────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  backgroundColor: colors.surface,
                  elevation: 0,
                  scrolledUnderElevation: 1,
                  shadowColor: colors.shadow.withOpacity(0.08),
                  surfaceTintColor: colors.surface,
                  leading: IconButton(
                    onPressed: () => context.go(AppRoutes.userHome),
                    icon: Icon(Icons.arrow_back, color: colors.onSurface),
                  ),
                  title: Text(
                    'My Reports',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  actions: [
                    _StatsSummaryBadge(reports: uiReports),
                    const SizedBox(width: 16),
                  ],
                ),

                // ── Stats Row ─────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: _UserStatsRow(reports: uiReports),
                  ),
                ),

                // ── Filter Bar ────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 4),
                    child: ReportFilterBar(
                      onFilterChanged: (s) => setState(() => _activeFilter = s),
                    ),
                  ),
                ),

                // ── Section header ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Row(
                      children: [
                        Text(
                          _activeFilter == null
                              ? 'All Reports'
                              : '${_activeFilter!.label} Reports',
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${filteredReports.length}',
                            style: text.labelSmall?.copyWith(
                              color: colors.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        MaterialButton(
                          onPressed: () {
                            ref.read(authControllerProvider.notifier).signOut();
                          },
                          child: const Text('Log out'),
                        ), // TODO: Remove this after testing
                      ],
                    ),
                  ),
                ),

                // ── Report List ───────────────────────────────────────────────
                filteredReports.isEmpty
                    ? SliverFillRemaining(
                        child: ReportEmptyState(
                          title: 'No ${_activeFilter?.label ?? ''} reports',
                          subtitle:
                              'Try selecting a different filter or submit a new report.',
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        sliver: SliverList.separated(
                          itemCount: filteredReports.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final report = filteredReports[index];
                            return ReportCard(
                              report: report,
                              onTap: () => context.go(
                                AppRoutes.userReportPath(report.id),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.go(AppRoutes.userHome),
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            elevation: 3,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'New Report',
              style: text.labelLarge?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}

// ── Mini Stats Badge ──────────────────────────────────────────────────────────

class _StatsSummaryBadge extends StatelessWidget {
  const _StatsSummaryBadge({required this.reports});

  final List<ReportUiModel> reports;

  @override
  Widget build(BuildContext context) {
    final pendingCount = reports
        .where(
          (r) =>
              r.status == ReportStatus.pending ||
              r.status == ReportStatus.inProgress,
        )
        .length;

    if (pendingCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE047).withOpacity(0.7)),
      ),
      child: Text(
        '$pendingCount active',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF854D0E),
        ),
      ),
    );
  }
}

// ── User Stats Row ────────────────────────────────────────────────────────────

class _UserStatsRow extends StatelessWidget {
  const _UserStatsRow({required this.reports});

  final List<ReportUiModel> reports;

  @override
  Widget build(BuildContext context) {
    final pending = reports
        .where((r) => r.status == ReportStatus.pending)
        .length;
    final inProgress = reports
        .where((r) => r.status == ReportStatus.inProgress)
        .length;
    final resolved = reports
        .where((r) => r.status == ReportStatus.resolved)
        .length;

    return Row(
      children: [
        _StatTile(
          count: reports.length,
          label: 'Total',
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 10),
        _StatTile(
          count: pending,
          label: 'Pending',
          color: const Color(0xFFCA8A04),
        ),
        const SizedBox(width: 10),
        _StatTile(
          count: inProgress,
          label: 'In Progress',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        const SizedBox(width: 10),
        _StatTile(
          count: resolved,
          label: 'Resolved',
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outlineVariant.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: text.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
