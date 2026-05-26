import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resolv/features/report/providers/user_report_providers.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/report_model.dart';

// ── Admin Report List Notifier ──────────────────────────

class AdminReportListNotifier extends AsyncNotifier<List<ReportModel>> {
  bool _hasMore = true;

  @override
  Future<List<ReportModel>> build() async {
    _hasMore = true;

    final result = await ref.watch(_adminReportsStreamProvider.future);
    return result.isSuccess ? result.data ?? [] : [];
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final currentReports = state.asData?.value ?? [];
    if (currentReports.isEmpty) return;

    final lastReport = currentReports.last;
    final lastDoc = await ref.read(reportRepositoryProvider).getReportDocument(lastReport.id);

    if (lastDoc == null) return;

    final result = await ref
        .read(reportRepositoryProvider)
        .fetchMoreReports(lastDocument: lastDoc, limit: 15);

    if (result.isSuccess) {
      final moreReports = result.data ?? [];
      if (moreReports.length < 15) _hasMore = false;
      state = AsyncData([...currentReports, ...moreReports]);
    } else {
      // Don't overwrite existing data on pagination failure.
      // Surface this separately in the UI if needed.
    }
  }

  bool get hasMore => _hasMore;
}

// Internal stream provider — isolated so the list notifier can watch it
final _adminReportsStreamProvider = StreamProvider<Result<List<ReportModel>>>((ref) {
  return ref.watch(reportRepositoryProvider).streamAllReports(category: null, status: null);
});

final adminReportListProvider = AsyncNotifierProvider<AdminReportListNotifier, List<ReportModel>>(
  AdminReportListNotifier.new,
);
