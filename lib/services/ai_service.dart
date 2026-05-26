import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/ai_analysis_model.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/services/ai/duplicate_check_result.dart';
import 'package:resolv/services/ai/prompt_builder.dart';

/// Service for AI-powered analysis of civic reports.
/// Handles classification and duplicate detection using Firebase AI (Gemini).
class AiService {
  late final GenerativeModel _model;

  AiService() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash-lite',
    );
  }

  /// Classifies a civic report using AI.
  /// Returns analysis with predicted category, priority, tags, summary, and confidence.
  Future<Result<AiAnalysisModel>> classifyReport({
    required String title,
    required String description,
  }) async {
    try {
      final prompt = PromptBuilder.buildClassificationPrompt(
        reportTitle: title,
        reportDescription: description,
      );

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      if (responseText.isEmpty) {
        return Result.failure(Failure('Empty response from AI model'));
      }

      final jsonStr = _extractJson(responseText);
      final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;

      final analysis = AiAnalysisModel.fromJson(jsonData);
      return Result.success(analysis);
    } on FormatException catch (e) {
      return Result.failure(
        Failure('Failed to parse AI response: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(Failure('AI classification failed: $e'));
    }
  }

  /// Checks if a report is a duplicate of an existing incident.
  /// Returns result with sameIncident flag, confidence, and reason.
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

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      if (responseText.isEmpty) {
        return Result.failure(Failure('Empty response from duplicate check'));
      }

      final jsonStr = _extractJson(responseText);
      final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;

      final result = DuplicateCheckResult.fromJson(jsonData);
      return Result.success(result);
    } on FormatException catch (e) {
      return Result.failure(
        Failure('Failed to parse duplicate check response: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(Failure('Duplicate check failed: $e'));
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
