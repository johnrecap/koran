import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/ai/domain/ai_search_result.dart';
import 'package:quran_kareem/features/ai/features/search/ai_search_result_tile.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

void main() {
  testWidgets('renders surah, ayah, verse text, and context note',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: const AiSearchResultTile(
          result: AiSearchResult(
            surah: 2,
            ayah: 153,
            verseTextAr: 'يا أيها الذين آمنوا استعينوا بالصبر',
            contextNote: 'آية محورية عن الصبر والثبات.',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text('Ayah 153'), findsOneWidget);
    expect(find.text('يا أيها الذين آمنوا استعينوا بالصبر'), findsOneWidget);
    expect(find.text('آية محورية عن الصبر والثبات.'), findsOneWidget);
  });

  testWidgets('tap navigates to reader and updates reader providers',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
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
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: GoRouter(
            initialLocation: '/search',
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const Scaffold(
                  body: AiSearchResultTile(
                    result: AiSearchResult(
                      surah: 2,
                      ayah: 153,
                      verseTextAr: 'يا أيها الذين آمنوا استعينوا بالصبر',
                      contextNote: 'آية محورية عن الصبر والثبات.',
                    ),
                  ),
                ),
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
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ai-search-result-tile-2-153')));
    await tester.pumpAndSettle();

    expect(find.text('Reader route'), findsOneWidget);
    expect(container.read(currentSurahProvider), 2);
    expect(container.read(quranPageIndexProvider), 42);
    expect(
      container.read(readerNavigationTargetProvider).ayahNumber,
      153,
    );
  });
}

Widget _buildHarness({
  required Widget child,
}) {
  return ProviderScope(
    overrides: [
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
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: child),
    ),
  );
}
