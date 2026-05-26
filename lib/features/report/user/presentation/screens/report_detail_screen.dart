import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/features/report/user/repositories/report_mock_data.dart';
import 'package:resolv/models/report_ui_model.dart';
import 'package:resolv/routing/app_routes.dart';
import '../widgets/status_badge.dart';

/// Detailed view of a single report for the authenticated user.
/// Shows full description, status timeline, and any admin notes.
///
/// TODO: Replace [report] parameter with a Riverpod provider lookup by ID.
/// TODO: Replace Navigator.pop with GoRouter.
class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, required this.report, this.onBack});

  final ReportUiModel report;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: colors.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: colors.shadow.withOpacity(0.08),
            surfaceTintColor: colors.surface,
            leading: _BackButton(
              onTap: onBack ?? () => context.go(AppRoutes.userReports),
            ),
            title: Text(
              report.id,
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: StatusBadge(
                  status: report.status,
                  size: StatusBadgeSize.medium,
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category + Title ──────────────────────────────────
                  _CategoryRow(category: report.category),
                  const SizedBox(height: 10),
                  Text(
                    report.title,
                    style: text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                      height: 1.25,
                    ),
                  ),

                  // ── Meta Row ──────────────────────────────────────────
                  const SizedBox(height: 12),
                  _MetaRow(report: report),
                  const SizedBox(height: 24),

                  // ── Description Card ──────────────────────────────────
                  _SectionCard(
                    title: 'Description',
                    icon: Icons.description_outlined,
                    child: Text(
                      report.description,
                      style: text.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.85),
                        height: 1.65,
                      ),
                    ),
                  ),

                  // ── Location ──────────────────────────────────────────
                  if (report.address != null) ...[
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Location',
                      icon: Icons.location_on_outlined,
                      child: Text(
                        report.address!,
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurface.withOpacity(0.85),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  // ── Admin Note ────────────────────────────────────────
                  if (report.adminNote != null) ...[
                    const SizedBox(height: 14),
                    _AdminNoteCard(note: report.adminNote!),
                  ],

                  // ── Status Timeline ───────────────────────────────────
                  const SizedBox(height: 24),
                  Text(
                    'Status Timeline',
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _StatusTimeline(report: report),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: text.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ── Admin Note Card ───────────────────────────────────────────────────────────

class _AdminNoteCard extends StatelessWidget {
  const _AdminNoteCard({required this.note});
  final String note;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.secondary.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 15,
                color: colors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Barangay Response',
                style: text.labelMedium?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            note,
            style: text.bodyMedium?.copyWith(
              color: colors.onSecondaryContainer,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Row ──────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});
  final ReportCategory category;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            category.label,
            style: text.labelSmall?.copyWith(
              color: colors.onSecondaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meta Row ──────────────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.report});
  final ReportUiModel report;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final dt = report.submittedAt;
    final formatted =
        '${dt.day}/${dt.month}/${dt.year} at ${_pad(dt.hour)}:${_pad(dt.minute)}';

    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 13,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          'Submitted $formatted',
          style: text.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

// ── Status Timeline ───────────────────────────────────────────────────────────

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.report});
  final ReportUiModel report;

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(report);

    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isLast = i == steps.length - 1;
        return _TimelineStep(step: step, isLast: isLast);
      }),
    );
  }

  List<_TimelineStepData> _buildSteps(ReportUiModel report) {
    final all = [
      _TimelineStepData(
        label: 'Report Submitted',
        subtitle: _formatDt(report.submittedAt),
        isCompleted: true,
        isCurrent: report.status == ReportStatus.pending,
      ),
      _TimelineStepData(
        label: 'Under Review',
        subtitle: report.status == ReportStatus.rejected
            ? 'Report was rejected'
            : report.status.index >= ReportStatus.inProgress.index
            ? report.updatedAt != null
                  ? _formatDt(report.updatedAt!)
                  : 'Processing'
            : 'Awaiting review',
        isCompleted:
            report.status.index >= ReportStatus.inProgress.index ||
            report.status == ReportStatus.rejected,
        isCurrent: report.status == ReportStatus.inProgress,
        isRejected: report.status == ReportStatus.rejected,
      ),
      _TimelineStepData(
        label: 'Resolved',
        subtitle: report.status == ReportStatus.resolved
            ? (report.updatedAt != null
                  ? _formatDt(report.updatedAt!)
                  : 'Completed')
            : 'Pending resolution',
        isCompleted: report.status == ReportStatus.resolved,
        isCurrent: false,
      ),
    ];
    return all;
  }

  String _formatDt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

class _TimelineStepData {
  const _TimelineStepData({
    required this.label,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
    this.isRejected = false,
  });
  final String label;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isRejected;
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.step, required this.isLast});
  final _TimelineStepData step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final dotColor = step.isRejected
        ? colors.error
        : step.isCompleted
        ? colors.primary
        : step.isCurrent
        ? colors.tertiary
        : colors.outlineVariant;

    final dotIcon = step.isRejected
        ? Icons.close_rounded
        : step.isCompleted
        ? Icons.check_rounded
        : step.isCurrent
        ? Icons.radio_button_checked_rounded
        : Icons.radio_button_unchecked_rounded;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot + Line column
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: step.isCompleted || step.isRejected || step.isCurrent
                        ? dotColor.withOpacity(0.15)
                        : colors.surfaceContainerLow,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: 1.5),
                  ),
                  child: Icon(dotIcon, size: 14, color: dotColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: step.isCompleted
                          ? colors.primary.withOpacity(0.3)
                          : colors.outlineVariant.withOpacity(0.4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    step.label,
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          step.isCompleted || step.isCurrent || step.isRejected
                          ? colors.onSurface
                          : colors.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
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

// ── Back Button ───────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: colors.onSurface,
          size: 20,
        ),
      ),
    );
  }
}
