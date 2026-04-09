import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_snapshot.dart';

void main() {
  test('builds a stable empty-state achievement snapshot', () {
    final snapshot = AchievementSnapshotPolicy.build(
      sessions: const <ReadingSession>[],
      khatmas: const <Khatma>[],
      reviewItems: const <SpacedReviewItem>[],
      now: DateTime(2026, 3, 28, 12),
    );

    expect(snapshot.rawSessionCount, 0);
    expect(snapshot.normalizedVisitCount, 0);
    expect(snapshot.totalTrackedMinutes, 0);
    expect(snapshot.totalKhatmaCount, 0);
    expect(snapshot.completedKhatmaCount, 0);
    expect(snapshot.totalReviewItemCount, 0);
    expect(snapshot.reviewedReviewCount, 0);
    expect(snapshot.totalReviewRepetitions, 0);
    expect(snapshot.readingDayCount, 0);
    expect(snapshot.bestReadingStreakDays, 0);
    expect(snapshot.latestActivityAt, isNull);
  });

  test('normalizes dual-save khatma visits and aggregates lifetime progress',
      () {
    final snapshot = AchievementSnapshotPolicy.build(
      sessions: [
        ReadingSession(
          id: 'general-1',
          surahNumber: 1,
          ayahNumber: 1,
          surahName: 'Al-Fatihah',
          timestamp: DateTime(2026, 3, 20, 8),
          durationMinutes: 5,
        ),
        ReadingSession(
          id: 'visit-1',
          surahNumber: 2,
          ayahNumber: 255,
          surahName: 'Al-Baqarah',
          timestamp: DateTime(2026, 3, 21, 9),
          durationMinutes: 7,
        ),
        ReadingSession(
          id: 'khatma-k1',
          surahNumber: 2,
          ayahNumber: 255,
          surahName: 'Al-Baqarah',
          timestamp: DateTime(2026, 3, 21, 9),
          durationMinutes: 7,
          khatmaId: 'k1',
          isTrustedKhatmaAnchor: true,
        ),
        ReadingSession(
          id: 'general-2',
          surahNumber: 36,
          ayahNumber: 1,
          surahName: 'Ya-Sin',
          timestamp: DateTime(2026, 3, 22, 10),
        ),
        ReadingSession(
          id: 'khatma-k2',
          surahNumber: 67,
          ayahNumber: 1,
          surahName: 'Al-Mulk',
          timestamp: DateTime(2026, 3, 23, 11),
          durationMinutes: 4,
          khatmaId: 'k2',
          isTrustedKhatmaAnchor: true,
        ),
      ],
      khatmas: [
        Khatma(
          id: 'k1',
          title: 'Completed Khatma',
          targetDays: 14,
          startDate: DateTime(2026, 3, 1),
          completedDate: DateTime(2026, 3, 21),
          completedSurahs: 114,
          furthestPageRead: 604,
          totalReadMinutes: 15,
          readingDayKeys: const ['2026-03-21'],
        ),
        Khatma(
          id: 'k2',
          title: 'Active Khatma',
          targetDays: 30,
          startDate: DateTime(2026, 3, 10),
          furthestPageRead: 120,
          totalReadMinutes: 25,
          readingDayKeys: const ['2026-03-23', '2026-03-24'],
        ),
      ],
      reviewItems: [
        SpacedReviewItem(
          id: 'review-1',
          khatmaId: 'k1',
          khatmaTitle: 'Completed Khatma',
          startPage: 1,
          endPage: 10,
          createdAt: DateTime(2026, 3, 20, 7),
          nextReviewAt: DateTime(2026, 3, 27, 7),
          repetitionCount: 0,
          intervalDays: 1,
          easeFactor: 2.3,
        ),
        SpacedReviewItem(
          id: 'review-2',
          khatmaId: 'k2',
          khatmaTitle: 'Active Khatma',
          startPage: 11,
          endPage: 20,
          createdAt: DateTime(2026, 3, 21, 7),
          nextReviewAt: DateTime(2026, 3, 28, 7),
          lastReviewedAt: DateTime(2026, 3, 26, 7),
          repetitionCount: 2,
          intervalDays: 4,
          easeFactor: 2.5,
          lastOutcome: ReviewOutcome.easy,
        ),
      ],
      now: DateTime(2026, 3, 28, 12),
    );

    expect(snapshot.rawSessionCount, 5);
    expect(snapshot.regularSessionCount, 3);
    expect(snapshot.trustedKhatmaAnchorCount, 2);
    expect(snapshot.orphanTrustedAnchorCount, 1);
    expect(snapshot.normalizedVisitCount, 4);
    expect(snapshot.totalTrackedMinutes, 45);
    expect(snapshot.totalKhatmaCount, 2);
    expect(snapshot.completedKhatmaCount, 1);
    expect(snapshot.totalReviewItemCount, 2);
    expect(snapshot.reviewedReviewCount, 1);
    expect(snapshot.totalReviewRepetitions, 2);
    expect(snapshot.readingDayCount, 5);
    expect(snapshot.bestReadingStreakDays, 5);
    expect(snapshot.latestActivityAt, DateTime(2026, 3, 23, 11));
  });
}
