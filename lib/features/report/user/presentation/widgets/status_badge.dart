import 'package:flutter/material.dart';
import 'package:resolv/features/report/user/repositories/report_mock_data.dart';

/// Compact status pill badge for displaying a report's current lifecycle state.
/// Uses semantic color tokens from the active theme.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.size = StatusBadgeSize.medium,
  });

  final ReportStatus status;
  final StatusBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final config = _BadgeConfig.from(status, colors);

    final fontSize = switch (size) {
      StatusBadgeSize.small  => 10.0,
      StatusBadgeSize.medium => 11.5,
      StatusBadgeSize.large  => 13.0,
    };
    final iconSize = switch (size) {
      StatusBadgeSize.small  => 9.0,
      StatusBadgeSize.medium => 11.0,
      StatusBadgeSize.large  => 13.0,
    };
    final hPad = switch (size) {
      StatusBadgeSize.small  => 7.0,
      StatusBadgeSize.medium => 10.0,
      StatusBadgeSize.large  => 12.0,
    };
    final vPad = switch (size) {
      StatusBadgeSize.small  => 3.0,
      StatusBadgeSize.medium => 4.5,
      StatusBadgeSize.large  => 6.0,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: config.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: config.dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: config.foreground,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusBadgeSize { small, medium, large }

class _BadgeConfig {
  const _BadgeConfig({
    required this.background,
    required this.foreground,
    required this.dot,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color dot;
  final Color border;

  factory _BadgeConfig.from(ReportStatus status, ColorScheme colors) {
    switch (status) {
      case ReportStatus.pending:
        return _BadgeConfig(
          background: const Color(0xFFFEF9C3),
          foreground: const Color(0xFF854D0E),
          dot: const Color(0xFFCA8A04),
          border: const Color(0xFFFDE047).withOpacity(0.6),
        );
      case ReportStatus.inProgress:
        return _BadgeConfig(
          background: colors.tertiaryContainer,
          foreground: colors.onTertiaryContainer,
          dot: colors.tertiary,
          border: colors.tertiary.withOpacity(0.3),
        );
      case ReportStatus.resolved:
        return _BadgeConfig(
          background: colors.primaryContainer,
          foreground: colors.onPrimaryContainer,
          dot: colors.primary,
          border: colors.primary.withOpacity(0.3),
        );
      case ReportStatus.rejected:
        return _BadgeConfig(
          background: colors.errorContainer,
          foreground: colors.onErrorContainer,
          dot: colors.error,
          border: colors.error.withOpacity(0.3),
        );
    }
  }
}