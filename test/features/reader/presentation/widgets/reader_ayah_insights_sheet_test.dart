import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/domain/ai_response.dart';
import 'package:quran_kareem/features/ai/features/context/verse_context_provider.dart';
import 'package:quran_kareem/features/ai/features/tadabbur/tadabbur_questions_provider.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';
import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_ayah_insights_sheet.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_state.dart';
import 'package:quran_kareem/features/tafsir/providers/insight_section_providers.dart';

void main() {
  testWidgets('renders a compact tafsir preview and the first five word chips',
      (tester) async {
    final bodyText = '${List<String>.filled(40, 'tafsir').join(' ')} tail';
    final expectedPreview = '${bodyText.substring(0, 200)}...';

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          tafsirSectionProvider.overrideWith(
            (ref, target) async => InsightSectionLoaded<TafsirBrowserLoadedContent>(
              TafsirBrowserLoadedContent(
                verseText: 'Arabic verse text',
                bodyText: bodyText,
              ),
            ),
          ),
          wordMeaningSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionLoaded<List<WordMeaningEntry>>(
              <WordMeaningEntry>[
                WordMeaningEntry(word: 'الله', meaning: 'Allah'),
                WordMeaningEntry(word: 'لا', meaning: 'No'),
                WordMeaningEntry(word: 'إله', meaning: 'deity'),
                WordMeaningEntry(word: 'إلا', meaning: 'except'),
                WordMeaningEntry(word: 'هو', meaning: 'He'),
                WordMeaningEntry(word: 'الحي', meaning: 'The Ever-Living'),
              ],
            ),
          ),
        ],
        child: const ReaderAyahInsightsSheet(
          target: _target,
          isDark: false,
        ),
      ),
    );
    await _pumpFrames(tester);

    expect(find.text('Tafsir'), findsOneWidget);
    expect(find.text(expectedPreview), findsOneWidget);
    expect(find.text('Word Meanings'), findsOneWidget);
    expect(find.text('الله · Allah'), findsOneWidget);
    expect(find.text('هو · He'), findsOneWidget);
    expect(find.text('الحي · The Ever-Living'), findsNothing);
  });

  testWidgets('hides the word meanings preview when it is unavailable',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          tafsirSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionLoaded<TafsirBrowserLoadedContent>(
              TafsirBrowserLoadedContent(
                verseText: 'Arabic verse text',
                bodyText: 'Tafsir body',
              ),
            ),
          ),
          wordMeaningSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
        ],
        child: const ReaderAyahInsightsSheet(
          target: _target,
          isDark: false,
        ),
      ),
    );
    await _pumpFrames(tester);

    expect(find.text('Tafsir'), findsOneWidget);
    expect(find.text('Tafsir body'), findsOneWidget);
    expect(find.text('Word Meanings'), findsNothing);
  });

  testWidgets('falls back to the legacy quick view when tafsir preview fails',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          tafsirSectionProvider.overrideWith(
            (ref, target) async => InsightSectionError(StateError('boom')),
          ),
          wordMeaningSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
        ],
        child: const ReaderAyahInsightsSheet(
          target: _target,
          isDark: false,
          legacyQuickViewBuilder: _fakeLegacyQuickViewBuilder,
        ),
      ),
    );
    await _pumpFrames(tester);

    expect(find.text('Legacy quick view'), findsOneWidget);
    expect(find.text('Tafsir'), findsNothing);
  });

  testWidgets('opens the full tafsir browser route from the compact sheet entry',
      (tester) async {
    await tester.pumpWidget(
      _buildRouterHarness(
        overrides: [
          tafsirSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionLoaded<TafsirBrowserLoadedContent>(
              TafsirBrowserLoadedContent(
                verseText: 'Arabic verse text',
                bodyText: 'Compact tafsir body',
              ),
            ),
          ),
          wordMeaningSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
        ],
      ),
    );
    await _pumpFrames(tester);

    expect(find.text('Open full tafsir browser'), findsOneWidget);

    await tester.tap(find.text('Open full tafsir browser'));
    await _pumpFrames(tester);

    expect(find.text('Tafsir route 2:255'), findsOneWidget);
  });

  testWidgets('renders localized Arabic section titles for the compact preview',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        locale: const Locale('ar'),
        overrides: [
          tafsirSectionProvider.overrideWith(
            (ref, target) async =>
                const InsightSectionLoaded<TafsirBrowserLoadedContent>(
              TafsirBrowserLoadedContent(
                verseText: 'نص الآية',
                bodyText: 'ملخص التفسير',
              ),
            ),
          ),
          wordMeaningSectionProvider.overrideWith(
            (ref, target) async =>
                const InsightSectionLoaded<List<WordMeaningEntry>>(
              <WordMeaningEntry>[
                WordMeaningEntry(word: 'الله', meaning: 'الله'),
              ],
            ),
          ),
        ],
        child: const ReaderAyahInsightsSheet(
          target: _target,
          isDark: false,
        ),
      ),
    );
    await _pumpFrames(tester);

    expect(find.text('التفسير'), findsOneWidget);
    expect(find.text('معاني الكلمات'), findsOneWidget);
    expect(find.text('فتح متصفح التفسير'), findsOneWidget);
  });
  testWidgets('shows the AI simplify entry inside the compact tafsir sheet',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          tafsirSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionLoaded<
                TafsirBrowserLoadedContent>(
              TafsirBrowserLoadedContent(
                verseText: 'Arabic verse text',
                bodyText:
                    'This tafsir body is intentionally long enough to show the AI simplify entry in the compact sheet.',
              ),
            ),
          ),
          wordMeaningSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
          aiAvailableProvider.overrideWith((ref) => true),
          aiQuotaExhaustedProvider.overrideWith((ref) async => false),
        ],
        child: const ReaderAyahInsightsSheet(
          target: _target,
          isDark: false,
        ),
      ),
    );
    await _pumpFrames(tester);

    expect(find.text('Simplify tafsir'), findsOneWidget);
  });

  testWidgets('shows verse context and tadabbur sections when AI is available',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          tafsirSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionLoaded<
                TafsirBrowserLoadedContent>(
              TafsirBrowserLoadedContent(
                verseText: 'Arabic verse text',
                bodyText: 'Compact tafsir body that is long enough for AI sections.',
              ),
            ),
          ),
          wordMeaningSectionProvider.overrideWith(
            (ref, target) async => const InsightSectionUnavailable(),
          ),
          aiAvailableProvider.overrideWith((ref) => true),
          aiQuotaExhaustedProvider.overrideWith((ref) async => false),
          verseContextProvider.overrideWith(
            (ref, verse) async => AiResponse.fromRaw(
              'Context explanation',
              'test',
              120,
            ),
          ),
          tadabburQuestionsProvider.overrideWith(
            (ref, verse) async => const ['Reflection question'],
          ),
        ],
        child: const ReaderAyahInsightsSheet(
          target: _target,
          isDark: false,
        ),
      ),
    );
    await _pumpFrames(tester);

    expect(find.text('Context and Connection'), findsOneWidget);
    expect(find.text('Reflection Questions'), findsOneWidget);
  });
}

Widget _buildHarness({
  required List<Override> overrides,
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
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
        initialLocation: '/reader',
        routes: [
          GoRoute(
            path: '/reader',
            builder: (context, state) => const Scaffold(
              body: ReaderAyahInsightsSheet(
                target: _target,
                isDark: false,
              ),
            ),
          ),
          GoRoute(
            path: '/tafsir/:surah/:ayah',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text(
                  'Tafsir route ${state.pathParameters['surah']}:${state.pathParameters['ayah']}',
                ),
              ),
            ),
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

Widget _fakeLegacyQuickViewBuilder(BuildContext context) {
  return const Center(
    child: Text('Legacy quick view'),
  );
}

Future<void> _pumpFrames(WidgetTester tester, {int count = 4}) async {
  for (var index = 0; index < count; index++) {
    await tester.pump();
  }
}
