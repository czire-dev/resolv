import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/ai_analysis_model.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/services/ai/duplicate_check_result.dart';
import 'package:resolv/services/ai_service.dart';

/// Repository layer for AI analysis features.
/// Provides clean API for report classification and duplicate detection.
/// Handles result transformation and error handling.
class AiRepository {
  final AiService _aiService;

  AiRepository(this._aiService);

  /// Classifies a report using AI.
  /// Returns AiAnalysisModel with predicted category, priority, tags, and confidence.
  Future<Result<AiAnalysisModel>> classifyReport({
    required String title,
    required String description,
  }) async {
    final result = await _aiService.classifyReport(
      title: title,
      description: description,
    );

    if (result.isSuccess) {
      return Result.success(result.data!);
    } else {
      return Result.failure(result.error!);
    }
  }

  /// Checks if a report matches an existing incident.
  /// Returns DuplicateCheckResult with sameIncident flag and confidence.
  Future<Result<DuplicateCheckResult>> checkDuplicate({
    required ReportModel report,
    required IncidentModel incident,
  }) async {
    final result = await _aiService.checkDuplicate(
      report: report,
      incident: incident,
    );

    if (result.isSuccess) {
      return Result.success(result.data!);
    } else {
      return Result.failure(result.error!);
    }
  }
}
