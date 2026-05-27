import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/features/report/admin/widgets/admin_status_bottom_modal_sheet.dart';
import 'package:resolv/features/report/providers/ai_providers.dart';
import 'package:resolv/models/ai_analysis_model.dart';
import 'package:resolv/models/report_remark_model.dart';
import 'package:resolv/shared/widgets/layouts.dart';

class AdminReportDetailScreen extends ConsumerWidget {
  final String reportId;

  const AdminReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsStreamProvider);

    return reportsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Report Detail')),
        body: ErrorStateWidget(message: error.toString()),
      ),
      data: (reports) {
        final matches = reports.where((r) => r.id == reportId);
        final report = matches.isEmpty ? null : matches.first;

        if (report == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Report Detail')),
            body: const EmptyStateWidget(
              icon: Icons.description_outlined,
              title: 'Report not found',
              message: 'This report may have been removed.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Report Detail'),
            actions: [
              TextButton.icon(
                onPressed: () => AdminStatusBottomSheet.show(context, report),
                icon: const Icon(Icons.edit),
                label: const Text('Update'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  'By ${report.submittedByName} · ${report.address}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(report.status.name.replaceAll('_', ' '))),
                    Chip(label: Text(report.category.label)),
                    Chip(label: Text('Incident: ${report.incidentId.isEmpty ? 'None' : report.incidentId}')),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(report.description),
                const SizedBox(height: 16),
                if (report.imageUrl != null && report.imageUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(report.imageUrl!, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                ],
                if (report.aiAnalysis != null) ...[
                  const Text('AI Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  _AiAnalysisCard(analysis: report.aiAnalysis!),
                  const SizedBox(height: 16),
                ],
                if (report.remarks.isNotEmpty) ...[
                  const Text('Status History', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  ...report.remarks.reversed.map((r) => _RemarkTile(remark: r)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AiAnalysisCard extends StatelessWidget {
  final AiAnalysisModel analysis;
  const _AiAnalysisCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Priority: ${analysis.priority.toUpperCase()}'),
            Text('Suggested Category: ${analysis.predictedCategory}'),
            if (analysis.tags.isNotEmpty)
              Wrap(
                spacing: 4,
                children: analysis.tags
                    .map(
                      (t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _RemarkTile extends StatelessWidget {
  final ReportRemark remark;
  const _RemarkTile({required this.remark});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.circle, size: 8),
      title: Text(
        remark.status.replaceAll('_', ' '),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: remark.remark.isNotEmpty ? Text(remark.remark) : null,
      trailing: Text(
        '${remark.updatedAt.month}/${remark.updatedAt.day}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
