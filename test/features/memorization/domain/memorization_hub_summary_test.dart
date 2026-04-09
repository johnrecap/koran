import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/domain/memorization_hub_summary.dart';

void main() {
  test('builds the hub summary from khatma, session, and bookmark inputs', () {
    final summary = MemorizationHubSummaryPolicy.build(
      sessions: [
        ReadingSession(
          id: 'regular-old',
          surahNumber: 3,
          ayahNumber: 18,
          surahName: 'Ali Imran',
          timestamp: DateTime(2026, 3, 20, 8, 0),
        ),
        ReadingSession(
          id: 'khatma-old',
          surahNumber: 2,
          ayahNumber: 120,
          surahName: 'Al-Baqarah',
          timestamp: DateTime(2026, 3, 21, 8, 0),
          khatmaId: 'khatma-1',
          isTrustedKhatmaAnchor: true,
        ),
        ReadingSession(
          id: 'regular-new',
          surahNumber: 4,
          ayahNumber: 12,
          surahName: 'An-Nisa',
          timestamp: DateTime(2026, 3, 24, 9, 0),
        ),
        ReadingSession(
          id: 'khatma-new',
          surahNumber: 2,
          ayahNumber: 255,
          surahName: 'Al-Baqarah',
          timestamp: DateTime(2026, 3, 25, 9, 0),
          khatmaId: 'khatma-1',
          isTrustedKhatmaAnchor: true,
        ),
      ],
      khatmas: [
        Khatma(
          id: 'khatma-1',
          title: 'Weekly Khatma',
          targetDays: 7,
          startDate: DateTime(2026, 3, 20),
          completedSurahs: 2,
        ),
        Khatma(
          id: 'khatma-2',
          title: 'Finished Khatma',
          targetDays: 10,
          startDate: DateTime(2026, 3, 1),
          completedDate: DateTime(2026, 3, 11),
          completedSurahs: 114,
        ),
      ],
      manualBookmarkCount: 3,
    );

    expect(summary.activeKhatma?.id, 'khatma-1');
    expect(summary.activeKhatmaSession?.id, 'khatma-new');
    expect(
      summary.recentRegularSessions.map((session) => session.id),
      ['regular-new', 'regular-old'],
    );
    expect(summary.activeKhatmaCount, 1);
    expect(summary.completedKhatmas, hasLength(1));
    expect(summary.manualBookmarkCount, 3);
  });
}
