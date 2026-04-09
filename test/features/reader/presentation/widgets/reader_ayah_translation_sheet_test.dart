import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/ayah_translation.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_ayah_translation_sheet.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

void main() {
  testWidgets('shows Arabic text immediately while translation is loading', (
    tester,
  ) async {
    final pendingTranslations = Completer<Map<int, AyahTranslation>>();

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          surahTranslationsProvider.overrideWith((ref, surahNumber) {
            return pendingTranslations.future;
          }),
        ],
        child: const ReaderAyahTranslationSheet(ayah: _ayah),
      ),
    );
    await tester.pump();

    expect(find.text('قُلْ هُوَ اللَّهُ أَحَدٌ'), findsOneWidget);
    expect(find.text('Loading translation...'), findsOneWidget);
  });

  testWidgets('shows the selected ayah translation when available', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          surahTranslationsProvider.overrideWith((ref, surahNumber) async {
            return <int, AyahTranslation>{
              1: const AyahTranslation(
                ayahNumber: 1,
                verseKey: '112:1',
                text: 'Say, He is Allah, the One.',
                resourceId: 85,
              ),
            };
          }),
        ],
        child: const ReaderAyahTranslationSheet(ayah: _ayah),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('قُلْ هُوَ اللَّهُ أَحَدٌ'), findsOneWidget);
    expect(find.text('Say, He is Allah, the One.'), findsOneWidget);
  });

  testWidgets('shows retry state when translation loading fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          surahTranslationsProvider.overrideWith((ref, surahNumber) async {
            throw Exception('translation unavailable');
          }),
        ],
        child: const ReaderAyahTranslationSheet(ayah: _ayah),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load translation right now.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows fallback text when the selected ayah has no translation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          surahTranslationsProvider.overrideWith((ref, surahNumber) async {
            return const <int, AyahTranslation>{};
          }),
        ],
        child: const ReaderAyahTranslationSheet(ayah: _ayah),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Translation is unavailable for this verse.'),
      findsOneWidget,
    );
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

const _ayah = Ayah(
  id: 6237,
  surahNumber: 112,
  ayahNumber: 1,
  text: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
  page: 604,
  juz: 30,
  hizb: 4,
);
