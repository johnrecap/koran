import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/providers/achievements_providers.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/memorization/providers/spaced_review_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test(
      'derives the achievements summary and pending unlocks from app providers',
      () async {
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
        'achievementAcknowledgements': jsonEncode(
          ['level:2', 'badge:first_steps'],
        ),
      },
    );

    final container = ProviderContainer(
      overrides: [
        achievementsNowProvider.overrideWith(
          (ref) => () => DateTime(2026, 3, 28, 12),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sessionsProvider.notifier).ready;
    await container.read(khatmasProvider.notifier).ready;
    await container.read(spacedReviewItemsProvider.notifier).ready;
    await container.read(achievementsAcknowledgementsProvider.notifier).ready;

    final summary = container.read(achievementsSummaryProvider);
    final pendingUnlocks = container.read(achievementsPendingUnlocksProvider);

    expect(summary.totalXp, 310);
    expect(summary.level, 4);
    expect(summary.completedKhatmas, 2);
    expect(summary.totalTrackedMinutes, 45);
    expect(
      pendingUnlocks.map((unlock) => unlock.id),
      const [
        'level:3',
        'level:4',
        'badge:focus_minutes',
        'badge:first_khatma',
        'badge:khatma_builder',
        'badge:review_starter',
      ],
    );
  });

  test('acknowledges pending unlocks and persists them across provider reloads',
      () async {
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
              readingDayKeys: const ['2026-03-20'],
            ).toMap(),
          ],
        ),
      },
    );

    ProviderContainer buildContainer() {
      return ProviderContainer(
        overrides: [
          achievementsNowProvider.overrideWith(
            (ref) => () => DateTime(2026, 3, 28, 12),
          ),
        ],
      );
    }

    final firstContainer = buildContainer();
    addTearDown(firstContainer.dispose);

    await firstContainer.read(sessionsProvider.notifier).ready;
    await firstContainer.read(khatmasProvider.notifier).ready;
    await firstContainer.read(spacedReviewItemsProvider.notifier).ready;
    final notifier =
        firstContainer.read(achievementsAcknowledgementsProvider.notifier);
    await notifier.ready;

    final pendingBefore =
        firstContainer.read(achievementsPendingUnlocksProvider);
    expect(pendingBefore, isNotEmpty);

    await notifier.acknowledgeAll(
      pendingBefore.map((unlock) => unlock.id),
    );

    expect(firstContainer.read(achievementsPendingUnlocksProvider), isEmpty);

    final prefs = await UserPreferences.prefs;
    expect(prefs.getString('achievementAcknowledgements'), isNotNull);

    firstContainer.dispose();
    UserPreferences.resetCache();

    final secondContainer = buildContainer();
    addTearDown(secondContainer.dispose);

    await secondContainer.read(sessionsProvider.notifier).ready;
    await secondContainer.read(khatmasProvider.notifier).ready;
    await secondContainer.read(spacedReviewItemsProvider.notifier).ready;
    await secondContainer
        .read(achievementsAcknowledgementsProvider.notifier)
        .ready;

    expect(secondContainer.read(achievementsPendingUnlocksProvider), isEmpty);
  });
}
