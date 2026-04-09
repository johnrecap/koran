import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_period_policy.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_period_snapshot.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_snapshot.dart';
import 'package:quran_kareem/features/more/domain/prayer_day_tracking.dart';
import 'package:quran_kareem/features/more/domain/prayer_time_models.dart';

void main() {
  final weekRange = AnalyticsDateRange(
    start: DateTime(2026, 3, 30),
    endExclusive: DateTime(2026, 4, 6),
  );

  test('builds a deterministic zero-state snapshot', () {
    final snapshot = _buildSnapshot(
      range: weekRange,
      sessions: const <ReadingSession>[],
      khatmas: const <Khatma>[],
      reviewItems: const <SpacedReviewItem>[],
      prayerTrackingsByDayKey: const <String, PrayerDayTracking>{},
      sessionPageById: const <String, int>{},
    );

    expect(snapshot.reading.totalMinutes, 0);
    expect(snapshot.reading.normalizedVisitCount, 0);
    expect(snapshot.reading.readingDaysCount, 0);
    expect(snapshot.reading.averageDailyMinutes, 0);
    expect(snapshot.reading.topSurahs, isEmpty);
    expect(snapshot.memorization.activeKhatmaCount, 0);
    expect(snapshot.memorization.reviewAdherenceRate, isNull);
    expect(snapshot.prayer.completionRate, isNull);
    expect(snapshot.hasAnyData, isFalse);
  });

  test(
      'normalizes dual-save visits, keeps orphan anchors, ignores missing surah labels, and computes review and prayer metrics',
      () {
    final sessions = [
      ReadingSession(
        id: 'general-1',
        surahNumber: 2,
        ayahNumber: 255,
        surahName: 'Al-Baqarah',
        timestamp: DateTime(2026, 3, 31, 9),
        durationMinutes: 12,
      ),
      ReadingSession(
        id: 'anchor-1',
        surahNumber: 2,
        ayahNumber: 255,
        surahName: 'Al-Baqarah',
        timestamp: DateTime(2026, 3, 31, 9),
        durationMinutes: 12,
        khatmaId: 'k1',
        isTrustedKhatmaAnchor: true,
      ),
      ReadingSession(
        id: 'general-2',
        surahNumber: 36,
        ayahNumber: 1,
        surahName: 'Ya-Sin',
        timestamp: DateTime(2026, 4, 1, 11),
        durationMinutes: 8,
      ),
      ReadingSession(
        id: 'orphan-anchor',
        surahNumber: 67,
        ayahNumber: 1,
        surahName: 'Al-Mulk',
        timestamp: DateTime(2026, 4, 2, 12),
        durationMinutes: 6,
        khatmaId: 'k2',
        isTrustedKhatmaAnchor: true,
      ),
      ReadingSession(
        id: 'zero-minutes',
        surahNumber: 18,
        ayahNumber: 10,
        surahName: 'Al-Kahf',
        timestamp: DateTime(2026, 4, 3, 8),
        durationMinutes: 0,
      ),
      ReadingSession(
        id: 'missing-surah',
        surahNumber: 0,
        ayahNumber: 1,
        surahName: '',
        timestamp: DateTime(2026, 4, 4, 7),
        durationMinutes: 4,
      ),
    ];
    final khatmas = [
      Khatma(
        id: 'k1',
        title: 'Weekly Plan',
        targetDays: 7,
        startDate: DateTime(2026, 3, 28),
        furthestPageRead: 80,
        totalReadMinutes: 20,
        readingDayKeys: const ['2026-03-31'],
      ),
    ];
    final reviewItems = [
      SpacedReviewItem(
        id: 'review-1',
        khatmaId: 'k1',
        khatmaTitle: 'Weekly Plan',
        startPage: 1,
        endPage: 10,
        createdAt: DateTime(2026, 3, 30, 6),
        nextReviewAt: DateTime(2026, 4, 1, 6),
        lastReviewedAt: DateTime(2026, 4, 1, 8),
        repetitionCount: 1,
        intervalDays: 2,
        easeFactor: 2.3,
        lastOutcome: ReviewOutcome.easy,
      ),
      SpacedReviewItem(
        id: 'review-2',
        khatmaId: 'k1',
        khatmaTitle: 'Weekly Plan',
        startPage: 11,
        endPage: 20,
        createdAt: DateTime(2026, 3, 30, 6),
        nextReviewAt: DateTime(2026, 4, 3, 6),
        repetitionCount: 0,
        intervalDays: 1,
        easeFactor: 2.3,
      ),
    ];
    final prayerTrackings = <String, PrayerDayTracking>{
      '2026-03-30': const PrayerDayTracking(
        dateKey: '2026-03-30',
        completedPrayers: {
          PrayerType.fajr,
          PrayerType.dhuhr,
          PrayerType.asr,
          PrayerType.maghrib,
          PrayerType.isha,
        },
      ),
      '2026-03-31': const PrayerDayTracking(
        dateKey: '2026-03-31',
        completedPrayers: {
          PrayerType.fajr,
          PrayerType.dhuhr,
          PrayerType.asr,
        },
      ),
    };

    final snapshot = _buildSnapshot(
      range: weekRange,
      sessions: sessions,
      khatmas: khatmas,
      reviewItems: reviewItems,
      prayerTrackingsByDayKey: prayerTrackings,
      sessionPageById: const {
        'general-1': 42,
        'anchor-1': 42,
        'general-2': 440,
        'orphan-anchor': 562,
        'zero-minutes': 293,
      },
    );

    expect(snapshot.reading.normalizedVisitCount, 5);
    expect(snapshot.reading.totalMinutes, 30);
    expect(snapshot.reading.readingDaysCount, 5);
    expect(snapshot.reading.pagesVisitedCount, 4);
    expect(snapshot.reading.averageDailyMinutes, closeTo(30 / 7, 0.001));
    expect(
      snapshot.reading.topSurahs.map((item) => item.surahName),
      const ['Al-Baqarah', 'Al-Kahf', 'Ya-Sin', 'Al-Mulk'],
    );
    expect(snapshot.memorization.activeKhatmaCount, 1);
    expect(snapshot.memorization.completedReviewsCount, 1);
    expect(snapshot.memorization.reviewDueCount, 2);
    expect(snapshot.memorization.overdueReviewCount, 1);
    expect(snapshot.memorization.reviewAdherenceRate, 0.5);
    expect(snapshot.prayer.completedPrayersCount, 8);
    expect(snapshot.prayer.perfectDaysCount, 1);
    expect(snapshot.prayer.completionRate, closeTo(8 / 35, 0.001));
    expect(snapshot.hasAnyData, isTrue);
  });

  test('filters by inclusive start and exclusive end boundaries', () {
    final snapshot = _buildSnapshot(
      range: weekRange,
      sessions: [
        ReadingSession(
          id: 'included-start',
          surahNumber: 1,
          ayahNumber: 1,
          surahName: 'Al-Fatihah',
          timestamp: DateTime(2026, 3, 30),
          durationMinutes: 4,
        ),
        ReadingSession(
          id: 'excluded-end',
          surahNumber: 2,
          ayahNumber: 1,
          surahName: 'Al-Baqarah',
          timestamp: DateTime(2026, 4, 6),
          durationMinutes: 9,
        ),
      ],
      khatmas: const <Khatma>[],
      reviewItems: const <SpacedReviewItem>[],
      prayerTrackingsByDayKey: const <String, PrayerDayTracking>{},
      sessionPageById: const {
        'included-start': 1,
        'excluded-end': 2,
      },
    );

    expect(snapshot.reading.normalizedVisitCount, 1);
    expect(snapshot.reading.totalMinutes, 4);
    expect(snapshot.reading.topSurahs.single.surahName, 'Al-Fatihah');
  });
}

AnalyticsPeriodSnapshot _buildSnapshot({
  required AnalyticsDateRange range,
  required List<ReadingSession> sessions,
  required List<Khatma> khatmas,
  required List<SpacedReviewItem> reviewItems,
  required Map<String, PrayerDayTracking> prayerTrackingsByDayKey,
  required Map<String, int> sessionPageById,
}) {
  return AnalyticsPeriodPolicy.build(
    type: AnalyticsPeriodType.thisWeek,
    range: range,
    sessions: sessions,
    khatmas: khatmas,
    reviewItems: reviewItems,
    achievementSnapshot: AchievementSnapshotPolicy.build(
      sessions: sessions,
      khatmas: khatmas,
      reviewItems: reviewItems,
      now: DateTime(2026, 4, 4, 12),
    ),
    prayerTrackingsByDayKey: prayerTrackingsByDayKey,
    sessionPageById: sessionPageById,
  );
}
