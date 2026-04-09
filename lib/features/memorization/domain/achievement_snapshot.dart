import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/domain/khatma_planner_summary.dart';

class AchievementVisit {
  const AchievementVisit({
    required this.timestamp,
    required this.durationMinutes,
    required this.isKhatmaOwned,
    this.khatmaId,
  });

  final DateTime timestamp;
  final int durationMinutes;
  final bool isKhatmaOwned;
  final String? khatmaId;
}

class AchievementSnapshot {
  const AchievementSnapshot({
    required this.rawSessionCount,
    required this.regularSessionCount,
    required this.trustedKhatmaAnchorCount,
    required this.orphanTrustedAnchorCount,
    required this.normalizedVisitCount,
    required this.generalVisitCount,
    required this.khatmaVisitCount,
    required this.totalTrackedMinutes,
    required this.totalKhatmaCount,
    required this.completedKhatmaCount,
    required this.totalReviewItemCount,
    required this.reviewedReviewCount,
    required this.totalReviewRepetitions,
    required this.readingDayCount,
    required this.currentReadingStreakDays,
    required this.bestReadingStreakDays,
    required this.latestActivityAt,
    required this.normalizedVisits,
    required this.readingDayKeys,
    required this.khatmas,
    required this.reviewItems,
  });

  final int rawSessionCount;
  final int regularSessionCount;
  final int trustedKhatmaAnchorCount;
  final int orphanTrustedAnchorCount;
  final int normalizedVisitCount;
  final int generalVisitCount;
  final int khatmaVisitCount;
  final int totalTrackedMinutes;
  final int totalKhatmaCount;
  final int completedKhatmaCount;
  final int totalReviewItemCount;
  final int reviewedReviewCount;
  final int totalReviewRepetitions;
  final int readingDayCount;
  final int currentReadingStreakDays;
  final int bestReadingStreakDays;
  final DateTime? latestActivityAt;
  final List<AchievementVisit> normalizedVisits;
  final List<String> readingDayKeys;
  final List<Khatma> khatmas;
  final List<SpacedReviewItem> reviewItems;

  bool get hasActivity =>
      normalizedVisitCount > 0 ||
      totalKhatmaCount > 0 ||
      totalReviewItemCount > 0;
}

abstract final class AchievementSnapshotPolicy {
  static AchievementSnapshot build({
    required List<ReadingSession> sessions,
    required List<Khatma> khatmas,
    required List<SpacedReviewItem> reviewItems,
    required DateTime now,
  }) {
    final sortedSessions = [...sessions]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final regularSessions =
        sortedSessions.where((session) => session.khatmaId == null).toList();
    final trustedAnchors = sortedSessions
        .where(
          (session) =>
              session.khatmaId != null && session.isTrustedKhatmaAnchor,
        )
        .toList();

    final trustedAnchorByVisitKey = <String, ReadingSession>{
      for (final anchor in trustedAnchors) _visitKey(anchor): anchor,
    };
    final regularVisitKeys = regularSessions.map(_visitKey).toSet();
    final orphanTrustedAnchors = trustedAnchors
        .where((anchor) => !regularVisitKeys.contains(_visitKey(anchor)))
        .toList();

    final normalizedVisits = <AchievementVisit>[
      for (final session in regularSessions)
        AchievementVisit(
          timestamp: session.timestamp,
          durationMinutes: session.durationMinutes,
          isKhatmaOwned:
              trustedAnchorByVisitKey.containsKey(_visitKey(session)),
          khatmaId: trustedAnchorByVisitKey[_visitKey(session)]?.khatmaId,
        ),
      for (final anchor in orphanTrustedAnchors)
        AchievementVisit(
          timestamp: anchor.timestamp,
          durationMinutes: anchor.durationMinutes,
          isKhatmaOwned: true,
          khatmaId: anchor.khatmaId,
        ),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final khatmaById = <String, Khatma>{
      for (final khatma in khatmas) khatma.id: khatma,
    };
    final fallbackOrphanMinutes = orphanTrustedAnchors.fold<int>(
      0,
      (sum, anchor) {
        final khatma = khatmaById[anchor.khatmaId];
        if (khatma == null || khatma.totalReadMinutes <= 0) {
          return sum + anchor.durationMinutes;
        }

        return sum;
      },
    );

    final nonKhatmaRegularMinutes = regularSessions.fold<int>(
      0,
      (sum, session) {
        if (trustedAnchorByVisitKey.containsKey(_visitKey(session))) {
          return sum;
        }

        return sum + session.durationMinutes;
      },
    );

    final totalTrackedMinutes = nonKhatmaRegularMinutes +
        khatmas.fold<int>(
          0,
          (sum, khatma) => sum + khatma.totalReadMinutes,
        ) +
        fallbackOrphanMinutes;

    final readingDayKeys = <String>{
      for (final session in sortedSessions)
        KhatmaPlannerSummaryPolicy.dayKey(session.timestamp),
      for (final khatma in khatmas) ...khatma.readingDayKeys,
    }.toList()
      ..sort();

    final khatmaVisitCount =
        normalizedVisits.where((visit) => visit.isKhatmaOwned).length;
    final reviewedReviewCount = reviewItems
        .where(
          (item) => item.lastReviewedAt != null || item.repetitionCount > 0,
        )
        .length;

    return AchievementSnapshot(
      rawSessionCount: sortedSessions.length,
      regularSessionCount: regularSessions.length,
      trustedKhatmaAnchorCount: trustedAnchors.length,
      orphanTrustedAnchorCount: orphanTrustedAnchors.length,
      normalizedVisitCount: normalizedVisits.length,
      generalVisitCount: normalizedVisits.length - khatmaVisitCount,
      khatmaVisitCount: khatmaVisitCount,
      totalTrackedMinutes: totalTrackedMinutes,
      totalKhatmaCount: khatmas.length,
      completedKhatmaCount:
          khatmas.where((khatma) => khatma.isCompleted).length,
      totalReviewItemCount: reviewItems.length,
      reviewedReviewCount: reviewedReviewCount,
      totalReviewRepetitions: reviewItems.fold<int>(
        0,
        (sum, item) => sum + item.repetitionCount,
      ),
      readingDayCount: readingDayKeys.length,
      currentReadingStreakDays: _currentStreakDays(readingDayKeys, now: now),
      bestReadingStreakDays: _bestStreakDays(readingDayKeys),
      latestActivityAt:
          sortedSessions.isEmpty ? null : sortedSessions.first.timestamp,
      normalizedVisits: normalizedVisits,
      readingDayKeys: readingDayKeys,
      khatmas: [...khatmas],
      reviewItems: [...reviewItems],
    );
  }

  static String _visitKey(ReadingSession session) {
    return [
      session.timestamp.toIso8601String(),
      session.surahNumber,
      session.ayahNumber,
    ].join('|');
  }

  static int _currentStreakDays(
    List<String> readingDayKeys, {
    required DateTime now,
  }) {
    if (readingDayKeys.isEmpty) {
      return 0;
    }

    final days = readingDayKeys.toSet();
    var streak = 0;
    var cursor = DateTime(now.year, now.month, now.day);

    while (days.contains(KhatmaPlannerSummaryPolicy.dayKey(cursor))) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static int _bestStreakDays(List<String> readingDayKeys) {
    if (readingDayKeys.isEmpty) {
      return 0;
    }

    final dates = [
      for (final dayKey in readingDayKeys) DateTime.parse(dayKey),
    ]..sort((a, b) => a.compareTo(b));

    var best = 1;
    var current = 1;

    for (var index = 1; index < dates.length; index += 1) {
      final previous = dates[index - 1];
      final currentDate = dates[index];
      final difference = currentDate.difference(previous).inDays;

      if (difference == 1) {
        current += 1;
      } else {
        current = 1;
      }

      if (current > best) {
        best = current;
      }
    }

    return best;
  }
}
