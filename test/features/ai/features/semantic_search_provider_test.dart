import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/ai/core/ai_provider.dart';
import 'package:quran_kareem/features/ai/core/ai_safety_policy.dart';
import 'package:quran_kareem/features/ai/core/ai_service.dart';
import 'package:quran_kareem/features/ai/core/ai_usage_tracker.dart';
import 'package:quran_kareem/features/ai/domain/ai_search_result.dart';
import 'package:quran_kareem/features/ai/features/search/semantic_search_provider.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('semanticSearchProvider', () {
    test('returns search results from AiService on success', () async {
      final service = await _FakeSearchAiService.create(
        searchResults: const <AiSearchResult>[
          AiSearchResult(
            surah: 2,
            ayah: 153,
            verseTextAr:
                'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ',
            contextNote: 'آية محورية عن الصبر والاستعانة بالله.',
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          aiServiceProvider.overrideWith((ref) async => service),
        ],
      );
      addTearDown(container.dispose);

      final results = await container.read(
        semanticSearchProvider('الصبر').future,
      );

      expect(results, hasLength(1));
      expect(results.single.surah, 2);
      expect(service.searchCalls, 1);
    });

    test('returns empty list for an empty query without calling AiService',
        () async {
      final service = await _FakeSearchAiService.create(
        searchResults: const <AiSearchResult>[
          AiSearchResult(
            surah: 1,
            ayah: 1,
            verseTextAr: 'placeholder',
            contextNote: 'placeholder',
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          aiServiceProvider.overrideWith((ref) async => service),
        ],
      );
      addTearDown(container.dispose);

      final results = await container.read(
        semanticSearchProvider('   ').future,
      );

      expect(results, isEmpty);
      expect(service.searchCalls, 0);
    });
  });
}

class _FakeSearchAiService extends AiService {
  _FakeSearchAiService._({
    required AiUsageTracker tracker,
    required this.searchResults,
  }) : super(
          provider: _NoopAiProvider(),
          usageTracker: tracker,
          safetyPolicy: const AiSafetyPolicy(),
        );

  static Future<_FakeSearchAiService> create({
    required List<AiSearchResult> searchResults,
  }) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final tracker = AiUsageTracker(await SharedPreferences.getInstance());
    return _FakeSearchAiService._(
      tracker: tracker,
      searchResults: searchResults,
    );
  }

  final List<AiSearchResult> searchResults;
  int searchCalls = 0;

  @override
  Future<List<AiSearchResult>> searchByTopic(
    String query, {
    String language = 'ar',
  }) async {
    searchCalls += 1;
    return searchResults;
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
