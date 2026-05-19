import 'package:flutter/material.dart';
import 'package:resolv/features/report/user/repositories/report_mock_data.dart';
import 'status_badge.dart';

/// Horizontal scrollable filter chips for filtering reports by status.
/// Stateful for visual selection feedback only — no real filtering logic.
class ReportFilterBar extends StatefulWidget {
  const ReportFilterBar({
    super.key,
    this.onFilterChanged,
  });

  /// Callback fires with selected status (null = All).
  /// Wire to real filter logic when backend is ready.
  final ValueChanged<ReportStatus?>? onFilterChanged;

  @override
  State<ReportFilterBar> createState() => _ReportFilterBarState();
}

class _ReportFilterBarState extends State<ReportFilterBar> {
  ReportStatus? _selected;

  void _select(ReportStatus? status) {
    setState(() => _selected = status);
    widget.onFilterChanged?.call(status);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _selected == null,
            onTap: () => _select(null),
          ),
          const SizedBox(width: 8),
          ...ReportStatus.values.map((s) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: s.label,
                status: s,
                isSelected: _selected == s,
                onTap: () => _select(s),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.status,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ReportStatus? status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outlineVariant.withOpacity(0.6),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: text.labelSmall?.copyWith(
            color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}