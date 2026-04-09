import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test('loads existing khatmas with safe planner defaults', () async {
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
            },
          ],
        ),
      },
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(khatmasProvider.notifier);
    await notifier.ready;

    final khatma = container.read(khatmasProvider).single;
    expect(khatma.startPage, 1);
    expect(khatma.furthestPageRead, 0);
    expect(khatma.totalReadMinutes, 0);
    expect(khatma.readingDayKeys, isEmpty);
  });

  test('records non-regressing planner progress and tracked minutes', () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'khatmas': jsonEncode(
          [
            {
              'id': 'khatma-1',
              'title': 'Weekly Khatma',
              'targetDays': 7,
              'startDate': DateTime(2026, 3, 20).toIso8601String(),
              'completedSurahs': 0,
            },
          ],
        ),
      },
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(khatmasProvider.notifier);
    await notifier.ready;

    await notifier.recordPlannerProgress(
      khatmaId: 'khatma-1',
      pageNumber: 12,
      timestamp: DateTime(2026, 3, 26, 8, 0),
      completedSurahs: 1,
    );
    await notifier.recordPlannerProgress(
      khatmaId: 'khatma-1',
      pageNumber: 8,
      timestamp: DateTime(2026, 3, 26, 9, 0),
      completedSurahs: 1,
    );
    await notifier.addTrackedMinutes(
      khatmaId: 'khatma-1',
      minutes: 18,
    );

    final khatma = container.read(khatmasProvider).single;
    expect(khatma.furthestPageRead, 12);
    expect(khatma.totalReadMinutes, 18);
    expect(khatma.readingDayKeys, const ['2026-03-26']);
    expect(khatma.completedSurahs, 1);
  });

  test('sanitizes phantom khatma progress without trusted reading evidence',
      () async {
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
              'completedSurahs': 4,
              'startPage': 1,
              'furthestPageRead': 80,
              'totalReadMinutes': 0,
              'readingDayKeys': ['2026-03-26'],
            },
          ],
        ),
      },
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(khatmasProvider.notifier).ready;
    await container.read(sessionsProvider.notifier).ready;

    final activeKhatma = container.read(activeKhatmaProvider);
    final plannerSummary =
        container.read(khatmaPlannerSummaryProvider('khatma-1'));

    expect(activeKhatma, isNotNull);
    expect(activeKhatma!.furthestPageRead, 0);
    expect(activeKhatma.completedSurahs, 0);
    expect(activeKhatma.readingDayKeys, isEmpty);

    expect(plannerSummary, isNotNull);
    expect(plannerSummary!.latestSession, isNull);
    expect(plannerSummary.nextPageToRead, 1);
    expect(plannerSummary.furthestPageRead, 0);
  });

  test('persists repaired phantom progress before later trusted saves',
      () async {
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
              'completedSurahs': 4,
              'startPage': 1,
              'furthestPageRead': 80,
              'totalReadMinutes': 0,
              'readingDayKeys': ['2026-03-26'],
            },
          ],
        ),
      },
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(khatmasProvider.notifier).ready;
    await container.read(sessionsProvider.notifier).ready;

    expect(container.read(activeKhatmaProvider)!.furthestPageRead, 0);

    await container.read(sessionsProvider.notifier).upsertSession(
          ReadingSession(
            id: 'khatma-khatma-1',
            surahNumber: 1,
            ayahNumber: 2,
            surahName: 'Al-Fatihah',
            timestamp: DateTime(2026, 3, 27, 8, 0),
            khatmaId: 'khatma-1',
            isTrustedKhatmaAnchor: true,
          ),
        );
    await container.read(khatmasProvider.notifier).recordPlannerProgress(
          khatmaId: 'khatma-1',
          pageNumber: 2,
          timestamp: DateTime(2026, 3, 27, 8, 0),
          completedSurahs: 1,
        );

    final repairedKhatma = container.read(khatmasProvider).single;
    expect(repairedKhatma.furthestPageRead, 2);
    expect(repairedKhatma.completedSurahs, 1);
    expect(repairedKhatma.readingDayKeys, const ['2026-03-27']);

    final activeKhatma = container.read(activeKhatmaProvider);
    expect(activeKhatma, isNotNull);
    expect(activeKhatma!.furthestPageRead, 2);
  });

  test('reopens a phantom completed khatma as active after sanitize', () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'readingSessions': jsonEncode(
          [
            ReadingSession(
              id: 'legacy-khatma-session',
              surahNumber: 114,
              ayahNumber: 6,
              surahName: 'An-Nas',
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
              'completedDate': DateTime(2026, 3, 26, 9, 0).toIso8601String(),
              'completedSurahs': 114,
              'startPage': 1,
              'furthestPageRead': 604,
              'totalReadMinutes': 0,
              'readingDayKeys': ['2026-03-26'],
            },
          ],
        ),
      },
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(khatmasProvider.notifier).ready;
    await container.read(sessionsProvider.notifier).ready;

    final activeKhatma = container.read(activeKhatmaProvider);
    final repairedKhatma = container.read(khatmaByIdProvider('khatma-1'));

    expect(activeKhatma, isNotNull);
    expect(activeKhatma!.id, 'khatma-1');
    expect(activeKhatma.isCompleted, isFalse);
    expect(activeKhatma.furthestPageRead, 0);
    expect(activeKhatma.completedSurahs, 0);
    expect(repairedKhatma, isNotNull);
    expect(repairedKhatma!.isCompleted, isFalse);
  });
}
