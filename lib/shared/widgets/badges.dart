// lib/widgets/shared/badges.dart
// RESOLV — Reusable Badge & Chip Widgets

import 'package:flutter/material.dart';
import 'package:resolv/core/themes/ui_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  _StatusStyle _style() {
    switch (status.toLowerCase().replaceAll(' ', '')) {
      case 'pending':
        return _StatusStyle(
          'Pending',
          StatusColors.pending,
          StatusColors.pendingBg,
          Icons.hourglass_empty_rounded,
        );
      case 'underreview':
        return _StatusStyle(
          'Under Review',
          StatusColors.underReview,
          StatusColors.underReviewBg,
          Icons.manage_search_rounded,
        );
      case 'inprogress':
        return _StatusStyle(
          'In Progress',
          StatusColors.inProgress,
          StatusColors.inProgressBg,
          Icons.construction_rounded,
        );
      case 'resolved':
        return _StatusStyle(
          'Resolved',
          StatusColors.resolved,
          StatusColors.resolvedBg,
          Icons.check_circle_rounded,
        );
      case 'rejected':
        return _StatusStyle(
          'Rejected',
          StatusColors.rejected,
          StatusColors.rejectedBg,
          Icons.cancel_rounded,
        );
      default:
        return _StatusStyle(
          status,
          StatusColors.pending,
          StatusColors.pendingBg,
          Icons.circle_outlined,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? Sp.sm : Sp.md,
        vertical: compact ? 3 : Sp.xs,
      ),
      decoration: BoxDecoration(color: s.bg, borderRadius: Radii.chip),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: compact ? 10 : 12, color: s.color),
          const SizedBox(width: 4),
          Text(
            s.label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: s.color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;
  const _StatusStyle(this.label, this.color, this.bg, this.icon);
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIORITY BADGE
// ─────────────────────────────────────────────────────────────────────────────

class PriorityBadge extends StatelessWidget {
  final String priority;
  final bool compact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.compact = false,
  });

  _PriorityStyle _style() {
    switch (priority.toLowerCase()) {
      case 'critical':
        return _PriorityStyle(
          'Critical',
          PriorityColors.critical,
          PriorityColors.criticalBg,
        );
      case 'high':
        return _PriorityStyle(
          'High',
          PriorityColors.high,
          PriorityColors.highBg,
        );
      case 'medium':
        return _PriorityStyle(
          'Medium',
          PriorityColors.medium,
          PriorityColors.mediumBg,
        );
      case 'low':
        return _PriorityStyle('Low', PriorityColors.low, PriorityColors.lowBg);
      default:
        return _PriorityStyle(
          priority,
          PriorityColors.medium,
          PriorityColors.mediumBg,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? Sp.sm : Sp.md,
        vertical: compact ? 2 : Sp.xs,
      ),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: Radii.chip,
        border: Border.all(color: s.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 5 : 6,
            height: compact ? 5 : 6,
            decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            s.label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: s.color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityStyle {
  final String label;
  final Color color;
  final Color bg;
  const _PriorityStyle(this.label, this.color, this.bg);
}

// ─────────────────────────────────────────────────────────────────────────────
// TAG CHIP
// ─────────────────────────────────────────────────────────────────────────────

class TagChip extends StatelessWidget {
  final String label;
  final Color? color;

  const TagChip({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: Radii.chip,
        border: Border.all(color: c.withOpacity(0.25)),
      ),
      child: Text(
        '#$label',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: c.withOpacity(0.85),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI BADGE
// ─────────────────────────────────────────────────────────────────────────────

class AiBadge extends StatelessWidget {
  final bool compact;
  const AiBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : Sp.sm,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: Radii.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: compact ? 9 : 11,
            color: Colors.white,
          ),
          const SizedBox(width: 3),
          Text(
            'AI',
            style: TextStyle(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY CHIP
// ─────────────────────────────────────────────────────────────────────────────

class CategoryChip extends StatelessWidget {
  final String category;

  const CategoryChip({super.key, required this.category});

  (Color, Color, IconData) _style() {
    switch (category.toLowerCase()) {
      case 'infrastructure':
        return (
          CategoryColors.infrastructure,
          CategoryColors.infrastructureBg,
          Icons.construction_rounded,
        );
      case 'environment':
        return (
          CategoryColors.environment,
          CategoryColors.environmentBg,
          Icons.eco_rounded,
        );
      case 'safety':
        return (
          CategoryColors.safety,
          CategoryColors.safetyBg,
          Icons.shield_rounded,
        );
      case 'utilities':
        return (
          CategoryColors.utilities,
          CategoryColors.utilitiesBg,
          Icons.electrical_services_rounded,
        );
      case 'health':
        return (
          CategoryColors.health,
          CategoryColors.healthBg,
          Icons.local_hospital_rounded,
        );
      default:
        return (
          CategoryColors.other,
          CategoryColors.otherBg,
          Icons.category_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, bg, icon) = _style();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: Radii.chip),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
