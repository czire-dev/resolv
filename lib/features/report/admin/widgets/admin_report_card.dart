// report/admin/widgets/admin_report_card.dart

import 'package:flutter/material.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/models/report_model.dart';

class AdminReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;

  const AdminReportCard({super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(
          report.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.submittedByName),
            const SizedBox(height: 4),
            Row(
              children: [
                _StatusChip(status: report.status),
                const SizedBox(width: 8),
                if (report.aiAnalysis?.priority != null)
                  _PriorityChip(priority: report.aiAnalysis!.priority!),
              ],
            ),
          ],
        ),
        trailing: Text(
          _formatDate(report.submittedAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final ReportStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ReportStatus.pending => ('Pending', Colors.orange),
      ReportStatus.inProgress => ('In Progress', Colors.blue),
      ReportStatus.resolved => ('Resolved', Colors.green),
      _ => (status.toString(), Colors.grey),
    };

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = switch (priority.toLowerCase()) {
      'high' => Colors.red.shade300,
      'medium' => Colors.amber.shade600,
      'low' => Colors.teal.shade300,
      _ => Colors.grey,
    };

    return Chip(
      label: Text(
        priority.toUpperCase(),
        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
