import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:quran_kareem/features/ai/core/ai_config.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';
import 'package:quran_kareem/features/ai/providers/gemini_ai_provider.dart';

void main() {
  group('GeminiAiProvider', () {
    test('generate returns expected text on success', () async {
      final provider = GeminiAiProvider(
        const AiProviderConfig(
          apiKey: 'test-key',
          model: 'gemini-2.5-flash',
        ),
        clientFactory: ({
          required String model,
          required String apiKey,
          required Content systemInstruction,
          required GenerationConfig generationConfig,
        }) {
          return _FakeGeminiClient(
            response: GenerateContentResponse(
              <Candidate>[
                Candidate(
                  Content.model(<Part>[TextPart('expected text')]),
                  null,
                  null,
                  null,
                  null,
                ),
              ],
              null,
            ),
          );
        },
      );

      final result = await provider.generate(
        prompt: 'Explain',
        systemPrompt: 'Be concise',
      );

      expect(result, 'expected text');
      expect(provider.providerName, 'gemini');
    });

    test('generate throws AiTimeoutException on timeout', () async {
      final provider = GeminiAiProvider(
        const AiProviderConfig(
          apiKey: 'test-key',
          model: 'gemini-2.5-flash',
          timeoutSeconds: 1,
        ),
        clientFactory: ({
          required String model,
          required String apiKey,
          required Content systemInstruction,
          required GenerationConfig generationConfig,
        }) {
          return _FakeGeminiClient(
            responseFuture: Future<GenerateContentResponse>.delayed(
              const Duration(seconds: 2),
              () => GenerateContentResponse(
                <Candidate>[
                  Candidate(
                    Content.model(<Part>[TextPart('late response')]),
                    null,
                    null,
                    null,
                    null,
                  ),
                ],
                null,
              ),
            ),
          );
        },
      );

      await expectLater(
        provider.generate(
          prompt: 'Explain',
          systemPrompt: 'Be concise',
        ),
        throwsA(isA<AiTimeoutException>()),
      );
    });

    test('generate throws AiProviderException on server rate limit', () async {
      final provider = GeminiAiProvider(
        const AiProviderConfig(
          apiKey: 'test-key',
          model: 'gemini-2.5-flash',
        ),
        clientFactory: ({
          required String model,
          required String apiKey,
          required Content systemInstruction,
          required GenerationConfig generationConfig,
        }) {
          return _FakeGeminiClient(
            error: ServerException('429 rate limit exceeded'),
          );
        },
      );

      await expectLater(
        provider.generate(
          prompt: 'Explain',
          systemPrompt: 'Be concise',
        ),
        throwsA(isA<AiProviderException>()),
      );
    });

    test('isAvailable returns false when api key is empty', () async {
      final provider = GeminiAiProvider(
        const AiProviderConfig(
          apiKey: '',
          model: 'gemini-2.5-flash',
        ),
        connectivityChecker: () async => <ConnectivityResult>[
          ConnectivityResult.wifi,
        ],
      );

      expect(await provider.isAvailable(), isFalse);
    });

    test('generate throws AiProviderException on empty response', () async {
      final provider = GeminiAiProvider(
        const AiProviderConfig(
          apiKey: 'test-key',
          model: 'gemini-2.5-flash',
        ),
        clientFactory: ({
          required String model,
          required String apiKey,
          required Content systemInstruction,
          required GenerationConfig generationConfig,
        }) {
          return _FakeGeminiClient(
            response: GenerateContentResponse(
              <Candidate>[
                Candidate(
                  Content.model(<Part>[TextPart('   ')]),
                  null,
                  null,
                  null,
                  null,
                ),
              ],
              null,
            ),
          );
        },
      );

      await expectLater(
        provider.generate(
          prompt: 'Explain',
          systemPrompt: 'Be concise',
        ),
        throwsA(isA<AiProviderException>()),
      );
    });
  });
}

class _FakeGeminiClient implements GeminiContentClient {
  _FakeGeminiClient({
    this.response,
    this.responseFuture,
    this.error,
  });

  final GenerateContentResponse? response;
  final Future<GenerateContentResponse>? responseFuture;
  final Object? error;

  @override
  Future<GenerateContentResponse> generateContent(
    List<Content> prompt,
  ) async {
    if (error != null) {
      throw error!;
    }
    if (responseFuture != null) {
      return responseFuture!;
    }
    return response!;
  }
}
