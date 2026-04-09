import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_dashboard_summary.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_period_snapshot.dart';
import 'package:quran_kareem/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:quran_kareem/features/analytics/presentation/widgets/analytics_memorization_card.dart';
import 'package:quran_kareem/features/analytics/presentation/widgets/analytics_prayer_card.dart';
import 'package:quran_kareem/features/analytics/providers/analytics_providers.dart';

void main() {
  testWidgets('renders the period selector and reading hero with seeded data', (
    tester,
  ) async {
    await tester.pumpWidget(_buildHarness(summary: _summary()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('analytics-period-selector')), findsOneWidget);
    expect(find.byKey(const Key('analytics-reading-hero')), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('Your reading time for this period'), findsOneWidget);
  });

  testWidgets(
      'shows the global empty state when the current period has no data',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        summary: _summary(
          current: _zeroSnapshot(
            range: AnalyticsPeriodType.thisWeek.currentRange(
              DateTime(2026, 4, 18, 12),
            ),
          ),
          previous: _zeroSnapshot(
            range: AnalyticsPeriodType.thisWeek.previousRange(
              DateTime(2026, 4, 18, 12),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
        find.byKey(const Key('analytics-overall-empty-state')), findsOneWidget);
    expect(find.text('Your analytics will appear here'), findsOneWidget);
  });

  testWidgets(
      'shows memorization progress details and a zero-review hint when needed',
      (tester) async {
    await tester.pumpWidget(
      _buildCardHarness(
        child: AnalyticsMemorizationCard(
          snapshot: _snapshot(
            range: AnalyticsPeriodType.thisWeek.currentRange(
              DateTime(2026, 4, 18, 12),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
        find.byKey(const Key('analytics-memorization-card')), findsOneWidget);
    expect(find.text('Weekly Khatma'), findsOneWidget);

    await tester.pumpWidget(
      _buildCardHarness(
        child: AnalyticsMemorizationCard(
          snapshot: _snapshot(
            range: AnalyticsPeriodType.thisWeek.currentRange(
              DateTime(2026, 4, 18, 12),
            ),
            memorization: const AnalyticsMemorizationMetrics(
              activeKhatmas: <AnalyticsKhatmaProgress>[
                AnalyticsKhatmaProgress(
                  id: 'k1',
                  title: 'Weekly Khatma',
                  progress: 0.4,
                  furthestPageRead: 120,
                  totalReadMinutes: 18,
                ),
              ],
              completedReviewsCount: 0,
              reviewDueCount: 0,
              overdueReviewCount: 0,
              reviewAdherenceRate: null,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
        find.byKey(const Key('analytics-review-empty-hint')), findsOneWidget);
  });

  testWidgets('shows the prayer card full-completion and empty states', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildCardHarness(
        child: AnalyticsPrayerCard(
          snapshot: _snapshot(
            range: AnalyticsPeriodType.thisWeek.currentRange(
              DateTime(2026, 4, 18, 12),
            ),
            prayer: const AnalyticsPrayerMetrics(
              completedPrayersCount: 35,
              totalPossiblePrayersCount: 35,
              perfectDaysCount: 7,
              trackedDaysCount: 7,
              completionRate: 1,
            ),
          ),
          delta: const AnalyticsMetricDelta(
            currentValue: 1,
            previousValue: 0.5,
            direction: AnalyticsDeltaDirection.up,
            percentageChange: 1,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Perfect consistency in this period'), findsOneWidget);

    await tester.pumpWidget(
      _buildCardHarness(
        child: AnalyticsPrayerCard(
          snapshot: _snapshot(
            range: AnalyticsPeriodType.thisWeek.currentRange(
              DateTime(2026, 4, 18, 12),
            ),
            prayer: const AnalyticsPrayerMetrics(
              completedPrayersCount: 0,
              totalPossiblePrayersCount: 35,
              perfectDaysCount: 0,
              trackedDaysCount: 0,
              completionRate: null,
            ),
          ),
          delta: const AnalyticsMetricDelta(
            currentValue: 0,
            previousValue: 0,
            direction: AnalyticsDeltaDirection.neutral,
            percentageChange: 0,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
        find.byKey(const Key('analytics-prayer-empty-state')), findsOneWidget);
    expect(find.text('No prayer tracking yet'), findsOneWidget);
  });

  testWidgets('renders the full dashboard sections with seeded data', (
    tester,
  ) async {
    await tester.pumpWidget(_buildHarness(summary: _summary()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('analytics-reading-hero')), findsOneWidget);
    expect(
        find.byKey(const Key('analytics-reading-detail-card')), findsOneWidget);
    expect(find.byKey(const Key('analytics-top-surahs-card')), findsOneWidget);
    expect(
        find.byKey(const Key('analytics-memorization-card')), findsOneWidget);
    expect(find.byKey(const Key('analytics-prayer-card')), findsOneWidget);
  });

  testWidgets(
      'renders dashboard strings from AppLocalizations in Arabic locale',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        summary: _summary(),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('هذا الأسبوع'), findsOneWidget);
    expect(find.text('هذا الشهر'), findsOneWidget);
    expect(find.text('التحليلات'), findsOneWidget);
    expect(find.text('ملخص القراءة'), findsOneWidget);
  });
}

Widget _buildHarness({
  required AnalyticsDashboardSummary summary,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      analyticsDashboardSummaryProvider.overrideWith((ref) async => summary),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const AnalyticsDashboardScreen(),
    ),
  );
}

Widget _buildCardHarness({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );
}

AnalyticsDashboardSummary _summary({
  AnalyticsPeriodSnapshot? current,
  AnalyticsPeriodSnapshot? previous,
}) {
  final resolvedCurrent = current ??
      _snapshot(
        range: AnalyticsPeriodType.thisWeek.currentRange(
          DateTime(2026, 4, 18, 12),
        ),
      );
  final resolvedPrevious = previous ??
      _snapshot(
        range: AnalyticsPeriodType.thisWeek.previousRange(
          DateTime(2026, 4, 18, 12),
        ),
        reading: const AnalyticsReadingMetrics(
          totalMinutes: 12,
          normalizedVisitCount: 1,
          pagesVisitedCount: 1,
          readingDaysCount: 1,
          averageDailyMinutes: 1.71,
          currentStreakDays: 1,
          topSurahs: <AnalyticsTopSurahStat>[
            AnalyticsTopSurahStat(
              surahNumber: 18,
              surahName: 'Al-Kahf',
              visitCount: 1,
            ),
          ],
        ),
        memorization: const AnalyticsMemorizationMetrics(
          activeKhatmas: <AnalyticsKhatmaProgress>[
            AnalyticsKhatmaProgress(
              id: 'k1',
              title: 'Weekly Khatma',
              progress: 0.25,
              furthestPageRead: 80,
              totalReadMinutes: 12,
            ),
          ],
          completedReviewsCount: 1,
          reviewDueCount: 1,
          overdueReviewCount: 0,
          reviewAdherenceRate: 1,
        ),
        prayer: const AnalyticsPrayerMetrics(
          completedPrayersCount: 5,
          totalPossiblePrayersCount: 35,
          perfectDaysCount: 1,
          trackedDaysCount: 1,
          completionRate: 5 / 35,
        ),
      );

  return AnalyticsDashboardSummaryPolicy.build(
    periodType: AnalyticsPeriodType.thisWeek,
    current: resolvedCurrent,
    previous: resolvedPrevious,
  );
}

AnalyticsPeriodSnapshot _snapshot({
  required AnalyticsDateRange range,
  AnalyticsReadingMetrics reading = const AnalyticsReadingMetrics(
    totalMinutes: 18,
    normalizedVisitCount: 2,
    pagesVisitedCount: 2,
    readingDaysCount: 2,
    averageDailyMinutes: 2.57,
    currentStreakDays: 2,
    topSurahs: <AnalyticsTopSurahStat>[
      AnalyticsTopSurahStat(
        surahNumber: 2,
        surahName: 'Al-Baqarah',
        visitCount: 2,
      ),
      AnalyticsTopSurahStat(
        surahNumber: 36,
        surahName: 'Ya-Sin',
        visitCount: 1,
      ),
    ],
  ),
  AnalyticsMemorizationMetrics memorization =
      const AnalyticsMemorizationMetrics(
    activeKhatmas: <AnalyticsKhatmaProgress>[
      AnalyticsKhatmaProgress(
        id: 'k1',
        title: 'Weekly Khatma',
        progress: 0.4,
        furthestPageRead: 120,
        totalReadMinutes: 18,
      ),
    ],
    completedReviewsCount: 1,
    reviewDueCount: 2,
    overdueReviewCount: 1,
    reviewAdherenceRate: 0.5,
  ),
  AnalyticsPrayerMetrics prayer = const AnalyticsPrayerMetrics(
    completedPrayersCount: 8,
    totalPossiblePrayersCount: 35,
    perfectDaysCount: 1,
    trackedDaysCount: 2,
    completionRate: 8 / 35,
  ),
}) {
  return AnalyticsPeriodSnapshot(
    type: AnalyticsPeriodType.thisWeek,
    range: range,
    reading: reading,
    memorization: memorization,
    prayer: prayer,
  );
}

AnalyticsPeriodSnapshot _zeroSnapshot({
  required AnalyticsDateRange range,
}) {
  return AnalyticsPeriodSnapshot(
    type: AnalyticsPeriodType.thisWeek,
    range: range,
    reading: const AnalyticsReadingMetrics(
      totalMinutes: 0,
      normalizedVisitCount: 0,
      pagesVisitedCount: 0,
      readingDaysCount: 0,
      averageDailyMinutes: 0,
      currentStreakDays: 0,
      topSurahs: <AnalyticsTopSurahStat>[],
    ),
    memorization: const AnalyticsMemorizationMetrics(
      activeKhatmas: <AnalyticsKhatmaProgress>[],
      completedReviewsCount: 0,
      reviewDueCount: 0,
      overdueReviewCount: 0,
      reviewAdherenceRate: null,
    ),
    prayer: const AnalyticsPrayerMetrics(
      completedPrayersCount: 0,
      totalPossiblePrayersCount: 35,
      perfectDaysCount: 0,
      trackedDaysCount: 0,
      completionRate: null,
    ),
  );
}
