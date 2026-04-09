import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_state.dart';
import 'package:quran_kareem/features/tafsir/presentation/screens/tafsir_browser_screen.dart';
import 'package:quran_kareem/features/tafsir/providers/insight_section_providers.dart';
import 'package:quran_kareem/features/tafsir/providers/tafsir_browser_providers.dart';

void main() {
  testWidgets('uses the provider-driven tafsir section to render content',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          tafsirBrowserTargetProvider.overrideWith((ref, args) async => _target),
          tafsirBrowserSourceOptionsProvider.overrideWith(
            (ref) async => const <TafsirBrowserSourceOption>[],
          ),
          tafsirSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionLoaded<
                TafsirBrowserLoadedContent>(
              TafsirBrowserLoadedContent(
                verseText: 'Arabic verse text',
                bodyText: 'Rendered from tafsir section provider.',
              ),
            ),
          ),
          tafsirBrowserContentProvider.overrideWith(
            (ref, target) async =>
                TafsirBrowserErrorContent(error: StateError('unused')),
          ),
          wordMeaningSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
          asbaabSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
          relatedAyahsSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
        ],
        child: const TafsirBrowserScreen(
          surahNumber: 2,
          ayahNumber: 255,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Arabic verse text'), findsOneWidget);
    expect(find.text('Rendered from tafsir section provider.'), findsOneWidget);
    expect(find.text('Unable to load tafsir right now.'), findsNothing);
  });

  testWidgets('renders available sections and hides unavailable sections',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          tafsirBrowserTargetProvider.overrideWith((ref, args) async => _target),
          tafsirBrowserSourceOptionsProvider.overrideWith(
            (ref) async => const <TafsirBrowserSourceOption>[],
          ),
          tafsirSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionLoaded<
                TafsirBrowserLoadedContent>(
              TafsirBrowserLoadedContent(
                verseText: 'Arabic verse text',
                bodyText: 'Tafsir body',
              ),
            ),
          ),
          wordMeaningSectionProvider.overrideWith(
            (ref, target) async =>
                const InsightSectionLoaded<List<WordMeaningEntry>>(
              <WordMeaningEntry>[
                WordMeaningEntry(
                  word: 'اللَّهُ',
                  meaning: 'Allah',
                  root: 'أله',
                ),
              ],
            ),
          ),
          asbaabSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
          relatedAyahsSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
        ],
        child: const TafsirBrowserScreen(
          surahNumber: 2,
          ayahNumber: 255,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tafsir'), findsOneWidget);
    expect(find.text('Word Meanings'), findsOneWidget);
    expect(find.text('Arabic verse text'), findsOneWidget);
    expect(find.text('Allah'), findsOneWidget);
    expect(find.text('Reasons for Revelation'), findsNothing);
    expect(find.text('Related Verses'), findsNothing);
  });

  testWidgets('shows a section-local loading indicator while other sections render',
      (tester) async {
    final wordMeaningsCompleter = Completer<InsightSectionData>();

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          tafsirBrowserTargetProvider.overrideWith((ref, args) async => _target),
          tafsirBrowserSourceOptionsProvider.overrideWith(
            (ref) async => const <TafsirBrowserSourceOption>[],
          ),
          tafsirSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionLoaded<
                TafsirBrowserLoadedContent>(
              TafsirBrowserLoadedContent(
                verseText: 'Arabic verse text',
                bodyText: 'Tafsir body',
              ),
            ),
          ),
          wordMeaningSectionProvider.overrideWith(
            (ref, target) => wordMeaningsCompleter.future,
          ),
          asbaabSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
          relatedAyahsSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
        ],
        child: const TafsirBrowserScreen(
          surahNumber: 2,
          ayahNumber: 255,
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('Tafsir body'));

    expect(find.text('Tafsir body'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('navigates to a related ayah from the related section',
      (tester) async {
    await tester.pumpWidget(
      _buildRouterHarness(
        overrides: [
          tafsirBrowserTargetProvider.overrideWith((ref, args) async => _target),
          tafsirBrowserSourceOptionsProvider.overrideWith(
            (ref) async => const <TafsirBrowserSourceOption>[],
          ),
          tafsirSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionLoaded<
                TafsirBrowserLoadedContent>(
              TafsirBrowserLoadedContent(
                verseText: 'Arabic verse text',
                bodyText: 'Tafsir body',
              ),
            ),
          ),
          wordMeaningSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
          asbaabSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
          relatedAyahsSectionProvider.overrideWith(
            (ref, target) async =>
                const InsightSectionLoaded<List<RelatedAyahEntry>>(
              <RelatedAyahEntry>[
                RelatedAyahEntry(
                  surahNumber: 3,
                  ayahNumber: 18,
                  tag: 'thematic',
                  snippet: 'Allah bears witness.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Related Verses'), findsOneWidget);

    await tester.tap(find.text('Surah 3 : Ayah 18'));
    await tester.pumpAndSettle();

    expect(find.text('Route 3:18'), findsOneWidget);
  });
}

Widget _buildHarness({
  required Widget child,
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: child),
    ),
  );
}

Widget _buildRouterHarness({
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: '/tafsir/2/255',
        routes: [
          GoRoute(
            path: '/tafsir/:surah/:ayah',
            builder: (context, state) {
              final surah = state.pathParameters['surah']!;
              final ayah = state.pathParameters['ayah']!;
              if (surah == '2' && ayah == '255') {
                return const TafsirBrowserScreen(
                  surahNumber: 2,
                  ayahNumber: 255,
                );
              }

              return Scaffold(
                body: Center(
                  child: Text('Route $surah:$ayah'),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

const _target = ReaderAyahInsightsTarget(
  surahNumber: 2,
  ayahNumber: 255,
  ayahUQNumber: 281,
  pageNumber: 42,
);

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 10,
}) async {
  for (var attempt = 0; attempt < maxPumps; attempt++) {
    await tester.pump();
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
}
