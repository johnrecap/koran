import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';
import 'package:quran_kareem/features/ai/core/ai_provider.dart';
import 'package:quran_kareem/features/ai/core/ai_safety_policy.dart';
import 'package:quran_kareem/features/ai/core/ai_service.dart';
import 'package:quran_kareem/features/ai/core/ai_usage_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AiService', () {
    test('simplifyTafsir returns AiResponse on success', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final tracker = AiUsageTracker(
        prefs,
        currentDateProvider: () => DateTime(2026, 4, 11),
      );
      final service = AiService(
        provider: _FakeAiProvider(
          responseText: 'ملخص واضح ومختصر للتفسير.',
        ),
        usageTracker: tracker,
        safetyPolicy: const AiSafetyPolicy(),
      );

      final response = await service.simplifyTafsir(
        2,
        255,
        'نص تفسير طويل نسبياً يحتاج إلى تبسيط.',
      );

      expect(response.text, contains('ملخص'));
      expect(response.providerName, 'fake-ai');
      expect(tracker.remainingToday, 19);
    });

    test('throws AiQuotaExceededException when quota is exhausted', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final tracker = AiUsageTracker(
        prefs,
        currentDateProvider: () => DateTime(2026, 4, 11),
      )..setQuota(0);
      final service = AiService(
        provider: _FakeAiProvider(responseText: 'unused'),
        usageTracker: tracker,
        safetyPolicy: const AiSafetyPolicy(),
      );

      expect(
        () => service.simplifyTafsir(1, 1, 'text'),
        throwsA(isA<AiQuotaExceededException>()),
      );
    });

    test('throws AiOfflineException when provider is unavailable', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final service = AiService(
        provider: _FakeAiProvider(
          responseText: 'unused',
          available: false,
        ),
        usageTracker: AiUsageTracker(
          prefs,
          currentDateProvider: () => DateTime(2026, 4, 11),
        ),
        safetyPolicy: const AiSafetyPolicy(),
      );

      expect(
        () => service.simplifyTafsir(1, 1, 'text'),
        throwsA(isA<AiOfflineException>()),
      );
    });

    test('propagates AiTimeoutException from the provider', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final service = AiService(
        provider: _FakeAiProvider(
          responseText: 'unused',
          generateError: AiTimeoutException(
            message: 'Timed out',
            provider: 'fake-ai',
          ),
        ),
        usageTracker: AiUsageTracker(
          prefs,
          currentDateProvider: () => DateTime(2026, 4, 11),
        ),
        safetyPolicy: const AiSafetyPolicy(),
      );

      expect(
        () => service.simplifyTafsir(1, 1, 'text'),
        throwsA(isA<AiTimeoutException>()),
      );
    });

    test('throws AiSafetyException when response validation fails', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final service = AiService(
        provider: _FakeAiProvider(
          responseText: 'هذه فتوى مباشرة وحكم شرعي قطعي.',
        ),
        usageTracker: AiUsageTracker(
          prefs,
          currentDateProvider: () => DateTime(2026, 4, 11),
        ),
        safetyPolicy: const AiSafetyPolicy(),
      );

      expect(
        () => service.simplifyTafsir(1, 1, 'text'),
        throwsA(isA<AiSafetyException>()),
      );
    });
  });
}

class _FakeAiProvider implements AiProvider {
  _FakeAiProvider({
    required this.responseText,
    this.available = true,
    this.generateError,
  });

  final String responseText;
  final bool available;
  final Exception? generateError;

  @override
  String get providerName => 'fake-ai';

  @override
  Future<String> generate({
    required String prompt,
    required String systemPrompt,
    int? maxTokens,
    double? temperature,
  }) async {
    if (generateError != null) {
      throw generateError!;
    }

    return responseText;
  }

  @override
  Future<bool> isAvailable() async => available;
}
