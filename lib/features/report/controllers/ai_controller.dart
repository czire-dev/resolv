import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resolv/core/enums/incident_enums.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/services/incident_service.dart';
import 'package:resolv/services/report_service.dart';
import 'package:resolv/features/report/repositories/ai_repository.dart';

/// Controller for AI-driven report analysis and incident management.
/// Orchestrates the workflow for classifying reports and deduplicating incidents.
class AiController {
  final AiRepository _aiRepository;
  final ReportService _reportService;
  final IncidentService _incidentService;
  final FirebaseFirestore _firestore;

  static const String _incidentsCollection = 'incidents';
  static const Duration _activeIncidentWindow = Duration(hours: 2);

  AiController({
    required AiRepository aiRepository,
    required ReportService reportService,
    required IncidentService incidentService,
    FirebaseFirestore? firestore,
  }) : _aiRepository = aiRepository,
       _reportService = reportService,
       _incidentService = incidentService,
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Main workflow: Analyze report and create/attach incident.
  /// 1. Classify the report
  /// 2. Fetch active incidents in same category
  /// 3. Check for duplicates
  /// 4. Create new incident or attach to existing one
  /// 5. Update report with analysis and incident reference
  Future<Result<AnalysisWorkflowResult>> analyzeAndProcessReport({
    required ReportModel report,
  }) async {
    try {
      // Step 1: Classify the report
      final classifyResult = await _aiRepository.classifyReport(
        title: report.title,
        description: report.description,
      );

      if (classifyResult.isFailure) {
        return Result.failure(classifyResult.error!);
      }

      final aiAnalysis = classifyResult.data!;

      // Step 2: Query for active incidents in the same category
      final activeIncidents = await _queryActiveIncidents(report.category);

      // Step 3: Check for duplicates
      String? matchingIncidentId;
      int bestConfidence = 0;

      for (final incident in activeIncidents) {
        final duplicateResult = await _aiRepository.checkDuplicate(
          report: report,
          incident: incident,
        );

        if (duplicateResult.isSuccess) {
          final checkResult = duplicateResult.data!;
          if (checkResult.isDuplicateWithThreshold) {
            matchingIncidentId = incident.id;
            bestConfidence = checkResult.confidence;
            break;
          }
        }
      }

      // Step 4a: Duplicate found - attach to existing incident
      if (matchingIncidentId != null) {
        final updateResult = await _attachReportToIncident(
          reportId: report.id,
          incidentId: matchingIncidentId,
          aiAnalysis: aiAnalysis,
          isDuplicate: true,
        );

        if (updateResult.isFailure) {
          return Result.failure(updateResult.error!);
        }

        return Result.success(
          AnalysisWorkflowResult(
            reportId: report.id,
            incidentId: matchingIncidentId,
            isDuplicate: true,
            aiAnalysis: aiAnalysis,
            confidence: bestConfidence,
          ),
        );
      }

      // Step 4b: No duplicate - create new incident
      final newIncidentResult = await _createNewIncident(
        report: report,
        aiAnalysis: aiAnalysis,
      );

      if (newIncidentResult.isFailure) {
        return Result.failure(newIncidentResult.error!);
      }

      final newIncident = newIncidentResult.data!;

      // Update report with incident reference
      final updateResult = await _attachReportToIncident(
        reportId: report.id,
        incidentId: newIncident.id,
        aiAnalysis: aiAnalysis,
        isDuplicate: false,
      );

      if (updateResult.isFailure) {
        return Result.failure(updateResult.error!);
      }

      return Result.success(
        AnalysisWorkflowResult(
          reportId: report.id,
          incidentId: newIncident.id,
          isDuplicate: false,
          aiAnalysis: aiAnalysis,
          confidence: aiAnalysis.confidence.toInt(),
        ),
      );
    } catch (e) {
      return Result.failure(Failure('AI workflow failed: $e'));
    }
  }

  /// Fetches active incidents in a specific category within the time window.
  Future<List<IncidentModel>> _queryActiveIncidents(
    ReportCategory category,
  ) async {
    try {
      final cutoffTime = DateTime.now().subtract(_activeIncidentWindow);

      final snapshot = await _firestore
          .collection(_incidentsCollection)
          .where('category', isEqualTo: category.value)
          .where('status', isEqualTo: IncidentStatus.active.name)
          .where('lastReportAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
          .get();

      return snapshot.docs.map((doc) => IncidentModel.fromDoc(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Creates a new incident from a report and AI analysis.
  Future<Result<IncidentModel>> _createNewIncident({
    required ReportModel report,
    required AiAnalysis aiAnalysis,
  }) async {
    try {
      final now = DateTime.now();
      final incidentData = {
        'title': aiAnalysis.incidentSummary,
        'category': report.category.value,
        'priority': aiAnalysis.priority,
        'status': IncidentStatus.active.name,
        'tags': aiAnalysis.tags,
        'reportCount': 1,
        'reportIds': [report.id],
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'lastReportAt': Timestamp.fromDate(now),
        'aiGenerated': true,
      };

      final result = await _incidentService.createIncident(incidentData);

      if (result.isSuccess) {
        return Result.success(result.data!);
      } else {
        return Result.failure(result.error!);
      }
    } catch (e) {
      return Result.failure(Failure('Failed to create incident: $e'));
    }
  }

  /// Attaches a report to an existing incident and updates counts.
  Future<Result<void>> _attachReportToIncident({
    required String reportId,
    required String incidentId,
    required AiAnalysis aiAnalysis,
    required bool isDuplicate,
  }) async {
    try {
      // Update report with incident reference and AI analysis
      final reportUpdateResult = await _reportService.updateReport(reportId, {
        'incidentId': incidentId,
        'aiAnalysis': aiAnalysis.toJson(),
        'isDuplicate': isDuplicate,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (reportUpdateResult.isFailure) {
        return Result.failure(reportUpdateResult.error!);
      }

      // Update incident: increment reportCount and add reportId
      await _firestore.collection(_incidentsCollection).doc(incidentId).update({
        'reportIds': FieldValue.arrayUnion([reportId]),
        'reportCount': FieldValue.increment(1),
        'lastReportAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure('Failed to attach report to incident: $e'));
    }
  }
}

/// Alias for AiAnalysisModel to simplify type hints
typedef AiAnalysis = dynamic;

/// Result of the complete AI analysis workflow.
class AnalysisWorkflowResult {
  final String reportId;
  final String incidentId;
  final bool isDuplicate;
  final dynamic aiAnalysis;
  final int confidence;

  const AnalysisWorkflowResult({
    required this.reportId,
    required this.incidentId,
    required this.isDuplicate,
    required this.aiAnalysis,
    required this.confidence,
  });
}
