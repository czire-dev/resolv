import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resolv/features/ai/controllers/ai_controller.dart';
import 'package:resolv/features/ai/providers/ai_providers.dart';
import 'package:resolv/models/report_model.dart';

/// State representing the result of an AI analysis workflow.
class AiAnalysisState {
  final String reportId;
  final String incidentId;
  final bool isDuplicate;
  final int confidence;
  final String? error;

  const AiAnalysisState({
    required this.reportId,
    required this.incidentId,
    required this.isDuplicate,
    required this.confidence,
    this.error,
  });

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

/// Notifier for managing AI analysis workflow state.
/// Handles classification and deduplication of reports.
class AiNotifier extends AsyncNotifier<AiAnalysisState?> {
  AiController get _controller => ref.read(aiControllerProvider);

  @override
  FutureOr<AiAnalysisState?> build() async {
    return null;
  }

  /// Triggers the AI analysis workflow for a report.
  /// Classifies the report and determines if it's a duplicate.
  Future<void> analyzeReport(ReportModel report) async {
    state = const AsyncValue.loading();
    print('[AiNotifier] Starting analysis for report ${report.id}');

    final result = await _controller.analyzeAndProcessReport(report: report);

    if (result.isSuccess) {
      final workflow = result.data!;
      print(
        '[AiNotifier] Analysis succeeded: incidentId=${workflow.incidentId}, isDuplicate=${workflow.isDuplicate}',
      );
      state = AsyncValue.data(
        AiAnalysisState(
          reportId: workflow.reportId,
          incidentId: workflow.incidentId,
          isDuplicate: workflow.isDuplicate,
          confidence: workflow.confidence,
        ),
      );

      // Invalidate relevant stream providers to force immediate UI updates
      try {
        print('[AiNotifier] Invalidating stream providers for immediate refresh');
        ref.invalidate(reportsStreamProvider);
        ref.invalidate(duplicateReportsStreamProvider);
        ref.invalidate(openIncidentsStreamProvider);
        // Invalidate the generic incidents family instance used by admin (null filters)
        ref.invalidate(incidentsStreamProvider((category: null, status: null)));
      } catch (e) {
        print('[AiNotifier] Provider invalidation error: $e');
      }
    } else {
      print('[AiNotifier] Analysis failed: ${result.error!.message}');
      state = AsyncValue.error(result.error!.message, StackTrace.current);
    }
  }

  /// Clears the current analysis state.
  void clearState() {
    state = const AsyncValue.data(null);
  }
}
