import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_period_snapshot.dart';
import 'package:quran_kareem/features/analytics/providers/analytics_providers.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/providers/achievements_providers.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/memorization/providers/spaced_review_providers.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'readingSessions': jsonEncode(
          [
            ReadingSession(
              id: 'week-general',
              surahNumber: 2,
              ayahNumber: 255,
              surahName: 'Al-Baqarah',
              timestamp: DateTime(2026, 4, 14, 9),
              durationMinutes: 10,
            ).toMap(),
            ReadingSession(
              id: 'week-anchor',
              surahNumber: 2,
              ayahNumber: 255,
              surahName: 'Al-Baqarah',
              timestamp: DateTime(2026, 4, 14, 9),
              durationMinutes: 10,
              khatmaId: 'k1',
              isTrustedKhatmaAnchor: true,
            ).toMap(),
            ReadingSession(
              id: 'week-second',
              surahNumber: 36,
              ayahNumber: 1,
              surahName: 'Ya-Sin',
              timestamp: DateTime(2026, 4, 17, 12),
              durationMinutes: 8,
            ).toMap(),
            ReadingSession(
              id: 'month-only',
              surahNumber: 18,
              ayahNumber: 10,
              surahName: 'Al-Kahf',
              timestamp: DateTime(2026, 4, 2, 10),
              durationMinutes: 20,
            ).toMap(),
          ],
        ),
        'khatmas': jsonEncode(
          [
            Khatma(
              id: 'k1',
              title: 'April Khatma',
              targetDays: 30,
              startDate: DateTime(2026, 4, 10),
              furthestPageRead: 20,
              totalReadMinutes: 18,
              readingDayKeys: const ['2026-04-14', '2026-04-17'],
            ).toMap(),
          ],
        ),
        'spacedReviewItems': jsonEncode(
          [
            SpacedReviewItem(
              id: 'review-week-done',
              khatmaId: 'k1',
              khatmaTitle: 'April Khatma',
              startPage: 1,
              endPage: 10,
              createdAt: DateTime(2026, 4, 13, 8),
              nextReviewAt: DateTime(2026, 4, 15, 8),
              lastReviewedAt: DateTime(2026, 4, 15, 10),
              repetitionCount: 1,
              intervalDays: 2,
              easeFactor: 2.3,
              lastOutcome: ReviewOutcome.easy,
            ).toMap(),
            SpacedReviewItem(
              id: 'review-week-overdue',
              khatmaId: 'k1',
              khatmaTitle: 'April Khatma',
              startPage: 11,
              endPage: 20,
              createdAt: DateTime(2026, 4, 13, 8),
              nextReviewAt: DateTime(2026, 4, 16, 8),
              repetitionCount: 0,
              intervalDays: 1,
              easeFactor: 2.3,
            ).toMap(),
            SpacedReviewItem(
              id: 'review-month-done',
              khatmaId: 'k1',
              khatmaTitle: 'April Khatma',
              startPage: 21,
              endPage: 30,
              createdAt: DateTime(2026, 4, 1, 8),
              nextReviewAt: DateTime(2026, 4, 3, 8),
              lastReviewedAt: DateTime(2026, 4, 3, 9),
              repetitionCount: 1,
              intervalDays: 2,
              easeFactor: 2.3,
              lastOutcome: ReviewOutcome.medium,
            ).toMap(),
          ],
        ),
      },
    );
  });

  test('defaults to thisWeek and allows period toggling', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(analyticsPeriodTypeProvider),
        AnalyticsPeriodType.thisWeek);

    container.read(analyticsPeriodTypeProvider.notifier).state =
        AnalyticsPeriodType.thisMonth;

    expect(
      container.read(analyticsPeriodTypeProvider),
      AnalyticsPeriodType.thisMonth,
    );
  });

  test(
      'derives weekly and monthly summaries from memorization, prayer, and achievements sources',
      () async {
    final container = ProviderContainer(
      overrides: [
        analyticsNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 4, 18, 12),
        ),
        achievementsNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 4, 18, 12),
        ),
        memorizationAyahPageResolverProvider.overrideWith((ref) {
          return (int surahNumber, int ayahNumber) async {
            if (surahNumber == 2) {
              return 42;
            }
            if (surahNumber == 36) {
              return 440;
            }
            return 293;
          };
        }),
        prayerTrackingLocalDataSourceProvider.overrideWithValue(
          _FakePrayerTrackingLocalDataSource(
            <String, PrayerDayTracking>{
              '2026-04-02': const PrayerDayTracking(
                dateKey: '2026-04-02',
                completedPrayers: {
                  PrayerType.fajr,
                  PrayerType.dhuhr,
                  PrayerType.asr,
                  PrayerType.maghrib,
                  PrayerType.isha,
                },
              ),
              '2026-04-13': const PrayerDayTracking(
                dateKey: '2026-04-13',
                completedPrayers: {
                  PrayerType.fajr,
                  PrayerType.dhuhr,
                  PrayerType.asr,
                  PrayerType.maghrib,
                  PrayerType.isha,
                },
              ),
              '2026-04-14': const PrayerDayTracking(
                dateKey: '2026-04-14',
                completedPrayers: {
                  PrayerType.fajr,
                  PrayerType.dhuhr,
                  PrayerType.asr,
                },
              ),
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sessionsProvider.notifier).ready;
    await container.read(khatmasProvider.notifier).ready;
    await container.read(spacedReviewItemsProvider.notifier).ready;

    final weekly =
        await container.read(analyticsDashboardSummaryProvider.future);

    expect(weekly.periodType, AnalyticsPeriodType.thisWeek);
    expect(weekly.current.reading.totalMinutes, 18);
    expect(weekly.current.reading.normalizedVisitCount, 2);
    expect(weekly.current.memorization.reviewDueCount, 2);
    expect(weekly.current.memorization.overdueReviewCount, 1);
    expect(weekly.current.prayer.completedPrayersCount, 8);
    expect(
      weekly.current.prayer.completionRate,
      closeTo(8 / 35, 0.001),
    );

    container.read(analyticsPeriodTypeProvider.notifier).state =
        AnalyticsPeriodType.thisMonth;
    container.invalidate(analyticsDashboardSummaryProvider);

    final monthly =
        await container.read(analyticsDashboardSummaryProvider.future);

    expect(monthly.periodType, AnalyticsPeriodType.thisMonth);
    expect(monthly.current.reading.totalMinutes, 38);
    expect(monthly.current.reading.normalizedVisitCount, 3);
    expect(monthly.current.reading.pagesVisitedCount, 3);
    expect(monthly.current.memorization.completedReviewsCount, 2);
    expect(monthly.current.memorization.reviewDueCount, 3);
    expect(monthly.current.memorization.overdueReviewCount, 1);
    expect(
      monthly.current.memorization.reviewAdherenceRate,
      closeTo(2 / 3, 0.001),
    );
    expect(monthly.current.prayer.completedPrayersCount, 13);
    expect(
      monthly.current.prayer.completionRate,
      closeTo(13 / 150, 0.001),
    );
  });
}

class _FakePrayerTrackingLocalDataSource
    implements PrayerTrackingLocalDataSource {
  _FakePrayerTrackingLocalDataSource(this.trackings);

  final Map<String, PrayerDayTracking> trackings;

  @override
  Future<Map<String, PrayerDayTracking>> loadTrackings(
    Iterable<String> dateKeys,
  ) async {
    return {
      for (final dateKey in dateKeys)
        if (trackings.containsKey(dateKey)) dateKey: trackings[dateKey]!,
    };
  }

  @override
  Future<Map<String, PrayerDayTracking>> getTrackingsForDateRange(
    String startKey,
    String endKey,
  ) async {
    final start = PrayerTimesPolicies.parseDateKey(startKey);
    final end = PrayerTimesPolicies.parseDateKey(endKey);
    final requestedKeys = <String>[];
    var cursor = DateTime(start.year, start.month, start.day);
    while (!cursor.isAfter(end)) {
      requestedKeys.add(PrayerTimesPolicies.dateKey(cursor));
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }
    return loadTrackings(requestedKeys);
  }

  @override
  Future<void> setPrayerCompleted({
    required String dateKey,
    required PrayerType prayer,
    required bool completed,
  }) async {}
}
