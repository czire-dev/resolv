import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:resolv/core/utils/result.dart';

/// Configuration for Hugging Face inference requests.
class HuggingFaceConfig {
  final String model;
  final String baseUrl;
  final Duration timeout;
  final int maxTokens;
  final double temperature;
  final int maxRetries;
  final Duration retryDelay;

  const HuggingFaceConfig({
    this.model = 'mistralai/Mistral-7B-Instruct-v0.2',
    this.baseUrl = 'https://api-inference.huggingface.co/models',
    this.timeout = const Duration(seconds: 20),
    this.maxTokens = 256,
    this.temperature = 0.15,
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 2),
  });

  String get endpoint => '$baseUrl/$model';
}

/// A minimal Hugging Face client for the Inference API.
/// Keeps API calls isolated from the rest of the AI layer.
class HuggingFaceClient {
  final HuggingFaceConfig config;
  final http.Client _httpClient;
  final String? _apiKey;

  HuggingFaceClient({HuggingFaceConfig? config, String? apiKey, http.Client? httpClient})
    : config = config ?? const HuggingFaceConfig(),
      _apiKey = apiKey ?? _loadApiKey(),
      _httpClient = httpClient ?? http.Client();

  static String? _loadApiKey() {
    final loadedKey = dotenv.env['HUGGINGFACE_API_KEY'];
    if (loadedKey != null && loadedKey.isNotEmpty) {
      return loadedKey;
    }

    const dartDefineKey = String.fromEnvironment('HUGGINGFACE_API_KEY', defaultValue: '');
    return dartDefineKey.isNotEmpty ? dartDefineKey : null;
  }

  /// Sends a prompt to the Hugging Face inference API and returns sanitized text.
  Future<Result<String>> generateText(String prompt) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      return Result.failure(
        Failure('Missing Hugging Face API key. Set HUGGINGFACE_API_KEY in environment variables.'),
      );
    }

    print('[HuggingFaceClient] Sending prompt to ${config.endpoint}');
    print('[HuggingFaceClient] Prompt length: ${prompt.length}');

    final requestBody = jsonEncode({
      'inputs': prompt,
      'parameters': {
        'max_new_tokens': config.maxTokens,
        'temperature': config.temperature,
        'top_p': 0.95,
        'repetition_penalty': 1.1,
        'return_full_text': false,
      },
      'options': {'wait_for_model': true},
    });

    for (var attempt = 0; attempt <= config.maxRetries; attempt++) {
      try {
        final response = await _httpClient
            .post(
              Uri.parse(config.endpoint),
              headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
              body: requestBody,
            )
            .timeout(config.timeout);

        print('[HuggingFaceClient] Response status: ${response.statusCode}');
        print('[HuggingFaceClient] Raw response: ${response.body}');

        if (response.statusCode == 200) {
          final output = _extractOutput(response.body);
          final sanitized = _sanitizeText(output);
          return Result.success(sanitized);
        }

        if (response.statusCode == 429 || response.statusCode == 503) {
          if (attempt < config.maxRetries) {
            print(
              '[HuggingFaceClient] Rate limited or model loading, retrying in ${config.retryDelay.inSeconds}s',
            );
            await Future.delayed(config.retryDelay * (attempt + 1));
            continue;
          }
        }

        return Result.failure(
          Failure('Hugging Face inference failed (${response.statusCode}): ${response.body}'),
        );
      } on TimeoutException catch (e) {
        print('[HuggingFaceClient] API request timed out: $e');
        if (attempt < config.maxRetries) {
          await Future.delayed(config.retryDelay * (attempt + 1));
          continue;
        }
        return Result.failure(Failure('Hugging Face request timed out.'));
      } catch (e) {
        print('[HuggingFaceClient] API request error: $e');
        if (attempt < config.maxRetries) {
          await Future.delayed(config.retryDelay * (attempt + 1));
          continue;
        }
        return Result.failure(Failure('Hugging Face request failed: $e'));
      }
    }

    return Result.failure(Failure('Hugging Face inference failed after retries.'));
  }

  static String _sanitizeText(String raw) {
    var cleaned = raw.trim();

    if (cleaned.startsWith('```') && cleaned.contains('```')) {
      final firstFenceEnd = cleaned.indexOf('```', 3);
      if (firstFenceEnd > 0) {
        cleaned = cleaned.substring(firstFenceEnd + 3).trim();
      }
    }

    cleaned = cleaned.replaceAll(RegExp(r'```json|```'), '').trim();
    cleaned = cleaned.replaceAll(RegExp(r'^\u0000+|\u0000+\r?\n*'), '');

    return cleaned;
  }

  static String _extractOutput(String body) {
    try {
      final parsed = jsonDecode(body);
      if (parsed is String) {
        return parsed;
      }
      if (parsed is Map<String, dynamic>) {
        if (parsed.containsKey('generated_text') && parsed['generated_text'] is String) {
          return parsed['generated_text'] as String;
        }
        if (parsed.containsKey('error') && parsed['error'] is String) {
          return parsed['error'] as String;
        }
      }
      if (parsed is List && parsed.isNotEmpty) {
        final first = parsed.first;
        if (first is Map<String, dynamic> && first['generated_text'] is String) {
          return first['generated_text'] as String;
        }
        if (first is String) {
          return first;
        }
      }
    } catch (_) {
      // Not JSON, fall back to raw body.
    }

    return body;
  }
}
