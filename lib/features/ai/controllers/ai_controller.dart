import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resolv/core/enums/incident_enums.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/services/incident_service.dart';
import 'package:resolv/services/report_service.dart';
import 'package:resolv/features/ai/repositories/ai_repository.dart';

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
      print('[AI] Starting analysis for report ${report.id}');

      // Step 1: Classify the report
      final classifyResult = await _aiRepository.classifyReport(
        title: report.title,
        description: report.description,
      );

      if (classifyResult.isFailure) {
        print('[AI] Classification failed: ${classifyResult.error}');
        return Result.failure(classifyResult.error!);
      }

      final aiAnalysis = classifyResult.data!;
      print(
        '[AI] Classification result: category=${aiAnalysis.predictedCategory}, priority=${aiAnalysis.priority}, confidence=${aiAnalysis.confidence}',
      );

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
          print(
            '[AI] Duplicate check vs ${incident.id}: sameIncident=${checkResult.sameIncident}, confidence=${checkResult.confidence}',
          );
          if (checkResult.isDuplicateWithThreshold) {
            matchingIncidentId = incident.id;
            bestConfidence = checkResult.confidence;
            print('[AI] Duplicate found! Matching incident: $matchingIncidentId');
            break;
          }
        }
      }

      // Step 4a: Duplicate found - attach to existing incident
      if (matchingIncidentId != null) {
        print('[AI] Attaching report to existing incident: $matchingIncidentId');
        final updateResult = await _attachReportToIncident(
          reportId: report.id,
          incidentId: matchingIncidentId,
          aiAnalysis: aiAnalysis,
          isDuplicate: true,
        );

        if (updateResult.isFailure) {
          print('[AI] Failed to attach report: ${updateResult.error}');
          return Result.failure(updateResult.error!);
        }

        print('[AI] Report successfully attached as duplicate');
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
      print('[AI] No duplicate found. Creating new incident.');
      final newIncidentResult = await _createNewIncident(report: report, aiAnalysis: aiAnalysis);

      if (newIncidentResult.isFailure) {
        print('[AI] Failed to create incident: ${newIncidentResult.error}');
        return Result.failure(newIncidentResult.error!);
      }

      final newIncident = newIncidentResult.data!;
      print('[AI] New incident created: ${newIncident.id}');

      // Update report with incident reference
      final updateResult = await _attachReportToIncident(
        reportId: report.id,
        incidentId: newIncident.id,
        aiAnalysis: aiAnalysis,
        isDuplicate: false,
      );

      if (updateResult.isFailure) {
        print('[AI] Failed to attach new report: ${updateResult.error}');
        return Result.failure(updateResult.error!);
      }

      print('[AI] Report successfully linked to new incident');
      print('[AI] ✓ Analysis workflow complete');
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
      print('[AI] ✗ Workflow failed: $e');
      return Result.failure(Failure('AI workflow failed: $e'));
    }
  }

  /// Fetches active incidents in a specific category within the time window.
  /// Queries by category and status, filters by time client-side to avoid composite index.
  Future<List<IncidentModel>> _queryActiveIncidents(ReportCategory category) async {
    try {
      final cutoffTime = DateTime.now().subtract(_activeIncidentWindow);

      final snapshot = await _firestore
          .collection(_incidentsCollection)
          .where('category', isEqualTo: category.value)
          .where('status', isEqualTo: IncidentStatus.active.name)
          .limit(50) // Fetch more to allow client-side filtering
          .get();

      // Client-side filtering by lastReportAt to avoid composite index
      final incidents = snapshot.docs
          .map((doc) => IncidentModel.fromDoc(doc))
          .where((incident) => incident.lastReportAt.isAfter(cutoffTime))
          .take(10) // Return maximum 10 incidents
          .toList();

      print(
        '[AI] Query active incidents: found ${incidents.length} candidates for category ${category.value}',
      );
      return incidents;
    } catch (e) {
      print('[AI] Error querying active incidents: $e');
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

      print('[AI] Creating incident with title: ${aiAnalysis.incidentSummary}');
      final result = await _incidentService.createIncident(incidentData);

      if (result.isSuccess) {
        print('[AI] Incident created successfully: ${result.data!.id}');
        return Result.success(result.data!);
      } else {
        print('[AI] Failed to create incident: ${result.error}');
        return Result.failure(result.error!);
      }
    } catch (e) {
      print('[AI] Exception in _createNewIncident: $e');
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
      print('[AI] Attaching report $reportId to incident $incidentId (isDuplicate=$isDuplicate)');
      // Update report with incident reference and AI analysis
      final reportUpdateResult = await _reportService.updateReport(reportId, {
        'incidentId': incidentId,
        'aiAnalysis': aiAnalysis.toJson(),
        'isDuplicate': isDuplicate,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (reportUpdateResult.isFailure) {
        print('[AI] Failed to update report: ${reportUpdateResult.error}');
        return Result.failure(reportUpdateResult.error!);
      }

      // Use a transaction to ensure idempotent addition of reportId and safe reportCount updates.
      final incidentRef = _firestore.collection(_incidentsCollection).doc(incidentId);

      await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(incidentRef);
        if (!snapshot.exists) {
          throw Exception('Incident $incidentId does not exist');
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final existingIds = <String>[...((data['reportIds'] as List?)?.map((e) => e.toString()) ?? [])];
        final existingCount = (data['reportCount'] is int) ? data['reportCount'] as int : existingIds.length;

        // If reportId already present, do not increment. Ensure reportCount matches actual list length.
        if (existingIds.contains(reportId)) {
          final actualCount = existingIds.length;
          if (existingCount != actualCount) {
            tx.update(incidentRef, {
              'reportCount': actualCount,
              'lastReportAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            print('[AI] Incident $incidentId had mismatched count. Corrected to $actualCount');
          } else {
            // Touch timestamps to surface recent change
            tx.update(incidentRef, {
              'lastReportAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            print('[AI] Report $reportId already present on incident $incidentId — no increment performed');
          }
        } else {
          // Add report id and increment count atomically
          tx.update(incidentRef, {
            'reportIds': FieldValue.arrayUnion([reportId]),
            'reportCount': FieldValue.increment(1),
            'lastReportAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('[AI] Report $reportId added to incident $incidentId and reportCount incremented');
        }
      });

      print('[AI] Report successfully attached to incident');
      return Result.success(null);
    } catch (e) {
      print('[AI] Exception in _attachReportToIncident: $e');
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
