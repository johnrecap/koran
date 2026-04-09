import 'dart:math' as math;

import 'package:quran_kareem/features/memorization/data/reading_session.dart';

class KhatmaPlannerSummary {
  const KhatmaPlannerSummary({
    required this.khatma,
    required this.latestSession,
    required this.furthestPageRead,
    required this.nextPageToRead,
    required this.assignmentStartPage,
    required this.assignmentEndPage,
    required this.pagesPerDay,
    required this.expectedPageToday,
    required this.remainingPages,
    required this.streakDays,
    required this.totalReadMinutes,
    required this.isOnTrack,
  });

  final Khatma khatma;
  final ReadingSession? latestSession;
  final int furthestPageRead;
  final int nextPageToRead;
  final int assignmentStartPage;
  final int assignmentEndPage;
  final int pagesPerDay;
  final int expectedPageToday;
  final int remainingPages;
  final int streakDays;
  final int totalReadMinutes;
  final bool isOnTrack;

  double get progress => khatma.progress;
}

abstract final class KhatmaPlannerSummaryPolicy {
  static KhatmaPlannerSummary build({
    required Khatma khatma,
    required ReadingSession? latestSession,
    DateTime Function()? now,
  }) {
    final currentTime = (now ?? DateTime.now)();
    final pagesPerDay =
        math.max(1, (Khatma.mushafPageCount / khatma.targetDays).ceil());
    final furthestPageRead = khatma.furthestPageRead.clamp(
      0,
      Khatma.mushafPageCount,
    );
    final nextPageToRead = furthestPageRead >= Khatma.mushafPageCount
        ? Khatma.mushafPageCount
        : math.max(khatma.startPage, furthestPageRead + 1);
    final assignmentStartPage = nextPageToRead;
    final assignmentEndPage = math.min(
      assignmentStartPage + pagesPerDay - 1,
      Khatma.mushafPageCount,
    );
    final dayIndex =
        math.max(1, currentTime.difference(khatma.startDate).inDays + 1);
    final expectedPageToday = math.min(
      khatma.startPage - 1 + (dayIndex * pagesPerDay),
      Khatma.mushafPageCount,
    );

    return KhatmaPlannerSummary(
      khatma: khatma,
      latestSession: latestSession,
      furthestPageRead: furthestPageRead,
      nextPageToRead: nextPageToRead,
      assignmentStartPage: assignmentStartPage,
      assignmentEndPage: assignmentEndPage,
      pagesPerDay: pagesPerDay,
      expectedPageToday: expectedPageToday,
      remainingPages: math.max(0, Khatma.mushafPageCount - furthestPageRead),
      streakDays: _calculateStreakDays(
        khatma.readingDayKeys,
        now: currentTime,
      ),
      totalReadMinutes: khatma.totalReadMinutes,
      isOnTrack: furthestPageRead >= expectedPageToday || khatma.isCompleted,
    );
  }

  static int _calculateStreakDays(
    List<String> readingDayKeys, {
    required DateTime now,
  }) {
    if (readingDayKeys.isEmpty) {
      return 0;
    }

    final days = readingDayKeys.toSet();
    var streak = 0;
    var cursor = DateTime(now.year, now.month, now.day);

    while (days.contains(_dayKey(cursor))) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static String dayKey(DateTime timestamp) => _dayKey(timestamp);

  static String _dayKey(DateTime timestamp) {
    final normalized = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$day';
  }
}
