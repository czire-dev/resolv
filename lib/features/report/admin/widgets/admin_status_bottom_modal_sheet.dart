// report/admin/widgets/admin_status_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/models/report_model.dart';
import '../controllers/admin_report_detail_controller.dart';

class AdminStatusBottomSheet extends ConsumerWidget {
  final ReportModel report;

  const AdminStatusBottomSheet({super.key, required this.report});

  static const _statuses = [ReportStatus.pending, ReportStatus.inProgress, ReportStatus.resolved];

  static Future<void> show(BuildContext context, ReportModel report) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AdminStatusBottomSheet(report: report),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(adminReportDetailControllerProvider(report));

    return Padding(
      // Respect keyboard inset
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Update Report', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),

          // Status selector
          DropdownButtonFormField<ReportStatus>(
            initialValue: controller.selectedStatus,
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: _statuses
                .map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(s))))
                .toList(),
            onChanged: controller.isSubmitting ? null : (val) => controller.selectStatus(val!),
          ),
          const SizedBox(height: 12),

          // Admin note field
          TextField(
            controller: controller.noteController,
            decoration: const InputDecoration(
              labelText: 'Admin Note (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            enabled: !controller.isSubmitting,
          ),

          if (controller.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              controller.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],

          const SizedBox(height: 16),

          FilledButton(
            onPressed: controller.isSubmitting
                ? null
                : () async {
                    final result = await controller.submitUpdate();
                    if (result.isSuccess && context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Report updated')));
                    }
                  },
            child: controller.isSubmitting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Changes'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _statusLabel(ReportStatus s) => switch (s) {
    ReportStatus.pending => 'Pending',
    ReportStatus.inProgress => 'In Progress',
    ReportStatus.resolved => 'Resolved',
    _ => s.toString(),
  };
}
