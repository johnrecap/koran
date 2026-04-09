import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/reader/domain/reader_session_intent.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test(
      'reader save recorder keeps default saves regular and does not pollute an active khatma',
      () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'khatmas': jsonEncode(
          [
            Khatma(
              id: 'khatma-1',
              title: 'Weekly Khatma',
              targetDays: 7,
              startDate: DateTime(2026, 3, 20),
            ).toMap(),
          ],
        ),
      },
    );
    UserPreferences.resetCache();

    final container = ProviderContainer(
      overrides: [
        surahsProvider.overrideWith(
          (ref) async => const [
            Surah(
              number: 2,
              nameArabic: 'البقرة',
              nameEnglish: 'Al-Baqarah',
              nameTransliteration: 'Al-Baqarah',
              ayahCount: 286,
              revelationType: 'Medinan',
              page: 2,
            ),
          ],
        ),
      ],
    );
    addTearDown(() {
      container.dispose();
      UserPreferences.resetCache();
    });

    final recorder = container.read(readerSaveRecorderProvider);
    await recorder.record(
      sessionId: 'visit-1',
      surahNumber: 2,
      ayahNumber: 5,
      page: 2,
    );
    await recorder.record(
      sessionId: 'visit-1',
      surahNumber: 2,
      ayahNumber: 255,
      page: 42,
    );

    final savedPosition =
        await container.read(lastReadingPositionProvider.future);
    final sessions = container.read(sessionsProvider);

    expect(savedPosition, isNotNull);
    expect(savedPosition!.surahNumber, 2);
    expect(savedPosition.ayahNumber, 255);
    expect(savedPosition.page, 42);

    expect(sessions.where((session) => session.khatmaId == null), hasLength(1));
    expect(
      sessions.where((session) => session.khatmaId == 'khatma-1'),
      isEmpty,
    );

    final regularSession =
        sessions.singleWhere((session) => session.khatmaId == null);
    expect(regularSession.id, 'visit-1');
    expect(regularSession.surahName, 'البقرة');
    expect(regularSession.ayahNumber, 255);

    await container.read(khatmasProvider.notifier).ready;
    final khatma = container.read(khatmasProvider).single;
    expect(khatma.furthestPageRead, 0);
    expect(khatma.readingDayKeys, isEmpty);
  });

  test(
      'reader save recorder tracks khatma progress only after an explicit khatma commit',
      () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'khatmas': jsonEncode(
          [
            Khatma(
              id: 'khatma-1',
              title: 'Weekly Khatma',
              targetDays: 7,
              startDate: DateTime(2026, 3, 20),
            ).toMap(),
          ],
        ),
      },
    );
    UserPreferences.resetCache();

    final container = ProviderContainer(
      overrides: [
        surahsProvider.overrideWith(
          (ref) async => const [
            Surah(
              number: 2,
              nameArabic: 'ط§ظ„ط¨ظ‚ط±ط©',
              nameEnglish: 'Al-Baqarah',
              nameTransliteration: 'Al-Baqarah',
              ayahCount: 286,
              revelationType: 'Medinan',
              page: 2,
            ),
          ],
        ),
        readerSessionIntentProvider.overrideWith(
          (ref) => const ReaderSessionIntent.khatma('khatma-1'),
        ),
      ],
    );
    addTearDown(() {
      container.dispose();
      UserPreferences.resetCache();
    });

    final recorder = container.read(readerSaveRecorderProvider);
    await recorder.record(
      sessionId: 'visit-3',
      surahNumber: 2,
      ayahNumber: 5,
      page: 2,
      allowKhatmaTracking: false,
    );

    await container.read(khatmasProvider.notifier).ready;
    var sessions = container.read(sessionsProvider);
    var khatma = container.read(khatmasProvider).single;

    expect(sessions.where((session) => session.khatmaId == null), hasLength(1));
    expect(sessions.where((session) => session.khatmaId == 'khatma-1'), isEmpty);
    expect(khatma.furthestPageRead, 0);

    await recorder.record(
      sessionId: 'visit-3',
      surahNumber: 2,
      ayahNumber: 255,
      page: 42,
      allowKhatmaTracking: true,
    );

    sessions = container.read(sessionsProvider);
    khatma = container.read(khatmasProvider).single;

    expect(sessions.where((session) => session.khatmaId == null), hasLength(1));
    expect(
      sessions.where((session) => session.khatmaId == 'khatma-1'),
      hasLength(1),
    );
    expect(
      sessions
          .singleWhere((session) => session.khatmaId == 'khatma-1')
          .isTrustedKhatmaAnchor,
      isTrue,
    );
    expect(khatma.furthestPageRead, 42);
    expect(khatma.readingDayKeys, isNotEmpty);
  });

  test('reader save recorder falls back to numeric surah name without khatma',
      () async {
    final container = ProviderContainer(
      overrides: [
        surahsProvider.overrideWith(
          (ref) async => const <Surah>[],
        ),
      ],
    );
    addTearDown(() {
      container.dispose();
      UserPreferences.resetCache();
    });

    await container.read(readerSaveRecorderProvider).record(
          sessionId: 'visit-2',
          surahNumber: 36,
          ayahNumber: 1,
          page: 440,
        );

    final sessions = container.read(sessionsProvider);
    expect(sessions, hasLength(1));
    expect(sessions.single.surahName, '36');
    expect(sessions.single.khatmaId, isNull);
  });
}
