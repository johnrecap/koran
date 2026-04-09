import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_policy.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_snapshot.dart';

void main() {
  test('builds a deterministic zero-state achievements summary', () {
    final snapshot = AchievementSnapshotPolicy.build(
      sessions: const <ReadingSession>[],
      khatmas: const <Khatma>[],
      reviewItems: const <SpacedReviewItem>[],
      now: DateTime(2026, 3, 28, 12),
    );

    final summary = AchievementPolicy.build(snapshot);

    expect(summary.totalXp, 0);
    expect(summary.level, 1);
    expect(summary.currentLevelStartXp, 0);
    expect(summary.nextLevelXp, 75);
    expect(summary.unlockedBadgeCount, 0);
    expect(summary.lockedBadgeCount, 12);
    expect(summary.nextBadge?.id, 'first_steps');
    expect(summary.unlocks, isEmpty);
  });

  test('evaluates xp, levels, badges, and records from one snapshot', () {
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

    final summary = AchievementPolicy.build(snapshot);

    expect(summary.totalXp, 270);
    expect(summary.level, 3);
    expect(summary.currentLevelStartXp, 175);
    expect(summary.nextLevelXp, 300);
    expect(summary.progressToNextLevel, closeTo(0.76, 0.001));
    expect(summary.unlockedBadgeCount, 6);
    expect(summary.lockedBadgeCount, 6);
    expect(
      summary.badges
          .where((badge) => badge.isUnlocked)
          .map((badge) => badge.id),
      const [
        'first_steps',
        'focus_minutes',
        'streak_guardian',
        'first_khatma',
        'khatma_builder',
        'review_starter',
      ],
    );
    expect(
      summary.badges
          .where((badge) => !badge.isUnlocked)
          .map((badge) => badge.id),
      const [
        'steady_reader',
        'deep_focus',
        'streak_lighthouse',
        'khatma_finisher',
        'review_keeper',
        'review_archivist',
      ],
    );
    expect(summary.nextBadge?.id, 'steady_reader');
    expect(
      summary.unlocks.map((unlock) => unlock.id),
      const [
        'level:2',
        'level:3',
        'badge:first_steps',
        'badge:focus_minutes',
        'badge:streak_guardian',
        'badge:first_khatma',
        'badge:khatma_builder',
        'badge:review_starter',
      ],
    );

    final bestStreakRecord = summary.records.firstWhere(
      (record) => record.id == 'best_streak_days',
    );
    final trackedMinutesRecord = summary.records.firstWhere(
      (record) => record.id == 'tracked_minutes',
    );
    final completedKhatmasRecord = summary.records.firstWhere(
      (record) => record.id == 'completed_khatmas',
    );

    expect(bestStreakRecord.value, 5);
    expect(trackedMinutesRecord.value, 45);
    expect(completedKhatmasRecord.value, 1);
  });

  test('returns the same summary for repeated evaluation of the same snapshot',
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
      ],
      khatmas: [
        Khatma(
          id: 'k1',
          title: 'Starter Khatma',
          targetDays: 30,
          startDate: DateTime(2026, 3, 1),
          totalReadMinutes: 10,
          readingDayKeys: const ['2026-03-20'],
        ),
      ],
      reviewItems: const <SpacedReviewItem>[],
      now: DateTime(2026, 3, 28, 12),
    );

    final first = AchievementPolicy.build(snapshot);
    final second = AchievementPolicy.build(snapshot);

    expect(second.totalXp, first.totalXp);
    expect(second.level, first.level);
    expect(
      second.badges.map((badge) => '${badge.id}:${badge.isUnlocked}'),
      first.badges.map((badge) => '${badge.id}:${badge.isUnlocked}'),
    );
    expect(
      second.unlocks.map((unlock) => unlock.id),
      first.unlocks.map((unlock) => unlock.id),
    );
    expect(second.nextBadge?.id, first.nextBadge?.id);
  });

  test('returns no next badge once the full catalog is unlocked', () {
    final summary = AchievementPolicy.build(
      AchievementSnapshot(
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
      ),
    );

    expect(summary.unlockedBadgeCount, 12);
    expect(summary.lockedBadgeCount, 0);
    expect(summary.nextBadge, isNull);
  });
}
