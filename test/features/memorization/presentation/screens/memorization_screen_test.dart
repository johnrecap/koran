import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/presentation/screens/memorization_screen.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/khatma_card.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/reader/providers/manual_bookmarks_provider.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
  });

  testWidgets(
    'renders the hub layout and resumes the active khatma from its last session',
    (tester) async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          'readingSessions': jsonEncode(
            [
              ReadingSession(
                id: 'khatma-session',
                surahNumber: 2,
                ayahNumber: 255,
                surahName: 'Al-Baqarah',
                timestamp: DateTime(2026, 3, 26, 9, 0),
                khatmaId: 'khatma-1',
              ).toMap()
                ..['isTrustedKhatmaAnchor'] = true,
              ReadingSession(
                id: 'regular-session',
                surahNumber: 36,
                ayahNumber: 1,
                surahName: 'Ya-Sin',
                timestamp: DateTime(2026, 3, 25, 8, 0),
              ).toMap(),
            ],
          ),
          'khatmas': jsonEncode(
            [
              Khatma(
                id: 'khatma-1',
                title: 'Weekly Khatma',
                targetDays: 7,
                startDate: DateTime(2026, 3, 20),
                completedSurahs: 2,
              ).toMap(),
            ],
          ),
          'manualBookmarks': jsonEncode(
            [
              ManualBookmark(
                surahNumber: 18,
                ayahNumber: 10,
                surahName: 'Al-Kahf',
                timestamp: DateTime(2026, 3, 24, 12, 0),
              ).toMap(),
            ],
          ),
        },
      );

      await tester.pumpWidget(_buildHarness());
      await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TabBar), findsNothing);
      expect(find.text('Current plan'), findsOneWidget);
      expect(find.text('Weekly Khatma'), findsWidgets);
      expect(find.text('Recent sessions'), findsWidgets);
      expect(find.text('Khatmas'), findsOneWidget);
      expect(find.text('Manual saves'), findsWidgets);
      expect(find.text('Upcoming reviews'), findsOneWidget);
      expect(find.text('Resume'), findsWidgets);

      await tester.tap(find.text('Resume').first);
      await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Reader route 2:42'), findsOneWidget);
    },
  );

  testWidgets('shows the create state when there is no active khatma', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(_buildHarness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No active khatma'), findsOneWidget);
    expect(find.text('New Khatma'), findsWidgets);

    await tester.tap(find.text('New Khatma').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('New khatma'), findsWidgets);
  });

  testWidgets('opens the khatma planner when a khatma card is tapped', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'khatmas': jsonEncode(
          [
            Khatma(
              id: 'khatma-1',
              title: 'Weekly Khatma',
              targetDays: 7,
              startDate: DateTime(2026, 3, 20),
              completedSurahs: 2,
            ).toMap(),
          ],
        ),
      },
    );

    await tester.pumpWidget(_buildHarness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final khatmaCard = find.byType(KhatmaCard).first;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(khatmaCard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Planner route khatma-1'), findsOneWidget);
  });

  testWidgets('ignores a polluted khatma session and resumes from the plan start',
      (tester) async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'readingSessions': jsonEncode(
          [
            ReadingSession(
              id: 'legacy-khatma-session',
              surahNumber: 36,
              ayahNumber: 1,
              surahName: 'Ya-Sin',
              timestamp: DateTime(2026, 3, 26, 9, 0),
              khatmaId: 'khatma-1',
            ).toMap(),
          ],
        ),
        'khatmas': jsonEncode(
          [
            {
              'id': 'khatma-1',
              'title': 'Weekly Khatma',
              'targetDays': 7,
              'startDate': DateTime(2026, 3, 20).toIso8601String(),
              'completedSurahs': 0,
              'startPage': 1,
              'furthestPageRead': 0,
              'totalReadMinutes': 0,
              'readingDayKeys': const <String>[],
            },
          ],
        ),
      },
    );

    await tester.pumpWidget(_buildHarness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Resume').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Reader route 1:42'), findsOneWidget);
  });

  testWidgets(
    'shows a start reviews CTA when the active khatma has completed review ranges',
    (tester) async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          'khatmas': jsonEncode(
            [
              {
                'id': 'khatma-1',
                'title': 'Weekly Khatma',
                'targetDays': 7,
                'startDate': DateTime(2026, 3, 20).toIso8601String(),
                'completedSurahs': 2,
                'startPage': 1,
                'furthestPageRead': 90,
                'totalReadMinutes': 15,
                'readingDayKeys': const <String>['2026-03-27'],
              },
            ],
          ),
        },
      );

      await tester.pumpWidget(_buildHarness());
      await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Start reviews'), findsOneWidget);
      expect(
        find.text(
          'Spaced reviews will appear here after the review engine is added.',
        ),
        findsNothing,
      );
    },
  );

  testWidgets('opens the review queue when the start reviews CTA is tapped', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'khatmas': jsonEncode(
          [
            {
              'id': 'khatma-1',
              'title': 'Weekly Khatma',
              'targetDays': 7,
              'startDate': DateTime(2026, 3, 20).toIso8601String(),
              'completedSurahs': 2,
              'startPage': 1,
              'furthestPageRead': 90,
              'totalReadMinutes': 15,
              'readingDayKeys': const <String>['2026-03-27'],
            },
          ],
        ),
      },
    );

    await tester.pumpWidget(_buildHarness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final startReviewsFinder = find.text('Start reviews');
    await tester.ensureVisible(startReviewsFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(startReviewsFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Review queue route'), findsOneWidget);
  });

  testWidgets('opens the quiz hub from the memorization quick actions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(_buildHarness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final quizActionFinder = find.text('Quizzes');
    expect(quizActionFinder, findsOneWidget);

    await tester.tap(quizActionFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Quiz hub route'), findsOneWidget);
  });
}

Widget _buildHarness() {
  return ProviderScope(
    overrides: [
      memorizationAyahPageResolverProvider.overrideWith((ref) {
        return (int surahNumber, int ayahNumber) async => 42;
      }),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: '/memorization',
        routes: [
          GoRoute(
            path: '/memorization',
            builder: (context, state) => const MemorizationScreen(),
          ),
          GoRoute(
            path: '/reader',
            builder: (context, state) => Consumer(
              builder: (context, ref, child) {
                final surahNumber = ref.watch(currentSurahProvider);
                final pageNumber = ref.watch(quranPageIndexProvider);

                return Scaffold(
                  body: Center(
                    child: Text('Reader route $surahNumber:$pageNumber'),
                  ),
                );
              },
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
          GoRoute(
            path: '/memorization/reviews',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Review queue route'),
              ),
            ),
          ),
          GoRoute(
            path: '/memorization/quiz',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Quiz hub route'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
