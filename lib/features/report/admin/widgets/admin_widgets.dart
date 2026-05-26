// lib/widgets/admin/admin_widgets.dart
// RESOLV — Admin-Specific UI Widgets

import 'package:flutter/material.dart';
import 'package:resolv/core/themes/ui_constants.dart';
import 'package:resolv/shared/widgets/badges.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AI ANALYSIS PANEL
// ─────────────────────────────────────────────────────────────────────────────

class AIAnalysisPanel extends StatelessWidget {
  final String predictedCategory;
  final String priority;
  final double confidence;
  final List<String> tags;
  final String incidentSummary;

  const AIAnalysisPanel({
    super.key,
    required this.predictedCategory,
    required this.priority,
    required this.confidence,
    required this.tags,
    required this.incidentSummary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Sp.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.06),
            const Color(0xFF8B5CF6).withOpacity(0.04),
          ],
        ),
        borderRadius: Radii.card,
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Sp.sm),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: Radii.button,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: Sp.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Analysis',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Auto-classified by RESOLV AI',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF6366F1).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Sp.base),

          // AI Summary
          Container(
            padding: const EdgeInsets.all(Sp.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: Radii.button,
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  size: 18,
                  color: Color(0xFF8B5CF6),
                ),
                const SizedBox(width: Sp.sm),
                Expanded(
                  child: Text(
                    incidentSummary.isNotEmpty
                        ? incidentSummary
                        : 'No AI summary available.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Sp.md),

          // Metrics row
          Row(
            children: [
              Expanded(
                child: _AIMetricTile(
                  label: 'Category',
                  child: CategoryChip(category: predictedCategory),
                ),
              ),
              const SizedBox(width: Sp.sm),
              Expanded(
                child: _AIMetricTile(
                  label: 'Priority',
                  child: PriorityBadge(priority: priority),
                ),
              ),
              const SizedBox(width: Sp.sm),
              Expanded(
                child: _AIMetricTile(
                  label: 'Confidence',
                  child: _ConfidenceBar(confidence: confidence),
                ),
              ),
            ],
          ),

          if (tags.isNotEmpty) ...[
            const SizedBox(height: Sp.md),
            Wrap(
              spacing: Sp.xs,
              runSpacing: Sp.xs,
              children: [
                Text(
                  'Tags: ',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ...tags.map(
                  (t) => TagChip(label: t, color: const Color(0xFF6366F1)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AIMetricTile extends StatelessWidget {
  final String label;
  final Widget child;

  const _AIMetricTile({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6366F1).withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  final double confidence;

  const _ConfidenceBar({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).toInt();
    final color = confidence >= 0.8
        ? StatusColors.resolved
        : confidence >= 0.6
        ? StatusColors.pending
        : StatusColors.rejected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$pct%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: Radii.chip,
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: 5,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS TIMELINE WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class StatusTimelineItem {
  final String status;
  final String remark;
  final String timeAgo;
  final String author;

  const StatusTimelineItem({
    required this.status,
    required this.remark,
    required this.timeAgo,
    this.author = 'System',
  });
}

class StatusTimelineWidget extends StatelessWidget {
  final List<StatusTimelineItem> items;

  const StatusTimelineWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(Sp.base),
        child: Text('No status updates yet.', style: theme.textTheme.bodySmall),
      );
    }

    return Column(
      children: List.generate(items.length, (i) {
        final item = items[i];
        final isLast = i == items.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line + dot
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    _TimelineDot(status: item.status, isFirst: i == 0),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: Sp.sm),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : Sp.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusBadge(status: item.status, compact: true),
                      const SizedBox(height: Sp.xs),
                      if (item.remark.isNotEmpty)
                        Text(item.remark, style: theme.textTheme.bodySmall),
                      const SizedBox(height: Sp.xs),
                      Text(
                        '${item.author} · ${item.timeAgo}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  final String status;
  final bool isFirst;

  const _TimelineDot({required this.status, this.isFirst = false});

  Color _color() {
    switch (status.toLowerCase().replaceAll(' ', '')) {
      case 'pending':
        return StatusColors.pending;
      case 'underreview':
        return StatusColors.underReview;
      case 'inprogress':
        return StatusColors.inProgress;
      case 'resolved':
        return StatusColors.resolved;
      case 'rejected':
        return StatusColors.rejected;
      default:
        return StatusColors.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: _color().withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: _color(), width: isFirst ? 2.5 : 1.5),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: _color(), shape: BoxShape.circle),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INCIDENT SUMMARY PANEL
// ─────────────────────────────────────────────────────────────────────────────

class IncidentSummaryPanel extends StatelessWidget {
  final int reportCount;
  final String firstReportDate;
  final String lastUpdated;
  final String category;
  final bool aiGenerated;

  const IncidentSummaryPanel({
    super.key,
    required this.reportCount,
    required this.firstReportDate,
    required this.lastUpdated,
    required this.category,
    required this.aiGenerated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Sp.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: Radii.card,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Incident Summary', style: theme.textTheme.titleSmall),
              const Spacer(),
              if (aiGenerated) const AiBadge(),
            ],
          ),
          const Divider(height: Sp.xl),
          _SummaryRow(
            icon: Icons.bar_chart_rounded,
            label: 'Total Reports',
            value: '$reportCount',
            highlight: true,
          ),
          _SummaryRow(
            icon: Icons.category_rounded,
            label: 'Category',
            value: category,
          ),
          _SummaryRow(
            icon: Icons.calendar_today_rounded,
            label: 'First Reported',
            value: firstReportDate,
          ),
          _SummaryRow(
            icon: Icons.update_rounded,
            label: 'Last Activity',
            value: lastUpdated,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: Sp.sm),
          Text(label, style: theme.textTheme.bodySmall),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              color: highlight
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontSize: highlight ? 15 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class ActionBottomSheet extends StatelessWidget {
  final String title;
  final List<_BottomSheetAction> actions;

  const ActionBottomSheet({
    super.key,
    required this.title,
    required this.actions,
  });

  static void show(
    BuildContext context, {
    required String title,
    required List<_BottomSheetAction> actions,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
      ),
      builder: (_) => ActionBottomSheet(title: title, actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Sp.base, Sp.sm, Sp.base, Sp.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: Sp.base),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: Radii.chip,
              ),
            ),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: Sp.md),
            ...actions.map(
              (a) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(Sp.sm),
                  decoration: BoxDecoration(
                    color: (a.color ?? theme.colorScheme.primary).withOpacity(
                      0.1,
                    ),
                    borderRadius: Radii.button,
                  ),
                  child: Icon(
                    a.icon,
                    color: a.color ?? theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  a.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: a.color,
                  ),
                ),
                subtitle: a.subtitle != null ? Text(a.subtitle!) : null,
                shape: RoundedRectangleBorder(borderRadius: Radii.button),
                onTap: () {
                  Navigator.of(context).pop();
                  a.onTap();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetAction {
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _BottomSheetAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.color,
  });
}

// Helper constructor exposed
BottomSheetAction bottomSheetAction({
  required String label,
  String? subtitle,
  required IconData icon,
  Color? color,
  required VoidCallback onTap,
}) => _BottomSheetAction(
  label: label,
  subtitle: subtitle,
  icon: icon,
  color: color,
  onTap: onTap,
);
typedef BottomSheetAction = _BottomSheetAction;
