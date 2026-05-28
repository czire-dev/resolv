import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:resolv/features/report/providers/incident_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/routing/app_routes.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/core/enums/incident_enums.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class UserAllIncidentsScreen extends ConsumerStatefulWidget {
  const UserAllIncidentsScreen({super.key});

  @override
  ConsumerState<UserAllIncidentsScreen> createState() =>
      _UserAllIncidentsScreenState();
}

class _UserAllIncidentsScreenState
    extends ConsumerState<UserAllIncidentsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // null means "All"
  IncidentStatus? _selectedStatus;
  ReportCategory? _selectedCategory;

  final _categories = ReportCategory.values;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IncidentModel> _applyFilters(List<IncidentModel> all) {
    return all.where((inc) {
      final matchesSearch = _searchQuery.isEmpty ||
          inc.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (inc.tags.join(' ').toLowerCase().contains(_searchQuery.toLowerCase()));
        final matchesStatus =
          _selectedStatus == null || inc.status == _selectedStatus;
        final matchesCategory =
          _selectedCategory == null || inc.category == _selectedCategory;
      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final incidentsAsync = ref.watch(incidentStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: colorScheme.surfaceTint,
            title: Text(
              'All Incidents',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(AppRoutes.userHome),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(108),
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search incidents...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Filter chips
                    SizedBox(
                      height: 34,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: _selectedStatus == null &&
                                _selectedCategory == null,
                            onTap: () => setState(() {
                              _selectedStatus = null;
                              _selectedCategory = null;
                            }),
                          ),
                          const SizedBox(width: 6),
                          _FilterChip(
                            label: 'Active',
                            selected: _selectedStatus == IncidentStatus.active,
                            onTap: () => setState(() {
                              _selectedStatus =
                                  _selectedStatus == IncidentStatus.active
                                      ? null
                                      : IncidentStatus.active;
                            }),
                          ),
                          const SizedBox(width: 6),
                          _FilterChip(
                            label: 'Monitoring',
                            selected:
                                _selectedStatus == IncidentStatus.monitoring,
                            onTap: () => setState(() {
                              _selectedStatus =
                                  _selectedStatus == IncidentStatus.monitoring
                                      ? null
                                      : IncidentStatus.monitoring;
                            }),
                          ),
                          const SizedBox(width: 6),
                          _FilterChip(
                            label: 'Resolved',
                            selected:
                                _selectedStatus == IncidentStatus.resolved,
                            onTap: () => setState(() {
                              _selectedStatus =
                                  _selectedStatus == IncidentStatus.resolved
                                      ? null
                                      : IncidentStatus.resolved;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: incidentsAsync.when(
          loading: () => _LoadingSkeletonList(),
          error: (e, _) => _ErrorState(message: e.toString()),
          data: (incidents) {
            final filtered = _applyFilters(incidents);
            if (filtered.isEmpty) {
              return _EmptyState(
                hasSearch: _searchQuery.isNotEmpty ||
                    _selectedStatus != null ||
                    _selectedCategory != null,
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(incidentStreamProvider);
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => IncidentPreviewCard(
                  incident: filtered[i],
                  onTap: () {
                    // Navigate to user incident detail route
                    context.push(AppRoutes.userIncidentDetail(filtered[i].id));
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}

// ---------------------------------------------------------------------------
// Incident Preview Card (reusable)
// ---------------------------------------------------------------------------

class IncidentPreviewCard extends StatelessWidget {
  const IncidentPreviewCard({
    super.key,
    required this.incident,
    required this.onTap,
  });

  final IncidentModel incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fmt = DateFormat('MMM d, h:mm a');

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: badges
                Row(
                  children: [
                    _CategoryTag(category: incident.category),
                    const SizedBox(width: 6),
                    _SmallStatusBadge(status: incident.status),
                    const SizedBox(width: 6),
                    _SmallPriorityBadge(priority: incident.priority),
                    const Spacer(),
                    if (incident.aiGenerated)
                      Icon(Icons.auto_awesome,
                          size: 14,
                          color: colorScheme.tertiary.withOpacity(0.8)),
                  ],
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  incident.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Summary snippet
                if (incident.tags.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    incident.tags.join(', '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                // Bottom row: stats
                Row(
                  children: [
                    Icon(Icons.description_outlined,
                        size: 13, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${incident.reportCount} report${incident.reportCount != 1 ? 's' : ''}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.schedule_outlined,
                        size: 13, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        fmt.format(incident.updatedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        size: 18, color: colorScheme.onSurfaceVariant),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small badge widgets (card-size variants)
// ---------------------------------------------------------------------------

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.category});
  final ReportCategory category;

  static Color _color(String cat) {
    switch (cat.toLowerCase()) {
      case 'infrastructure':
        return const Color(0xFF1565C0);
      case 'safety':
        return const Color(0xFFB71C1C);
      case 'cleanliness':
        return const Color(0xFF2E7D32);
      case 'environment':
        return const Color(0xFF00695C);
      default:
        return const Color(0xFF37474F);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color(category.label).withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color(category.label).withOpacity(0.3)),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          color: _color(category.label),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SmallStatusBadge extends StatelessWidget {
  const _SmallStatusBadge({required this.status});
  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg) = switch (status) {
      IncidentStatus.active => ('Active', const Color(0xFF1565C0)),
      IncidentStatus.monitoring => ('Monitoring', const Color(0xFFE65100)),
      IncidentStatus.resolved => ('Resolved', const Color(0xFF2E7D32)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SmallPriorityBadge extends StatelessWidget {
  const _SmallPriorityBadge({required this.priority});
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.isCategory = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isCategory;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton
// ---------------------------------------------------------------------------

class _LoadingSkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty & error states
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSearch});
  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.inbox_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch
                  ? 'No incidents match your search.'
                  : 'No incidents yet.',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Placeholder detail page (remove when real routing is wired)
// ---------------------------------------------------------------------------

// placeholder removed — routing now navigates to real user incident detail screen