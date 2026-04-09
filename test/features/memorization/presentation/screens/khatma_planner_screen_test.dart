import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/memorization/presentation/screens/khatma_planner_screen.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
  });

  testWidgets('renders the khatma planner details with assignment and metrics',
      (tester) async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'readingSessions': jsonEncode(
          [
            {
              'id': 'khatma-khatma-1',
              'surahNumber': 2,
              'ayahNumber': 255,
              'surahName': 'Al-Baqarah',
              'timestamp': DateTime(2026, 3, 26, 9, 0).toIso8601String(),
              'durationMinutes': 0,
              'khatmaId': 'khatma-1',
              'isTrustedKhatmaAnchor': true,
            },
          ],
        ),
        'khatmas': jsonEncode(
          [
            {
              'id': 'khatma-1',
              'title': 'Monthly Khatma',
              'targetDays': 30,
              'startDate': DateTime(2026, 3, 1).toIso8601String(),
              'completedSurahs': 1,
              'startPage': 1,
              'furthestPageRead': 40,
              'totalReadMinutes': 125,
              'readingDayKeys': ['2026-03-24', '2026-03-25', '2026-03-26'],
            },
          ],
        ),
      },
    );

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    expect(find.text('Monthly Khatma'), findsWidgets);
    expect(find.text('Daily assignment'), findsOneWidget);
    expect(find.text('41 - 61'), findsOneWidget);
    expect(find.text('Reading streak'), findsOneWidget);
    expect(find.text('Tracked time'), findsOneWidget);
  });

  testWidgets(
      'planner resume ignores a polluted khatma session and opens the derived target',
      (tester) async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'readingSessions': jsonEncode(
          [
            {
              'id': 'legacy-khatma-session',
              'surahNumber': 36,
              'ayahNumber': 1,
              'surahName': 'Ya-Sin',
              'timestamp': DateTime(2026, 3, 26, 9, 0).toIso8601String(),
              'durationMinutes': 0,
              'khatmaId': 'khatma-1',
            },
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

    await tester.pumpWidget(
      _buildHarness(
        pageAyahResolver: (int pageNumber) async => const Ayah(
          id: 1,
          surahNumber: 1,
          ayahNumber: 1,
          text: 'text',
          page: 1,
          juz: 1,
          hizb: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resume reading').first);
    await tester.pumpAndSettle();

    expect(find.text('Reader route 1:1'), findsOneWidget);
  });
}

Widget _buildHarness({
  Future<Ayah?> Function(int pageNumber)? pageAyahResolver,
}) {
  return ProviderScope(
    overrides: [
      khatmaPlannerNowProvider.overrideWith((ref) {
        return () => DateTime(2026, 3, 26, 12, 0);
      }),
      memorizationAyahPageResolverProvider.overrideWith((ref) {
        return (int surahNumber, int ayahNumber) async => 42;
      }),
      memorizationPageAyahResolverProvider.overrideWith((ref) {
        return pageAyahResolver ??
            (int pageNumber) async => const Ayah(
                  id: 1,
                  surahNumber: 1,
                  ayahNumber: 1,
                  text: 'text',
                  page: 1,
                  juz: 1,
                  hizb: 1,
                );
      }),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: '/memorization/khatma/khatma-1',
        routes: [
          GoRoute(
            path: '/memorization/khatma/:khatmaId',
            builder: (context, state) => KhatmaPlannerScreen(
              khatmaId: state.pathParameters['khatmaId']!,
            ),
          ),
          GoRoute(
            path: '/reader',
            builder: (context, state) => Consumer(
              builder: (context, ref, child) {
                final target = ref.watch(readerNavigationTargetProvider);
                return Scaffold(
                  body: Center(
                    child: Text(
                      'Reader route ${target.surahNumber}:${target.ayahNumber}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
