import 'dart:convert';

import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/ai_analysis_model.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/services/ai/duplicate_check_result.dart';
import 'package:resolv/services/ai/huggingface_client.dart';
import 'package:resolv/services/ai/prompt_builder.dart';

/// Service for AI-powered analysis of civic reports.
/// Handles classification and duplicate detection using Hugging Face Inference.
class AiService {
  final HuggingFaceClient _client;

  AiService({HuggingFaceClient? client}) : _client = client ?? HuggingFaceClient();

  /// Classifies a civic report using AI.
  /// Returns analysis with predicted category, priority, tags, summary, and confidence.
  /// Falls back to default values if classification fails.
  Future<Result<AiAnalysisModel>> classifyReport({
    required String title,
    required String description,
  }) async {
    try {
      print('[AiService] Classifying report: $title');
      final prompt = PromptBuilder.buildClassificationPrompt(
        reportTitle: title,
        reportDescription: description,
      );

      final response = await _client.generateText(prompt);
      if (response.isFailure) {
        print('[AiService] Classification request failed: ${response.error}, using fallback');
        return Result.success(
          AiAnalysisModel(
            predictedCategory: 'other',
            priority: 'low',
            tags: [],
            incidentSummary: title,
            confidence: 0.0,
          ),
        );
      }

      final responseText = response.data ?? '';
      if (responseText.isEmpty) {
        print('[AiService] Empty response from AI model, using fallback');
        return Result.success(
          AiAnalysisModel(
            predictedCategory: 'other',
            priority: 'low',
            tags: [],
            incidentSummary: title,
            confidence: 0.0,
          ),
        );
      }

      final jsonStr = _extractJson(responseText);
      final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;

      final analysis = AiAnalysisModel.fromJson(jsonData);
      print(
        '[AiService] Classification succeeded: category=${analysis.predictedCategory}, priority=${analysis.priority}',
      );
      return Result.success(analysis);
    } on FormatException catch (e) {
      print('[AiService] Failed to parse AI response: ${e.message}, using fallback');
      return Result.success(
        AiAnalysisModel(
          predictedCategory: 'other',
          priority: 'low',
          tags: [],
          incidentSummary: title,
          confidence: 0.0,
        ),
      );
    } catch (e) {
      print('[AiService] AI classification failed: $e, using fallback');
      return Result.success(
        AiAnalysisModel(
          predictedCategory: 'other',
          priority: 'low',
          tags: [],
          incidentSummary: title,
          confidence: 0.0,
        ),
      );
    }
  }

  /// Checks if a report is a duplicate of an existing incident.
  /// Returns result with sameIncident flag, confidence, and reason.
  /// On error, returns false (not a duplicate) to avoid blocking the workflow.
  Future<Result<DuplicateCheckResult>> checkDuplicate({
    required ReportModel report,
    required IncidentModel incident,
  }) async {
    try {
      final prompt = PromptBuilder.buildDuplicateCheckPrompt(
        reportTitle: report.title,
        reportDescription: report.description,
        incidentTitle: incident.title,
        incidentSummary: incident.title,
        category: report.category.name,
      );

      final response = await _client.generateText(prompt);
      if (response.isFailure) {
        print(
          '[AiService] Duplicate check request failed: ${response.error}, returning not-duplicate',
        );
        return Result.success(
          const DuplicateCheckResult(
            sameIncident: false,
            confidence: 0,
            reason: 'Unable to determine',
          ),
        );
      }

      final responseText = response.data ?? '';
      if (responseText.isEmpty) {
        print('[AiService] Empty response from duplicate check, returning not-duplicate');
        return Result.success(
          const DuplicateCheckResult(
            sameIncident: false,
            confidence: 0,
            reason: 'Unable to determine',
          ),
        );
      }

      final jsonStr = _extractJson(responseText);
      final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;

      final result = DuplicateCheckResult.fromJson(jsonData);
      print(
        '[AiService] Duplicate check result: sameIncident=${result.sameIncident}, confidence=${result.confidence}',
      );
      return Result.success(result);
    } on FormatException catch (e) {
      print(
        '[AiService] Failed to parse duplicate check response: ${e.message}, returning not-duplicate',
      );
      return Result.success(
        const DuplicateCheckResult(sameIncident: false, confidence: 0, reason: 'Parse error'),
      );
    } catch (e) {
      print('[AiService] Duplicate check failed: $e, returning not-duplicate');
      return Result.success(
        const DuplicateCheckResult(sameIncident: false, confidence: 0, reason: 'Check failed'),
      );
    }
  }

  /// Extracts JSON from AI response that may be wrapped in markdown code blocks.
  /// Handles formats like ```json {...} ``` or plain JSON.
  String _extractJson(String response) {
    // Remove markdown code blocks if present
    String cleaned = response;
    if (cleaned.contains('```json')) {
      final start = cleaned.indexOf('```json') + 7;
      final end = cleaned.lastIndexOf('```');
      if (end > start) {
        cleaned = cleaned.substring(start, end);
      }
    } else if (cleaned.contains('```')) {
      final start = cleaned.indexOf('```') + 3;
      final end = cleaned.lastIndexOf('```');
      if (end > start) {
        cleaned = cleaned.substring(start, end);
      }
    }
    return cleaned.trim();
  }
}
