

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/ai/core/ai_exceptions.dart';
import 'package:quran_kareem/features/ai/domain/ai_search_result.dart';
import 'package:quran_kareem/features/ai/features/search/ai_topic_search_screen.dart';
import 'package:quran_kareem/features/ai/features/search/semantic_search_provider.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';

void main() {
  testWidgets('renders search input and debounced smart results',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          aiSearchDebounceDurationProvider.overrideWith(
            (ref) => const Duration(milliseconds: 10),
          ),
          semanticSearchProvider.overrideWith(
            (ref, query) async => const [
              AiSearchResult(
                surah: 2,
                ayah: 153,
                verseTextAr: 'يا أيها الذين آمنوا استعينوا بالصبر',
                contextNote: 'آية محورية عن الصبر.',
              ),
            ],
          ),
          aiSearchPageResolverProvider.overrideWithValue((_, __) async => 42),
          allSurahsProvider.overrideWith(
            (ref) async => const [
              Surah(
                number: 2,
                nameArabic: 'البقرة',
                nameEnglish: 'Al-Baqarah',
                nameTransliteration: 'Al-Baqarah',
                ayahCount: 286,
                revelationType: 'Medinan',
                page: 2,
              ),
            ],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'patience');
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpAndSettle();

    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text('آية محورية عن الصبر.'), findsOneWidget);
  });

  testWidgets('shows offline fallback banner and keyword results',
      (tester) async {
    final fallbackSource = _FakeLibraryAyahSearchSource(
      results: const [
        Ayah(
          id: 1,
          surahNumber: 2,
          ayahNumber: 153,
          text: 'يا أيها الذين آمنوا استعينوا بالصبر',
          page: 42,
          juz: 3,
          hizb: 1,
        ),
      ],
    );

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          aiSearchDebounceDurationProvider.overrideWith(
            (ref) => const Duration(milliseconds: 10),
          ),
          semanticSearchProvider.overrideWith(
            (ref, query) => Future<List<AiSearchResult>>.error(
              AiOfflineException(
                message: 'offline',
                provider: 'test',
              ),
            ),
          ),
          libraryAyahSearchSourceProvider.overrideWithValue(fallbackSource),
          allSurahsProvider.overrideWith(
            (ref) async => const [
              Surah(
                number: 2,
                nameArabic: 'البقرة',
                nameEnglish: 'Al-Baqarah',
                nameTransliteration: 'Al-Baqarah',
                ayahCount: 286,
                revelationType: 'Medinan',
                page: 2,
              ),
            ],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'patience');
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-search-offline-fallback-banner')), findsOneWidget);
    expect(find.text('يا أيها الذين آمنوا استعينوا بالصبر'), findsOneWidget);
  });

  testWidgets('shows empty state when smart search returns no results',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          aiSearchDebounceDurationProvider.overrideWith(
            (ref) => const Duration(milliseconds: 10),
          ),
          semanticSearchProvider.overrideWith(
            (ref, query) async => const <AiSearchResult>[],
          ),
          allSurahsProvider.overrideWith((ref) async => const <Surah>[]),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'patience');
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpAndSettle();

    expect(find.text('No relevant verses were found for this topic.'), findsOneWidget);
  });
}

Widget _buildHarness({
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: '/library/ai-search',
        routes: [
          GoRoute(
            path: '/library/ai-search',
            builder: (context, state) => const AiTopicSearchScreen(),
          ),
          GoRoute(
            path: '/reader',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Reader route')),
            ),
          ),
        ],
      ),
    ),
  );
}

class _FakeLibraryAyahSearchSource implements LibraryAyahSearchSource {
  _FakeLibraryAyahSearchSource({
    required this.results,
  });

  final List<Ayah> results;

  @override
  Future<List<Ayah>> searchAyahs({
    required String query,
    int? surahNumber,
  }) async {
    return results;
  }
}
