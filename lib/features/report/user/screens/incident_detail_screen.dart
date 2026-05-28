import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:resolv/core/enums/incident_enums.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/features/report/providers/incident_providers.dart';
import 'package:resolv/features/ai/providers/ai_providers.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class UserIncidentDetailScreen extends ConsumerWidget {
  const UserIncidentDetailScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentAsync = ref.watch(incidentByIdProvider(incidentId));
    final reportsAsync = ref.watch(reportsStreamProvider);

    return incidentAsync.when(
      loading: () => const _LoadingScaffold(),
      error: (e, _) => _ErrorScaffold(message: e.toString()),
      data: (incident) {
        if (incident == null) {
          return const _ErrorScaffold(message: 'Incident not found.');
        }
        return _IncidentDetailBody(incident: incident, reportsAsync: reportsAsync);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Main body
// ---------------------------------------------------------------------------

class _IncidentDetailBody extends StatelessWidget {
  const _IncidentDetailBody({required this.incident, required this.reportsAsync});

  final IncidentModel incident;
  final AsyncValue<List<ReportModel>> reportsAsync;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          _IncidentSliverAppBar(incident: incident),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OverviewSection(incident: incident),
                  const SizedBox(height: 16),
                  _StatusTimeline(remarks: incident.tags),
                  const SizedBox(height: 16),
                  _LinkedReportsSection(
                    reportsAsync: reportsAsync,
                    totalCount: incident.reportCount,
                    incidentId: incident.id,
                  ),
                  // Bottom padding for FAB
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomCTA(incident: incident),
    );
  }
}

// ---------------------------------------------------------------------------
// SliverAppBar
// ---------------------------------------------------------------------------

class _IncidentSliverAppBar extends StatelessWidget {
  const _IncidentSliverAppBar({required this.incident});
  final IncidentModel incident;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.85),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back, size: 20, color: colorScheme.onSurface),
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _categoryColor(incident.category, colorScheme),
                _categoryColor(incident.category, colorScheme).withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      _CategoryChip(category: incident.category),
                      const SizedBox(width: 8),
                      _StatusBadge(status: incident.status),
                      const SizedBox(width: 8),
                      _PriorityBadge(priority: incident.priority),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    incident.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _categoryColor(ReportCategory cat, ColorScheme cs) {
    switch (cat) {
      case ReportCategory.infrastructure:
        return const Color(0xFF1E6B9A);
      case ReportCategory.noise:
        return const Color(0xFFB84D00);
      case ReportCategory.sanitation:
        return const Color(0xFF2E7D32);
      case ReportCategory.publicSafety:
        return const Color(0xFF0D6D56);
      case ReportCategory.other:
        return const Color(0xFF6A1B9A);
      case ReportCategory.flooding:
        return const Color(0xFF1565C0);
      case ReportCategory.streetLight:
        return const Color(0xFFF57C00);
    }
  }
}

// ---------------------------------------------------------------------------
// Overview section
// ---------------------------------------------------------------------------

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.incident});
  final IncidentModel incident;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fmt = DateFormat('MMM d, yyyy • h:mm a');

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Overview',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              if (incident.aiGenerated) ...[const SizedBox(width: 8), _AiBadge()],
            ],
          ),
          const SizedBox(height: 12),
          // Tags
          if (incident.tags.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: incident.tags.map((t) => _TagChip(label: t)).toList(),
            ),
            const SizedBox(height: 16),
          ],
          // Stats row
          Row(
            children: [
              _StatItem(
                icon: Icons.description_outlined,
                label: 'Reports',
                value: incident.reportCount.toString(),
              ),
              const SizedBox(width: 16),
              _StatItem(
                icon: Icons.calendar_today_outlined,
                label: 'Reported',
                value: fmt.format(incident.createdAt),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatItem(
                icon: Icons.update_outlined,
                label: 'Last update',
                value: fmt.format(incident.updatedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status timeline
// ---------------------------------------------------------------------------

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.remarks});
  final List<String> remarks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (remarks.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_outlined, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Progress Updates',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: remarks.map((r) => _TagChip(label: r)).toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Linked reports section
// ---------------------------------------------------------------------------

class _LinkedReportsSection extends StatelessWidget {
  const _LinkedReportsSection({
    required this.reportsAsync,
    required this.totalCount,
    required this.incidentId,
  });

  final AsyncValue<List<ReportModel>> reportsAsync;
  final int totalCount;
  final String incidentId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_copy_outlined, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Community Reports',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '$totalCount total',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          reportsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => Text('Could not load reports.', style: theme.textTheme.bodySmall),
            data: (reports) {
              final linked = reports.where((r) => r.incidentId == incidentId).toList();
              if (linked.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No reports linked yet.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              final preview = linked.take(3).toList();
              return Column(
                children: [
                  ...preview.map((r) => _ReportPreviewTile(report: r)),
                  if (linked.length > 3) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: navigate to all reports for this incident
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: Text('View all $totalCount reports'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReportPreviewTile extends StatelessWidget {
  const _ReportPreviewTile({required this.report});
  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fmt = DateFormat('MMM d, h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
            child: Icon(Icons.person_outline, size: 18, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (report.submittedByName.isNotEmpty)
                  Text(
                    report.submittedByName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            fmt.format(report.submittedAt),
            style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom CTA
// ---------------------------------------------------------------------------

class _BottomCTA extends StatelessWidget {
  const _BottomCTA({required this.incident});
  final IncidentModel incident;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Share incident
              },
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                // TODO: navigate to submit report, pre-fill incidentId
              },
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Submit Related Report'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: child,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Flexible(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});
  final ReportCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Text(
        category.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      IncidentStatus.active => ('Active', const Color(0xFF1565C0), Colors.white),
      IncidentStatus.monitoring => ('Monitoring', const Color(0xFFE65100), Colors.white),
      IncidentStatus.resolved => ('Resolved', const Color(0xFF2E7D32), Colors.white),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final IncidentPriority priority;

  @override
  Widget build(BuildContext context) {
    final label = switch (priority) {
      IncidentPriority.low => 'Low',
      IncidentPriority.medium => 'Medium',
      IncidentPriority.high => 'High',
      IncidentPriority.critical => 'Critical',
    };

    final color = switch (priority) {
      IncidentPriority.low => const Color(0xFF388E3C),
      IncidentPriority.medium => const Color(0xFFF57C00),
      IncidentPriority.high => const Color(0xFFD32F2F),
      IncidentPriority.critical => const Color(0xFF7B1FA2),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$label',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 11, color: colorScheme.onTertiaryContainer),
          const SizedBox(width: 4),
          Text(
            'AI Summary',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading / Error scaffolds
// ---------------------------------------------------------------------------

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
