import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/domain/khatma_planner_summary.dart';

void main() {
  test('builds a page-based khatma planner summary with assignment and streak',
      () {
    final summary = KhatmaPlannerSummaryPolicy.build(
      khatma: Khatma(
        id: 'khatma-1',
        title: 'Monthly Khatma',
        targetDays: 30,
        startDate: DateTime(2026, 3, 1),
        furthestPageRead: 40,
        totalReadMinutes: 125,
        readingDayKeys: const [
          '2026-03-24',
          '2026-03-25',
          '2026-03-26',
        ],
      ),
      latestSession: ReadingSession(
        id: 'khatma-khatma-1',
        surahNumber: 2,
        ayahNumber: 255,
        surahName: 'Al-Baqarah',
        timestamp: DateTime(2026, 3, 26, 9, 0),
        khatmaId: 'khatma-1',
      ),
      now: () => DateTime(2026, 3, 26, 12, 0),
    );

    expect(summary.furthestPageRead, 40);
    expect(summary.nextPageToRead, 41);
    expect(summary.assignmentStartPage, 41);
    expect(summary.assignmentEndPage, 61);
    expect(summary.pagesPerDay, 21);
    expect(summary.streakDays, 3);
    expect(summary.totalReadMinutes, 125);
    expect(summary.remainingPages, 564);
  });
}
