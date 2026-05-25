import 'package:flutter/material.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/features/report/user/repositories/report_mock_data.dart';
import 'status_badge.dart';

/// Tappable report summary card used in both user and admin list screens.
///
/// [showSubmitter] — set true in admin view to display the reporter's name.
/// [onTap]        — navigation callback; connect to GoRouter when ready.
class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report, this.onTap, this.showSubmitter = false});

  final ReportUiModel report;
  final VoidCallback? onTap;
  final bool showSubmitter;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outlineVariant.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row: Category + Status ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  _CategoryChip(category: report.category),
                  const Spacer(),
                  StatusBadge(status: report.status),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Title ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                report.title,
                style: text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),

            // ── Description Preview ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                report.description,
                style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant, height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),

            // ── Divider ─────────────────────────────────────────────────
            Divider(
              height: 1,
              thickness: 1,
              color: colors.outlineVariant.withOpacity(0.4),
              indent: 0,
              endIndent: 0,
            ),

            // ── Footer ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 13),
              child: Row(
                children: [
                  // Report ID
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      report.id,
                      style: text.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Submitter (admin view only)
                  if (showSubmitter) ...[
                    Icon(Icons.person_outline_rounded, size: 12, color: colors.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        report.submittedByName,
                        style: text.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    const Spacer(),

                  // Timestamp
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: colors.onSurfaceVariant.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(report.submittedAt),
                    style: text.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final ReportCategory category;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 5),
          Text(
            category.label,
            style: text.labelSmall?.copyWith(
              color: colors.onSecondaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
