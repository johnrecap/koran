import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';
import 'package:quran_kareem/features/ai/core/ai_provider.dart';
import 'package:quran_kareem/features/ai/core/ai_safety_policy.dart';
import 'package:quran_kareem/features/ai/core/ai_service.dart';
import 'package:quran_kareem/features/ai/core/ai_usage_tracker.dart';
import 'package:quran_kareem/features/ai/domain/ai_response.dart';
import 'package:quran_kareem/features/ai/features/simplify/tafsir_simplify_provider.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('tafsirSimplifyProvider', () {
    test('returns AiResponse from AiService on success', () async {
      final service = await _FakeAiService.create(
        simplifyResponse: AiResponse.fromRaw(
          'ملخص مبسط للتفسير',
          'fake-ai',
          120,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          aiServiceProvider.overrideWith((ref) async => service),
        ],
      );
      addTearDown(container.dispose);

      final response = await container.read(
        tafsirSimplifyProvider(
          const TafsirSimplifyRequest(
            surah: 2,
            ayah: 255,
            tafsirText: 'تفسير طويل يحتاج إلى تبسيط.',
          ),
        ).future,
      );

      expect(response.text, 'ملخص مبسط للتفسير');
      expect(service.simplifyCalls, 1);
    });

    test('propagates AiQuotaExceededException from AiService', () async {
      final service = await _FakeAiService.create(
        simplifyResponse: AiResponse.fromRaw(
          'unused',
          'fake-ai',
          1,
        ),
        simplifyError: AiQuotaExceededException(
          message: 'Quota exhausted',
          provider: 'fake-ai',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          aiServiceProvider.overrideWith((ref) async => service),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(
          tafsirSimplifyProvider(
            const TafsirSimplifyRequest(
              surah: 1,
              ayah: 1,
              tafsirText: 'نص',
            ),
          ).future,
        ),
        throwsA(isA<AiQuotaExceededException>()),
      );
    });
  });
}

class _FakeAiService extends AiService {
  _FakeAiService._({
    required AiUsageTracker tracker,
    required this.simplifyResponse,
    this.simplifyError,
  }) : super(
          provider: _NoopAiProvider(),
          usageTracker: tracker,
          safetyPolicy: const AiSafetyPolicy(),
        );

  static Future<_FakeAiService> create({
    required AiResponse simplifyResponse,
    AiQuotaExceededException? simplifyError,
  }) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final tracker = AiUsageTracker(await SharedPreferences.getInstance());
    return _FakeAiService._(
      tracker: tracker,
      simplifyResponse: simplifyResponse,
      simplifyError: simplifyError,
    );
  }

  final AiResponse simplifyResponse;
  final AiQuotaExceededException? simplifyError;
  int simplifyCalls = 0;

  @override
  Future<AiResponse> simplifyTafsir(
      int surah, int ayah, String tafsirText) async {
    simplifyCalls += 1;
    if (simplifyError != null) {
      throw simplifyError!;
    }

    return simplifyResponse;
  }
}

class _NoopAiProvider implements AiProvider {
  @override
  Future<String> generate({
    required String prompt,
    required String systemPrompt,
    int? maxTokens,
    double? temperature,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  String get providerName => 'noop';
}
