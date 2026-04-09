import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/ayah_translation.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/translation_mode_view.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:quran_kareem/features/settings/providers/settings_providers.dart';

void main() {
  const target = ReaderNavigationTarget(
    surahNumber: 1,
    ayahNumber: 1,
    pageNumber: 1,
  );

  testWidgets('shows loading state while ayahs and translations are pending', (
    tester,
  ) async {
    final pendingAyahs = Completer<List<Ayah>>();
    final pendingTranslations = Completer<Map<int, AyahTranslation>>();

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          surahAyahsProvider.overrideWith((ref, surahNumber) {
            return pendingAyahs.future;
          }),
          surahTranslationsProvider.overrideWith((ref, surahNumber) {
            return pendingTranslations.future;
          }),
        ],
        child: const TranslationModeView(navigationTarget: target),
      ),
    );
    await tester.pump();

    expect(find.text('Loading translation...'), findsOneWidget);
  });

  testWidgets('shows error state with retry when translations fail', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          surahAyahsProvider.overrideWith((ref, surahNumber) async {
            return _fakeAyahs;
          }),
          surahTranslationsProvider.overrideWith((ref, surahNumber) async {
            throw Exception('network down');
          }),
        ],
        child: const TranslationModeView(navigationTarget: target),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load translation right now.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows error state when ayah loading fails', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          surahAyahsProvider.overrideWith((ref, surahNumber) async {
            throw Exception('db unavailable');
          }),
          surahTranslationsProvider.overrideWith((ref, surahNumber) async {
            return const <int, AyahTranslation>{};
          }),
        ],
        child: const TranslationModeView(navigationTarget: target),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load translation right now.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('renders ayahs with translation fallback when needed', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          surahAyahsProvider.overrideWith((ref, surahNumber) async {
            return _fakeAyahs;
          }),
          surahTranslationsProvider.overrideWith((ref, surahNumber) async {
            return <int, AyahTranslation>{
              1: const AyahTranslation(
                ayahNumber: 1,
                verseKey: '1:1',
                text: 'In the name of Allah',
                resourceId: 85,
              ),
            };
          }),
        ],
        child: const TranslationModeView(navigationTarget: target),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('بِسْمِ اللَّهِ'), findsOneWidget);
    expect(find.text('In the name of Allah'), findsOneWidget);
    expect(
      find.text('Translation is unavailable for this verse.'),
      findsOneWidget,
    );
  });

  testWidgets('uses the app settings arabic font size for translated ayah tiles',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          appSettingsInitialStateProvider.overrideWithValue(
            const AppSettingsState(
              themeMode: ThemeMode.light,
              locale: Locale('en'),
              arabicFontSize: 34,
              defaultReaderMode: ReaderMode.scroll,
              tajweedEnabled: false,
            ),
          ),
          surahAyahsProvider.overrideWith((ref, surahNumber) async {
            return _fakeAyahs;
          }),
          surahTranslationsProvider.overrideWith((ref, surahNumber) async {
            return <int, AyahTranslation>{
              1: const AyahTranslation(
                ayahNumber: 1,
                verseKey: '1:1',
                text: 'In the name of Allah',
                resourceId: 85,
              ),
            };
          }),
        ],
        child: const TranslationModeView(navigationTarget: target),
      ),
    );
    await tester.pumpAndSettle();

    final arabicText = tester.widget<Text>(find.text('بِسْمِ اللَّهِ'));
    expect(arabicText.style?.fontSize, 34);
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

const _fakeAyahs = <Ayah>[
  Ayah(
    id: 1,
    surahNumber: 1,
    ayahNumber: 1,
    text: 'بِسْمِ اللَّهِ',
    page: 1,
    juz: 1,
    hizb: 1,
  ),
  Ayah(
    id: 2,
    surahNumber: 1,
    ayahNumber: 2,
    text: 'الْحَمْدُ لِلَّهِ',
    page: 1,
    juz: 1,
    hizb: 1,
  ),
];
