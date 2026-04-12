import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/ai/core/ai_config.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';
import 'package:quran_kareem/features/ai/core/ai_provider.dart';

typedef GroqConnectivityChecker = Future<List<ConnectivityResult>> Function();
typedef GroqHttpClientFactory = http.Client Function();

class GroqAiProvider implements AiProvider {
  GroqAiProvider(
    this._config, {
    GroqConnectivityChecker? connectivityChecker,
    GroqHttpClientFactory? httpClientFactory,
  })  : _connectivityChecker =
            connectivityChecker ?? (() => Connectivity().checkConnectivity()),
        _httpClientFactory = httpClientFactory ?? http.Client.new;

  final AiProviderConfig _config;
  final GroqConnectivityChecker _connectivityChecker;
  final GroqHttpClientFactory _httpClientFactory;

  @override
  String get providerName => 'groq';

  @override
  Future<String> generate({
    required String prompt,
    required String systemPrompt,
    int? maxTokens,
    double? temperature,
  }) async {
    final client = _httpClientFactory();
    try {
      final response = await client
          .post(
            Uri.parse('${_config.baseUrl}/chat/completions'),
            headers: <String, String>{
              'Authorization': 'Bearer ${_config.apiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, Object?>{
              'model': _config.model,
              'messages': <Map<String, String>>[
                <String, String>{
                  'role': 'system',
                  'content': systemPrompt,
                },
                <String, String>{
                  'role': 'user',
                  'content': prompt,
                },
              ],
              'max_tokens': maxTokens ?? _config.maxOutputTokens,
              'temperature': temperature ?? _config.temperature,
            }),
          )
          .timeout(Duration(seconds: _config.timeoutSeconds));

      if (response.statusCode == 429) {
        throw AiProviderException(
          message: 'Groq rate limit exceeded.',
          provider: providerName,
          originalError: response.body,
        );
      }
      if (response.statusCode == 503) {
        throw AiProviderException(
          message: 'Groq service is unavailable.',
          provider: providerName,
          originalError: response.body,
        );
      }
      if (response.statusCode >= 400) {
        throw AiProviderException(
          message: 'Groq request failed with status ${response.statusCode}.',
          provider: providerName,
          originalError: response.body,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw AiProviderException(
          message: 'Groq response payload was not a JSON object.',
          provider: providerName,
          originalError: response.body,
        );
      }

      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) {
        throw AiProviderException(
          message: 'Groq response did not contain any choices.',
          provider: providerName,
          originalError: response.body,
        );
      }

      final firstChoice = choices.first;
      if (firstChoice is! Map) {
        throw AiProviderException(
          message: 'Groq response choice was malformed.',
          provider: providerName,
          originalError: response.body,
        );
      }

      final message = firstChoice['message'];
      if (message is! Map) {
        throw AiProviderException(
          message: 'Groq response message was malformed.',
          provider: providerName,
          originalError: response.body,
        );
      }

      final content = message['content']?.toString().trim() ?? '';
      if (content.isEmpty) {
        throw AiProviderException(
          message: 'Groq returned an empty response.',
          provider: providerName,
          originalError: response.body,
        );
      }

      return content;
    } on TimeoutException catch (error, stackTrace) {
      AppLogger.error('GroqAiProvider.generate', error, stackTrace);
      throw AiTimeoutException(
        message: 'Groq request timed out.',
        provider: providerName,
        originalError: error,
      );
    } on FormatException catch (error, stackTrace) {
      AppLogger.error('GroqAiProvider.generate', error, stackTrace);
      throw AiProviderException(
        message: 'Groq response JSON was malformed.',
        provider: providerName,
        originalError: error,
      );
    } on AiServiceException catch (error, stackTrace) {
      AppLogger.error('GroqAiProvider.generate', error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error('GroqAiProvider.generate', error, stackTrace);
      throw AiProviderException(
        message: 'Groq request failed unexpectedly.',
        provider: providerName,
        originalError: error,
      );
    } finally {
      client.close();
    }
  }

  @override
  Future<bool> isAvailable() async {
    if (_config.apiKey.trim().isEmpty) {
      return false;
    }

    final results = await _connectivityChecker();
    return results.any((result) => result != ConnectivityResult.none);
  }
}

class AiFallbackProvider implements AiProvider {
  AiFallbackProvider({
    required AiProvider primary,
    required AiProvider fallback,
  })  : _primary = primary,
        _fallback = fallback;

  final AiProvider _primary;
  final AiProvider _fallback;

  @override
  String get providerName =>
      '${_primary.providerName}->${_fallback.providerName}';

  @override
  Future<String> generate({
    required String prompt,
    required String systemPrompt,
    int? maxTokens,
    double? temperature,
  }) async {
    try {
      return await _primary.generate(
        prompt: prompt,
        systemPrompt: systemPrompt,
        maxTokens: maxTokens,
        temperature: temperature,
      );
    } catch (primaryError, primaryStackTrace) {
      AppLogger.error(
        'AiFallbackProvider.generate.primary',
        primaryError,
        primaryStackTrace,
      );
      return _fallback.generate(
        prompt: prompt,
        systemPrompt: systemPrompt,
        maxTokens: maxTokens,
        temperature: temperature,
      );
    }
  }

  @override
  Future<bool> isAvailable() async {
    return await _primary.isAvailable() || await _fallback.isAvailable();
  }
}
