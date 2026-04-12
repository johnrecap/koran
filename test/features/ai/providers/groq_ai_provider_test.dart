import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_kareem/features/ai/core/ai_config.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';
import 'package:quran_kareem/features/ai/core/ai_provider.dart';
import 'package:quran_kareem/features/ai/providers/groq_ai_provider.dart';

void main() {
  group('GroqAiProvider', () {
    test('generate extracts content text from a valid response', () async {
      final requests = <http.Request>[];
      final provider = GroqAiProvider(
        AiProviderConfig.groq('groq-key'),
        connectivityChecker: () async => <ConnectivityResult>[
          ConnectivityResult.wifi,
        ],
        httpClientFactory: () => MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode(<String, Object?>{
              'choices': <Object?>[
                <String, Object?>{
                  'message': <String, Object?>{
                    'content': 'groq response',
                  },
                },
              ],
            }),
            200,
            headers: <String, String>{
              'content-type': 'application/json',
            },
          );
        }),
      );

      final result = await provider.generate(
        prompt: 'Explain this verse',
        systemPrompt: 'Be concise',
      );

      expect(result, 'groq response');
      expect(requests.single.method, 'POST');
      expect(
        requests.single.url.toString(),
        'https://api.groq.com/openai/v1/chat/completions',
      );
      expect(requests.single.headers['Authorization'], 'Bearer groq-key');

      final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
      expect(body['model'], 'llama-3.3-70b-versatile');
      expect(body['max_tokens'], 1024);
      expect(body['temperature'], 0.3);
    });

    test('generate throws AiProviderException on 429 response', () async {
      final provider = GroqAiProvider(
        AiProviderConfig.groq('groq-key'),
        connectivityChecker: () async => <ConnectivityResult>[
          ConnectivityResult.wifi,
        ],
        httpClientFactory: () => MockClient(
          (_) async => http.Response('rate limited', 429),
        ),
      );

      await expectLater(
        provider.generate(
          prompt: 'Explain',
          systemPrompt: 'Be concise',
        ),
        throwsA(isA<AiProviderException>()),
      );
    });

    test('generate throws AiTimeoutException on timeout', () async {
      final provider = GroqAiProvider(
        const AiProviderConfig(
          apiKey: 'groq-key',
          model: 'llama-3.3-70b-versatile',
          baseUrl: 'https://api.groq.com/openai/v1',
          timeoutSeconds: 1,
        ),
        connectivityChecker: () async => <ConnectivityResult>[
          ConnectivityResult.wifi,
        ],
        httpClientFactory: () => MockClient((_) async {
          await Future<void>.delayed(const Duration(seconds: 2));
          return http.Response('{}', 200);
        }),
      );

      await expectLater(
        provider.generate(
          prompt: 'Explain',
          systemPrompt: 'Be concise',
        ),
        throwsA(isA<AiTimeoutException>()),
      );
    });

    test('generate throws AiProviderException on malformed json', () async {
      final provider = GroqAiProvider(
        AiProviderConfig.groq('groq-key'),
        connectivityChecker: () async => <ConnectivityResult>[
          ConnectivityResult.wifi,
        ],
        httpClientFactory: () => MockClient(
          (_) async => http.Response('{"choices": "bad"}', 200),
        ),
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

  group('AiFallbackProvider', () {
    test('returns primary result when primary succeeds', () async {
      final provider = AiFallbackProvider(
        primary: _FakeAiProvider(
          name: 'primary',
          responseText: 'primary result',
        ),
        fallback: _FakeAiProvider(
          name: 'fallback',
          responseText: 'fallback result',
        ),
      );

      final result = await provider.generate(
        prompt: 'Explain',
        systemPrompt: 'Be concise',
      );

      expect(result, 'primary result');
    });

    test('uses fallback when primary throws', () async {
      final provider = AiFallbackProvider(
        primary: _FakeAiProvider(
          name: 'primary',
          responseText: 'unused',
          error: AiProviderException(message: 'primary failed'),
        ),
        fallback: _FakeAiProvider(
          name: 'fallback',
          responseText: 'fallback result',
        ),
      );

      final result = await provider.generate(
        prompt: 'Explain',
        systemPrompt: 'Be concise',
      );

      expect(result, 'fallback result');
      expect(provider.providerName, 'primary->fallback');
    });

    test('rethrows when both providers fail', () async {
      final provider = AiFallbackProvider(
        primary: _FakeAiProvider(
          name: 'primary',
          responseText: 'unused',
          error: AiProviderException(message: 'primary failed'),
        ),
        fallback: _FakeAiProvider(
          name: 'fallback',
          responseText: 'unused',
          error: AiTimeoutException(message: 'fallback failed'),
        ),
      );

      await expectLater(
        provider.generate(
          prompt: 'Explain',
          systemPrompt: 'Be concise',
        ),
        throwsA(isA<AiTimeoutException>()),
      );
    });
  });
}

class _FakeAiProvider implements AiProvider {
  _FakeAiProvider({
    required this.name,
    required this.responseText,
    this.error,
  });

  final String name;
  final String responseText;
  final Exception? error;

  @override
  String get providerName => name;

  @override
  Future<String> generate({
    required String prompt,
    required String systemPrompt,
    int? maxTokens,
    double? temperature,
  }) async {
    if (error != null) {
      throw error!;
    }

    return responseText;
  }

  @override
  Future<bool> isAvailable() async => true;
}
