import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_dashboard_summary.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_policy.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_snapshot.dart';
import 'package:quran_kareem/features/memorization/presentation/screens/achievements_dashboard_screen.dart';
import 'package:quran_kareem/features/memorization/presentation/screens/memorization_screen.dart';
import 'package:quran_kareem/features/memorization/providers/achievements_providers.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  testWidgets(
    'renders the localized achievements dashboard summary and pending unlock banner',
    (tester) async {
      _seedAchievementsData();

      await tester.pumpWidget(
        _buildHarness(initialLocation: '/memorization/achievements'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Achievements'), findsWidgets);
      expect(find.text('Level 4'), findsWidgets);
      expect(find.text('310 XP'), findsOneWidget);
      expect(find.text('Badges'), findsOneWidget);
      expect(find.text('Personal records'), findsOneWidget);
      expect(find.text('New unlocks'), findsOneWidget);
      expect(find.text('Your momentum'), findsOneWidget);
      expect(find.text('Next milestone'), findsOneWidget);
      expect(find.text('In progress'), findsWidgets);
      expect(find.text('First steps'), findsWidgets);
      expect(find.text('Khatma builder'), findsWidgets);
    },
  );

  testWidgets('renders the refined Arabic achievements tone from localization',
      (tester) async {
    _seedAchievementsData();

    await tester.pumpWidget(
      _buildHarness(
        initialLocation: '/memorization/achievements',
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('زخم رحلتك'), findsOneWidget);
    expect(find.text('المحطة الأقرب'), findsOneWidget);
    expect(find.text('إنجازاتك الجديدة'), findsOneWidget);
    expect(find.text('أفضل أرقامك'), findsOneWidget);
    expect(find.text('قيد الإنجاز'), findsWidgets);
  });

  testWidgets('opens the achievements dashboard from the memorization hub', (
    tester,
  ) async {
    _seedAchievementsData();

    await tester.pumpWidget(_buildHarness(initialLocation: '/memorization'));
    await tester.pumpAndSettle();

    final achievementsButton = find.text('Achievements');
    expect(achievementsButton, findsOneWidget);

    await tester.tap(achievementsButton);
    await tester.pumpAndSettle();

    expect(find.text('Level 4'), findsWidgets);
    expect(find.text('Personal records'), findsOneWidget);
  });

  testWidgets('shows an all-earned fallback when the full catalog is unlocked',
      (
    tester,
  ) async {
    final snapshot = AchievementSnapshot(
      rawSessionCount: 24,
      regularSessionCount: 20,
      trustedKhatmaAnchorCount: 4,
      orphanTrustedAnchorCount: 0,
      normalizedVisitCount: 20,
      generalVisitCount: 16,
      khatmaVisitCount: 4,
      totalTrackedMinutes: 180,
      totalKhatmaCount: 4,
      completedKhatmaCount: 3,
      totalReviewItemCount: 4,
      reviewedReviewCount: 3,
      totalReviewRepetitions: 6,
      readingDayCount: 12,
      currentReadingStreakDays: 12,
      bestReadingStreakDays: 12,
      latestActivityAt: DateTime(2026, 3, 28, 12),
      normalizedVisits: const [],
      readingDayKeys: const [],
      khatmas: const <Khatma>[],
      reviewItems: const <SpacedReviewItem>[],
    );
    final summary = AchievementPolicy.build(snapshot);

    await tester.pumpWidget(
      _buildHarness(
        initialLocation: '/memorization/achievements',
        overrides: [
          achievementsSnapshotProvider.overrideWith((ref) => snapshot),
          achievementsSummaryProvider.overrideWith((ref) => summary),
          achievementsPendingUnlocksProvider.overrideWith(
            (ref) => const <AchievementUnlock>[],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your momentum'), findsOneWidget);
    expect(find.text('All badges earned'), findsOneWidget);
    expect(find.text('Unlocked'), findsWidgets);
  });
}

void _seedAchievementsData() {
  SharedPreferences.setMockInitialValues(
    <String, Object>{
      'readingSessions': jsonEncode(
        [
          ReadingSession(
            id: 'general-1',
            surahNumber: 1,
            ayahNumber: 1,
            surahName: 'Al-Fatihah',
            timestamp: DateTime(2026, 3, 20, 8),
            durationMinutes: 5,
          ).toMap(),
          ReadingSession(
            id: 'visit-1',
            surahNumber: 2,
            ayahNumber: 255,
            surahName: 'Al-Baqarah',
            timestamp: DateTime(2026, 3, 21, 9),
            durationMinutes: 7,
          ).toMap(),
          ReadingSession(
            id: 'khatma-k1',
            surahNumber: 2,
            ayahNumber: 255,
            surahName: 'Al-Baqarah',
            timestamp: DateTime(2026, 3, 21, 9),
            durationMinutes: 7,
            khatmaId: 'k1',
            isTrustedKhatmaAnchor: true,
          ).toMap(),
        ],
      ),
      'khatmas': jsonEncode(
        [
          Khatma(
            id: 'k1',
            title: 'Completed One',
            targetDays: 14,
            startDate: DateTime(2026, 3, 1),
            completedDate: DateTime(2026, 3, 21),
            completedSurahs: 114,
            furthestPageRead: 604,
            totalReadMinutes: 15,
            readingDayKeys: const ['2026-03-21'],
          ).toMap(),
          Khatma(
            id: 'k2',
            title: 'Completed Two',
            targetDays: 21,
            startDate: DateTime(2026, 3, 2),
            completedDate: DateTime(2026, 3, 24),
            completedSurahs: 114,
            furthestPageRead: 604,
            totalReadMinutes: 25,
            readingDayKeys: const ['2026-03-22', '2026-03-23'],
          ).toMap(),
        ],
      ),
      'spacedReviewItems': jsonEncode(
        [
          SpacedReviewItem(
            id: 'review-1',
            khatmaId: 'k1',
            khatmaTitle: 'Completed One',
            startPage: 1,
            endPage: 10,
            createdAt: DateTime(2026, 3, 20, 7),
            nextReviewAt: DateTime(2026, 3, 27, 7),
            repetitionCount: 0,
            intervalDays: 1,
            easeFactor: 2.3,
          ).toMap(),
          SpacedReviewItem(
            id: 'review-2',
            khatmaId: 'k2',
            khatmaTitle: 'Completed Two',
            startPage: 11,
            endPage: 20,
            createdAt: DateTime(2026, 3, 21, 7),
            nextReviewAt: DateTime(2026, 3, 28, 7),
            lastReviewedAt: DateTime(2026, 3, 26, 7),
            repetitionCount: 2,
            intervalDays: 4,
            easeFactor: 2.5,
            lastOutcome: ReviewOutcome.easy,
          ).toMap(),
        ],
      ),
    },
  );
}

Widget _buildHarness({
  required String initialLocation,
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      achievementsNowProvider.overrideWith(
        (ref) => () => DateTime(2026, 3, 28, 12),
      ),
      memorizationAyahPageResolverProvider.overrideWith((ref) {
        return (int surahNumber, int ayahNumber) async => 42;
      }),
      ...overrides,
    ],
    child: MaterialApp.router(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/memorization',
            builder: (context, state) => const MemorizationScreen(),
          ),
          GoRoute(
            path: '/memorization/achievements',
            builder: (context, state) => const AchievementsDashboardScreen(),
          ),
          GoRoute(
            path: '/memorization/reviews',
            builder: (context, state) => const Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
          GoRoute(
            path: '/reader',
            builder: (context, state) => const Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        ],
      ),
    ),
  );
}
