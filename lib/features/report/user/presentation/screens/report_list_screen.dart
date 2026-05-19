import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/features/report/user/presentation/widgets/report_filter.dart';
import 'package:resolv/features/report/user/repositories/report_mock_data.dart';
import 'package:resolv/routing/app_route.dart';
import '../widgets/report_card.dart';
import '../widgets/report_empty_state.dart';

/// Displays the authenticated user's submitted reports.
/// Supports status filtering via [ReportFilterBar].
///
/// TODO: Replace [kMockReports] with a Riverpod provider.
/// TODO: Connect [onNavigateToCreate] and [onNavigateToDetail] to GoRouter.
class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key, this.onNavigateToCreate, this.onNavigateToDetail});

  final VoidCallback? onNavigateToCreate;
  final ValueChanged<ReportUiModel>? onNavigateToDetail;

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  ReportStatus? _activeFilter;

  List<ReportUiModel> get _filtered => _activeFilter == null
      ? kMockReports
      : kMockReports.where((r) => r.status == _activeFilter).toList();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

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
              title: Text(
                'My Reports',
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              actions: [
                // Summary badge
                _StatsSummaryBadge(reports: kMockReports),
                const SizedBox(width: 16),
              ],
            ),

            // ── Stats Row ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: _UserStatsRow(reports: kMockReports),
              ),
            ),

            // ── Filter Bar ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 4),
                child: ReportFilterBar(onFilterChanged: (s) => setState(() => _activeFilter = s)),
              ),
            ),

            // ── Section header ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    Text(
                      _activeFilter == null ? 'All Reports' : '${_activeFilter!.label} Reports',
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_filtered.length}',
                        style: text.labelSmall?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Report List ───────────────────────────────────────────────
            _filtered.isEmpty
                ? SliverFillRemaining(
                    child: ReportEmptyState(
                      title: 'No ${_activeFilter?.label ?? ''} reports',
                      subtitle: 'Try selecting a different filter or submit a new report.',
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    sliver: SliverList.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final report = _filtered[index];
                        return ReportCard(
                          report: report,
                          onTap: () =>
                              context.go(AppRoute.reportDetail.replaceFirst(':id', report.id)),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoute.createReport),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New Report',
          style: text.labelLarge?.copyWith(color: colors.onPrimary, fontWeight: FontWeight.w700),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// ── Mini Stats Badge ──────────────────────────────────────────────────────────

class _StatsSummaryBadge extends StatelessWidget {
  const _StatsSummaryBadge({required this.reports});

  final List<ReportUiModel> reports;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pendingCount = reports
        .where((r) => r.status == ReportStatus.pending || r.status == ReportStatus.inProgress)
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
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF854D0E)),
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
    final pending = reports.where((r) => r.status == ReportStatus.pending).length;
    final inProgress = reports.where((r) => r.status == ReportStatus.inProgress).length;
    final resolved = reports.where((r) => r.status == ReportStatus.resolved).length;

    return Row(
      children: [
        _StatTile(
          count: reports.length,
          label: 'Total',
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 10),
        _StatTile(count: pending, label: 'Pending', color: const Color(0xFFCA8A04)),
        const SizedBox(width: 10),
        _StatTile(
          count: inProgress,
          label: 'In Progress',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        const SizedBox(width: 10),
        _StatTile(count: resolved, label: 'Resolved', color: Theme.of(context).colorScheme.primary),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.count, required this.label, required this.color});

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
              style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
