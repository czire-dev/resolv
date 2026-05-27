import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/ai_analysis_model.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/services/ai/duplicate_check_result.dart';
import 'package:resolv/services/ai/prompt_builder.dart';

/// Service for AI-powered analysis of civic reports.
/// Handles classification and duplicate detection using Google Generative AI (Gemini).
class AiService {
  final String? _apiKey;
  late final GenerativeModel _model;

  AiService({String? apiKey}) : _apiKey = apiKey ?? _loadApiKey() {
    _initializeModel();
  }

  void _initializeModel() {
    final key = _apiKey;
    if (key == null || key.isEmpty) {
      print('[Gemini] ⚠️ No API key provided; AI features will be unavailable');
      throw Exception('Gemini API key not configured');
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: key,
      safetySettings: _defaultSafetySettings(),
      generationConfig: GenerationConfig(
        temperature: 0.2,
        maxOutputTokens: 1024,
      ),
    );
    print('[Gemini] ✓ Model initialized: gemini-1.5-flash');
  }

  List<SafetySetting> _defaultSafetySettings() {
    return [
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
    ];
  }

  static String? _loadApiKey() {
    try {
      final loadedKey = dotenv.env['GEMINI_API_KEY'];
      if (loadedKey != null && loadedKey.isNotEmpty) {
        print(
          '[Gemini] ✓ API key loaded from dotenv (${loadedKey.length} chars)',
        );
        return loadedKey;
      }
    } catch (e) {
      print('[Gemini] dotenv access failed, trying dart-define');
    }

    const dartDefineKey = String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: '',
    );
    if (dartDefineKey.isNotEmpty) {
      print(
        '[Gemini] ✓ API key loaded from dart-define (${dartDefineKey.length} chars)',
      );
      return dartDefineKey;
    }

    print('[Gemini] ❌ No GEMINI_API_KEY found');
    return null;
  }

  /// Classifies a civic report using AI.
  /// Returns analysis with predicted category, priority, tags, summary, and confidence.
  /// Falls back to default values if classification fails.
  Future<Result<AiAnalysisModel>> classifyReport({
    required String title,
    required String description,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return Result.success(_fallbackAnalysis(title));
    }

    try {
      print('[AiService] Classifying report: $title');
      final prompt = PromptBuilder.buildClassificationPrompt(
        reportTitle: title,
        reportDescription: description,
      );

      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        print('[AiService] Empty response from Gemini, using fallback');
        return Result.success(_fallbackAnalysis(title));
      }

      final responseText = response.text!;
      print('[AiService] Raw response: $responseText');

      final jsonStr = _extractJson(responseText);
      final jsonData = _parseJson(jsonStr, context: 'classification');

      final analysis = AiAnalysisModel.fromJson(jsonData);
      print(
        '[AiService] Classification succeeded: category=${analysis.predictedCategory}, priority=${analysis.priority}',
      );
      return Result.success(analysis);
    } on FormatException catch (e) {
      print(
        '[AiService] Failed to parse Gemini response: ${e.message}, using fallback',
      );
      return Result.success(_fallbackAnalysis(title));
    } catch (e) {
      print('[AiService] Gemini classification failed: $e, using fallback');
      return Result.success(_fallbackAnalysis(title));
    }
  }

  /// Checks if a report is a duplicate of an existing incident.
  /// Returns result with sameIncident flag, confidence, and reason.
  /// On error, returns false (not a duplicate) to avoid blocking the workflow.
  Future<Result<DuplicateCheckResult>> checkDuplicate({
    required ReportModel report,
    required IncidentModel incident,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return Result.success(_fallbackDuplicate());
    }

    try {
      final prompt = PromptBuilder.buildDuplicateCheckPrompt(
        reportTitle: report.title,
        reportDescription: report.description,
        incidentTitle: incident.title,
        incidentSummary: incident.title,
        category: report.category.name,
      );

      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        print(
          '[AiService] Empty response from duplicate check, returning not-duplicate',
        );
        return Result.success(_fallbackDuplicate());
      }

      final responseText = response.text!;
      print('[AiService] Duplicate check raw response: $responseText');

      final jsonStr = _extractJson(responseText);
      final jsonData = _parseJson(jsonStr, context: 'duplicate check');

      final result = DuplicateCheckResult.fromJson(jsonData);
      print(
        '[AiService] Duplicate check result: sameIncident=${result.sameIncident}, confidence=${result.confidence}',
      );
      return Result.success(result);
    } on FormatException catch (e) {
      print(
        '[AiService] Failed to parse duplicate check response: ${e.message}, returning not-duplicate',
      );
      return Result.success(_fallbackDuplicate());
    } catch (e) {
      print('[AiService] Duplicate check failed: $e, returning not-duplicate');
      return Result.success(_fallbackDuplicate());
    }
  }

  /// Extracts JSON from AI response that may be wrapped in markdown code blocks.
  /// Handles formats like ```json {...} ``` or plain JSON.
  String _extractJson(String response) {
    String cleaned = response;

    // Remove markdown code blocks if present
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

    cleaned = cleaned.trim();

    // Try to find valid JSON object if wrapped in text
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
    if (jsonMatch != null) {
      return jsonMatch.group(0) ?? cleaned;
    }

    return cleaned;
  }

  Map<String, dynamic> _parseJson(String jsonStr, {required String context}) {
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } on FormatException catch (e) {
      final repaired = _repairJson(jsonStr);
      if (repaired == jsonStr) {
        rethrow;
      }

      print('[AiService] Repaired JSON for $context: $repaired');
      return jsonDecode(repaired) as Map<String, dynamic>;
    }
  }

  String _repairJson(String rawJson) {
    var repaired = rawJson.trim();

    repaired = repaired.replaceAll(RegExp(r',\s*([\}\]])'), r'$1');

    final quoteCount = '"'.allMatches(repaired).length;
    if (quoteCount.isOdd) {
      if (!repaired.endsWith('"')) {
        repaired = '$repaired"';
      }
    }

    final openBraces = '{'.allMatches(repaired).length;
    final closeBraces = '}'.allMatches(repaired).length;
    for (var i = 0; i < openBraces - closeBraces; i++) {
      repaired = '$repaired}';
    }

    final openBrackets = '\['.allMatches(repaired).length;
    final closeBrackets = '\]'.allMatches(repaired).length;
    for (var i = 0; i < openBrackets - closeBrackets; i++) {
      repaired = '$repaired]';
    }

    return repaired;
  }

  AiAnalysisModel _fallbackAnalysis(String title) {
    return AiAnalysisModel(
      predictedCategory: 'other',
      priority: 'low',
      tags: [],
      incidentSummary: title,
      confidence: 0.0,
    );
  }

  DuplicateCheckResult _fallbackDuplicate() {
    return const DuplicateCheckResult(
      sameIncident: false,
      confidence: 0,
      reason: 'Unable to determine',
    );
  }
}
