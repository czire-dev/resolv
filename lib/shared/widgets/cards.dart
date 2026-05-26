// lib/widgets/shared/cards.dart
// RESOLV — Reusable Card Widgets

import 'package:flutter/material.dart';
import 'package:resolv/core/themes/ui_constants.dart';
import 'badges.dart';

// ─────────────────────────────────────────────────────────────────────────────
// INCIDENT CARD  (Deduplicated group — core UI concept)
// ─────────────────────────────────────────────────────────────────────────────

class IncidentCard extends StatelessWidget {
  final String id;
  final String title;
  final String category;
  final String priority;
  final String status;
  final int reportCount;
  final String lastUpdated;
  final bool aiGenerated;
  final List<String> tags;
  final VoidCallback? onTap;

  const IncidentCard({
    super.key,
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.status,
    required this.reportCount,
    required this.lastUpdated,
    this.aiGenerated = false,
    this.tags = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: Sp.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: Radii.card,
          boxShadow: AppShadows.card,
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            // ── Deduplication indicator bar ──
            _DeduplicationBar(reportCount: reportCount),
            Padding(
              padding: const EdgeInsets.all(Sp.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row: badges ──
                  Row(
                    children: [
                      CategoryChip(category: category),
                      const SizedBox(width: Sp.sm),
                      if (aiGenerated) ...[
                        const AiBadge(),
                        const SizedBox(width: Sp.sm),
                      ],
                      const Spacer(),
                      PriorityBadge(priority: priority, compact: true),
                    ],
                  ),
                  const SizedBox(height: Sp.md),

                  // ── Title ──
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Sp.md),

                  // ── Tags ──
                  if (tags.isNotEmpty) ...[
                    Wrap(
                      spacing: Sp.xs,
                      runSpacing: Sp.xs,
                      children: tags
                          .take(3)
                          .map((t) => TagChip(label: t))
                          .toList(),
                    ),
                    const SizedBox(height: Sp.md),
                  ],

                  // ── Footer ──
                  Row(
                    children: [
                      StatusBadge(status: status, compact: true),
                      const Spacer(),
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(lastUpdated, style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shows the deduplication count visually at top of card
class _DeduplicationBar extends StatelessWidget {
  final int reportCount;

  const _DeduplicationBar({required this.reportCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.base, vertical: Sp.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.06),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Radii.lg),
          topRight: Radius.circular(Radii.lg),
        ),
      ),
      child: Row(
        children: [
          // Stacked dots to represent merged reports
          SizedBox(
            width: reportCount.clamp(1, 5) * 10 + 8.0,
            height: 16,
            child: Stack(
              children: List.generate(
                reportCount.clamp(1, 5),
                (i) => Positioned(
                  left: i * 9.0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(
                        0.15 + i * 0.08,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surfaceContainerLowest,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_rounded,
                        size: 8,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: Sp.sm),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$reportCount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                TextSpan(
                  text:
                      ' report${reportCount != 1 ? 's' : ''} merged into this incident',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Icon(
            Icons.call_merge_rounded,
            size: 14,
            color: theme.colorScheme.primary.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REPORT CARD (individual report within an incident or list)
// ─────────────────────────────────────────────────────────────────────────────

class ReportCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String submittedAt;
  final String address;
  final String? imageUrl;
  final bool isDuplicate;
  final bool isLinkedToIncident;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.submittedAt,
    required this.address,
    this.imageUrl,
    this.isDuplicate = false,
    this.isLinkedToIncident = false,
    this.onTap,
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
          boxShadow: AppShadows.card,
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar (status color)
              _StatusAccentBar(status: status),
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Sp.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CategoryChip(category: category),
                          const Spacer(),
                          StatusBadge(status: status, compact: true),
                        ],
                      ),
                      const SizedBox(height: Sp.sm),
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Sp.xs),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Sp.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              address,
                              style: theme.textTheme.labelSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: Sp.sm),
                          Text(submittedAt, style: theme.textTheme.labelSmall),
                        ],
                      ),
                      if (isDuplicate) ...[
                        const SizedBox(height: Sp.xs),
                        _DuplicatePill(),
                      ],
                    ],
                  ),
                ),
              ),
              // Image preview
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(Radii.lg),
                    bottomRight: Radius.circular(Radii.lg),
                  ),
                  child: Image.network(
                    imageUrl!,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusAccentBar extends StatelessWidget {
  final String status;
  const _StatusAccentBar({required this.status});

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
      width: 4,
      decoration: BoxDecoration(
        color: _color(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Radii.lg),
          bottomLeft: Radius.circular(Radii.lg),
        ),
      ),
    );
  }
}

class _DuplicatePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: Radii.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.call_merge_rounded, size: 10, color: Color(0xFF6366F1)),
          SizedBox(width: 3),
          Text(
            'Merged into incident',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD METRIC CARD
// ─────────────────────────────────────────────────────────────────────────────

class DashboardMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String? subtitle;

  const DashboardMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Sp.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: Radii.card,
        boxShadow: AppShadows.card,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(Sp.sm),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: Radii.button,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: Sp.md),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: theme.textTheme.labelSmall),
          ],
        ],
      ),
    );
  }
}
