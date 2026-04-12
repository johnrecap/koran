import 'package:quran_kareem/features/analytics/domain/analytics_period_snapshot.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_snapshot.dart';
import 'package:quran_kareem/features/memorization/domain/khatma_planner_summary.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_day_tracking.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';

abstract final class AnalyticsPeriodPolicy {
  static AnalyticsPeriodSnapshot build({
    required AnalyticsPeriodType type,
    required AnalyticsDateRange range,
    required List<ReadingSession> sessions,
    required List<Khatma> khatmas,
    required List<SpacedReviewItem> reviewItems,
    required AchievementSnapshot achievementSnapshot,
    required Map<String, PrayerDayTracking> prayerTrackingsByDayKey,
    required Map<String, int> sessionPageById,
  }) {
    final filteredSessions = sessions.where(range.containsSession).toList()
      ..sort((first, second) => second.timestamp.compareTo(first.timestamp));
    final normalizedVisits = _buildNormalizedVisits(
      filteredSessions,
      sessionPageById: sessionPageById,
    );
    final periodSnapshot = AchievementSnapshotPolicy.build(
      sessions: filteredSessions,
      khatmas: _buildSyntheticKhatmas(filteredSessions),
      reviewItems: const <SpacedReviewItem>[],
      now: range.endInclusive,
    );

    final topSurahs = _buildTopSurahs(normalizedVisits);
    final pagesVisitedCount = normalizedVisits
        .map((visit) => visit.pageNumber)
        .whereType<int>()
        .toSet()
        .length;

    final activeKhatmas = _buildActiveKhatmasForPeriod(
      khatmas: khatmas,
      range: range,
    );
    final completedReviewsCount = reviewItems
        .where((item) => item.lastReviewedAt != null)
        .where((item) => range.contains(item.lastReviewedAt!))
        .length;
    final reviewDueItems =
        reviewItems.where((item) => range.contains(item.nextReviewAt)).toList();
    final completedDueReviewCount = reviewDueItems
        .where(
          (item) =>
              item.lastReviewedAt != null &&
              !item.lastReviewedAt!.isAfter(range.endInclusive),
        )
        .length;
    final overdueReviewCount = reviewDueItems.length - completedDueReviewCount;
    final reviewAdherenceRate = reviewDueItems.isEmpty
        ? null
        : completedDueReviewCount / reviewDueItems.length;

    final prayerTrackings = [
      for (final dayKey in range.dayKeys)
        prayerTrackingsByDayKey[dayKey] ??
            PrayerDayTracking(
              dateKey: dayKey,
              completedPrayers: const <PrayerType>{},
            ),
    ];
    final completedPrayersCount = prayerTrackings.fold<int>(
      0,
      (sum, tracking) => sum + tracking.completedPrayers.length,
    );
    final trackedDaysCount = prayerTrackings
        .where((tracking) => tracking.completedPrayers.isNotEmpty)
        .length;
    final prayerCompletionRate = trackedDaysCount == 0
        ? null
        : completedPrayersCount / (range.dayCount * PrayerType.values.length);

    return AnalyticsPeriodSnapshot(
      type: type,
      range: range,
      reading: AnalyticsReadingMetrics(
        totalMinutes: periodSnapshot.totalTrackedMinutes,
        normalizedVisitCount: periodSnapshot.normalizedVisitCount,
        pagesVisitedCount: pagesVisitedCount,
        readingDaysCount: periodSnapshot.readingDayCount,
        averageDailyMinutes: range.dayCount == 0
            ? 0
            : periodSnapshot.totalTrackedMinutes / range.dayCount,
        currentStreakDays: achievementSnapshot.currentReadingStreakDays,
        topSurahs: topSurahs,
      ),
      memorization: AnalyticsMemorizationMetrics(
        activeKhatmas: activeKhatmas,
        completedReviewsCount: completedReviewsCount,
        reviewDueCount: reviewDueItems.length,
        overdueReviewCount: overdueReviewCount,
        reviewAdherenceRate: reviewAdherenceRate,
      ),
      prayer: AnalyticsPrayerMetrics(
        completedPrayersCount: completedPrayersCount,
        totalPossiblePrayersCount: range.dayCount * PrayerType.values.length,
        perfectDaysCount:
            prayerTrackings.where((tracking) => tracking.isComplete).length,
        trackedDaysCount: trackedDaysCount,
        completionRate: prayerCompletionRate,
      ),
    );
  }

  static List<AnalyticsTopSurahStat> _buildTopSurahs(
    List<_NormalizedAnalyticsVisit> visits,
  ) {
    final counts = <int, AnalyticsTopSurahStat>{};

    for (final visit in visits) {
      if (visit.surahNumber <= 0 || visit.surahName.trim().isEmpty) {
        continue;
      }

      final current = counts[visit.surahNumber];
      counts[visit.surahNumber] = AnalyticsTopSurahStat(
        surahNumber: visit.surahNumber,
        surahName: visit.surahName,
        visitCount: (current?.visitCount ?? 0) + 1,
      );
    }

    final topSurahs = counts.values.toList()
      ..sort((first, second) {
        final visitCountComparison =
            second.visitCount.compareTo(first.visitCount);
        if (visitCountComparison != 0) {
          return visitCountComparison;
        }

        return first.surahNumber.compareTo(second.surahNumber);
      });

    return topSurahs.take(5).toList(growable: false);
  }

  static List<AnalyticsKhatmaProgress> _buildActiveKhatmasForPeriod({
    required List<Khatma> khatmas,
    required AnalyticsDateRange range,
  }) {
    return khatmas
        .where((khatma) => !khatma.isCompleted)
        .where((khatma) => khatma.startDate.isBefore(range.endExclusive))
        .map(
          (khatma) => AnalyticsKhatmaProgress(
            id: khatma.id,
            title: khatma.title,
            progress: khatma.progress,
            furthestPageRead: khatma.furthestPageRead,
            totalReadMinutes: khatma.totalReadMinutes,
          ),
        )
        .toList(growable: false);
  }

  static List<Khatma> _buildSyntheticKhatmas(List<ReadingSession> sessions) {
    final totalsByKhatmaId = <String, int>{};
    final readingDayKeysByKhatmaId = <String, Set<String>>{};

    for (final session in sessions) {
      final khatmaId = session.khatmaId;
      if (khatmaId == null || !session.isTrustedKhatmaAnchor) {
        continue;
      }

      totalsByKhatmaId[khatmaId] =
          (totalsByKhatmaId[khatmaId] ?? 0) + session.durationMinutes;
      readingDayKeysByKhatmaId.putIfAbsent(khatmaId, () => <String>{}).add(
            KhatmaPlannerSummaryPolicy.dayKey(session.timestamp),
          );
    }

    return [
      for (final entry in totalsByKhatmaId.entries)
        Khatma(
          id: entry.key,
          title: entry.key,
          targetDays: 1,
          startDate: DateTime(1970),
          totalReadMinutes: entry.value,
          readingDayKeys:
              (readingDayKeysByKhatmaId[entry.key] ?? const <String>{}).toList()
                ..sort(),
        ),
    ];
  }

  static List<_NormalizedAnalyticsVisit> _buildNormalizedVisits(
    List<ReadingSession> sessions, {
    required Map<String, int> sessionPageById,
  }) {
    final sortedSessions = [...sessions]
      ..sort((first, second) => second.timestamp.compareTo(first.timestamp));
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

    return <_NormalizedAnalyticsVisit>[
      for (final session in regularSessions)
        _NormalizedAnalyticsVisit(
          sourceSessionId: session.id,
          timestamp: session.timestamp,
          durationMinutes: session.durationMinutes,
          surahNumber: session.surahNumber,
          surahName: session.surahName,
          pageNumber: sessionPageById[session.id],
          isKhatmaOwned:
              trustedAnchorByVisitKey.containsKey(_visitKey(session)),
          khatmaId: trustedAnchorByVisitKey[_visitKey(session)]?.khatmaId,
        ),
      for (final anchor in orphanTrustedAnchors)
        _NormalizedAnalyticsVisit(
          sourceSessionId: anchor.id,
          timestamp: anchor.timestamp,
          durationMinutes: anchor.durationMinutes,
          surahNumber: anchor.surahNumber,
          surahName: anchor.surahName,
          pageNumber: sessionPageById[anchor.id],
          isKhatmaOwned: true,
          khatmaId: anchor.khatmaId,
        ),
    ]..sort((first, second) => second.timestamp.compareTo(first.timestamp));
  }

  static String _visitKey(ReadingSession session) {
    return [
      session.timestamp.toIso8601String(),
      session.surahNumber,
      session.ayahNumber,
    ].join('|');
  }
}

extension on AnalyticsDateRange {
  bool containsSession(ReadingSession session) => contains(session.timestamp);
}

class _NormalizedAnalyticsVisit {
  const _NormalizedAnalyticsVisit({
    required this.sourceSessionId,
    required this.timestamp,
    required this.durationMinutes,
    required this.surahNumber,
    required this.surahName,
    required this.pageNumber,
    required this.isKhatmaOwned,
    required this.khatmaId,
  });

  final String sourceSessionId;
  final DateTime timestamp;
  final int durationMinutes;
  final int surahNumber;
  final String surahName;
  final int? pageNumber;
  final bool isKhatmaOwned;
  final String? khatmaId;
}
