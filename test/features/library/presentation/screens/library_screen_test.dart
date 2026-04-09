import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/library/presentation/screens/library_screen.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'renders the three library tabs without a dedicated auto-save tab',
      (tester) async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'manualBookmarks': jsonEncode(
          [
            {
              'surahNumber': 2,
              'ayahNumber': 255,
              'surahName': 'Test Surah',
              'timestamp': DateTime(2026, 3, 24, 9, 0).toIso8601String(),
            },
          ],
        ),
        'khatmas': jsonEncode(
          [
            Khatma(
              id: 'khatma-1',
              title: 'Weekly Khatma',
              targetDays: 7,
              startDate: DateTime(2026, 3, 20),
              completedSurahs: 10,
            ).toMap(),
          ],
        ),
      },
    );

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    expect(find.text('Surahs'), findsOneWidget);
    expect(find.text('Khatmas'), findsOneWidget);
    expect(find.text('Manual saves'), findsOneWidget);
    expect(find.text('Auto save'), findsNothing);
  });

  testWidgets('opens the khatma planner when a library khatma card is tapped',
      (tester) async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'khatmas': jsonEncode(
          [
            Khatma(
              id: 'khatma-1',
              title: 'Weekly Khatma',
              targetDays: 7,
              startDate: DateTime(2026, 3, 20),
              completedSurahs: 10,
            ).toMap(),
          ],
        ),
      },
    );

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Khatmas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekly Khatma'));
    await tester.pumpAndSettle();

    expect(find.text('Planner route khatma-1'), findsOneWidget);
  });

  testWidgets('shows a visible error state when surahs fail to load',
      (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          allSurahsProvider.overrideWith((ref) async {
            throw Exception('db unavailable');
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load surahs right now.'), findsOneWidget);
  });

  testWidgets('opens the stories hub when the quran stories entry is tapped',
      (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('library-stories-entry')));
    await tester.pumpAndSettle();

    expect(find.text('Stories hub route'), findsOneWidget);
  });
}

Widget _buildHarness({
  List<Override> overrides = const <Override>[],
}) {
  return ProviderScope(
    overrides: [
      allSurahsProvider.overrideWith(
        (ref) async => const [
          Surah(
            number: 1,
            nameArabic: 'Opening',
            nameEnglish: 'Opening',
            nameTransliteration: 'Opening',
            ayahCount: 7,
            revelationType: 'Meccan',
            page: 1,
          ),
          Surah(
            number: 2,
            nameArabic: 'Test Surah',
            nameEnglish: 'Test Surah',
            nameTransliteration: 'Test Surah',
            ayahCount: 286,
            revelationType: 'Medinan',
            page: 2,
          ),
        ],
      ),
      ...overrides,
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: '/library',
        routes: [
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/reader',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Reader route'),
              ),
            ),
          ),
          GoRoute(
            path: '/library/stories',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Stories hub route'),
              ),
            ),
          ),
          GoRoute(
            path: '/memorization/khatma/:khatmaId',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text(
                  'Planner route ${state.pathParameters['khatmaId']}',
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
