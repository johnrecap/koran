import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/ai/core/ai_config.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';
import 'package:quran_kareem/features/ai/core/ai_provider.dart';

typedef GeminiConnectivityChecker = Future<List<ConnectivityResult>> Function();
typedef GeminiClientFactory = GeminiContentClient Function({
  required String model,
  required String apiKey,
  required Content systemInstruction,
  required GenerationConfig generationConfig,
});

abstract class GeminiContentClient {
  Future<GenerateContentResponse> generateContent(List<Content> prompt);
}

class GeminiAiProvider implements AiProvider {
  GeminiAiProvider(
    this._config, {
    GeminiConnectivityChecker? connectivityChecker,
    GeminiClientFactory? clientFactory,
  })  : _connectivityChecker =
            connectivityChecker ?? (() => Connectivity().checkConnectivity()),
        _clientFactory = clientFactory ?? _defaultClientFactory;

  final AiProviderConfig _config;
  final GeminiConnectivityChecker _connectivityChecker;
  final GeminiClientFactory _clientFactory;
  final Map<String, GeminiContentClient> _clientsBySystemPrompt =
      <String, GeminiContentClient>{};

  @override
  String get providerName => 'gemini';

  @override
  Future<String> generate({
    required String prompt,
    required String systemPrompt,
    int? maxTokens,
    double? temperature,
  }) async {
    final client = _clientsBySystemPrompt.putIfAbsent(
      systemPrompt,
      () => _clientFactory(
        model: _config.model,
        apiKey: _config.apiKey,
        systemInstruction: Content.system(systemPrompt),
        generationConfig: GenerationConfig(
          maxOutputTokens: maxTokens ?? _config.maxOutputTokens,
          temperature: temperature ?? _config.temperature,
        ),
      ),
    );

    try {
      final response =
          await client.generateContent(<Content>[Content.text(prompt)]).timeout(
        Duration(seconds: _config.timeoutSeconds),
      );
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) {
        throw AiProviderException(
          message: 'Gemini returned an empty response.',
          provider: providerName,
        );
      }

      return text;
    } on TimeoutException catch (error, stackTrace) {
      AppLogger.error('GeminiAiProvider.generate', error, stackTrace);
      throw AiTimeoutException(
        message: 'Gemini request timed out.',
        provider: providerName,
        originalError: error,
      );
    } on InvalidApiKey catch (error, stackTrace) {
      AppLogger.error('GeminiAiProvider.generate', error, stackTrace);
      throw AiProviderException(
        message: 'Gemini API key is invalid.',
        provider: providerName,
        originalError: error,
      );
    } on ServerException catch (error, stackTrace) {
      AppLogger.error('GeminiAiProvider.generate', error, stackTrace);
      throw AiProviderException(
        message: _mapServerMessage(error.message),
        provider: providerName,
        originalError: error,
      );
    } on GenerativeAIException catch (error, stackTrace) {
      AppLogger.error('GeminiAiProvider.generate', error, stackTrace);
      throw AiProviderException(
        message: error.message,
        provider: providerName,
        originalError: error,
      );
    } on AiServiceException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error('GeminiAiProvider.generate', error, stackTrace);
      throw AiProviderException(
        message: 'Gemini request failed unexpectedly.',
        provider: providerName,
        originalError: error,
      );
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

  static GeminiContentClient _defaultClientFactory({
    required String model,
    required String apiKey,
    required Content systemInstruction,
    required GenerationConfig generationConfig,
  }) {
    return _SdkGeminiContentClient(
      GenerativeModel(
        model: model,
        apiKey: apiKey,
        systemInstruction: systemInstruction,
        generationConfig: generationConfig,
      ),
    );
  }

  static String _mapServerMessage(String message) {
    if (message.contains('429')) {
      return 'Gemini rate limit exceeded.';
    }
    if (message.contains('503')) {
      return 'Gemini service is unavailable.';
    }
    return message;
  }
}

class _SdkGeminiContentClient implements GeminiContentClient {
  _SdkGeminiContentClient(this._model);

  final GenerativeModel _model;

  @override
  Future<GenerateContentResponse> generateContent(List<Content> prompt) {
    return _model.generateContent(prompt);
  }
}
