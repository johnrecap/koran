import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_dashboard_summary.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_period_policy.dart';
import 'package:quran_kareem/features/analytics/domain/analytics_period_snapshot.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/providers/achievements_providers.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/memorization/providers/spaced_review_providers.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';

final analyticsNowProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final analyticsPeriodTypeProvider = StateProvider<AnalyticsPeriodType>(
  (ref) => AnalyticsPeriodType.thisWeek,
);

final analyticsDashboardSummaryProvider =
    FutureProvider<AnalyticsDashboardSummary>((ref) async {
  final periodType = ref.watch(analyticsPeriodTypeProvider);
  final now = ref.watch(analyticsNowProvider)();
  final currentRange = periodType.currentRange(now);
  final previousRange = periodType.previousRange(now);
  final sessions = ref.watch(sessionsProvider);
  final khatmas = ref.watch(effectiveKhatmasProvider);
  final reviewItems = ref.watch(spacedReviewItemsProvider);
  final achievementSnapshot = ref.watch(achievementsSnapshotProvider);
  final prayerTrackingLocalDataSource =
      ref.watch(prayerTrackingLocalDataSourceProvider);
  final resolveAyahPage = ref.watch(memorizationAyahPageResolverProvider);

  final prayerTrackingsByDayKey =
      await prayerTrackingLocalDataSource.loadTrackings(
    [
      ...currentRange.dayKeys,
      ...previousRange.dayKeys,
    ],
  );

  final relevantSessions = sessions.where((session) {
    return currentRange.contains(session.timestamp) ||
        previousRange.contains(session.timestamp);
  }).toList();
  final sessionPageById = await _resolveSessionPages(
    relevantSessions,
    resolveAyahPage,
  );

  final currentSnapshot = AnalyticsPeriodPolicy.build(
    type: periodType,
    range: currentRange,
    sessions: sessions,
    khatmas: khatmas,
    reviewItems: reviewItems,
    achievementSnapshot: achievementSnapshot,
    prayerTrackingsByDayKey: prayerTrackingsByDayKey,
    sessionPageById: sessionPageById,
  );
  final previousSnapshot = AnalyticsPeriodPolicy.build(
    type: periodType,
    range: previousRange,
    sessions: sessions,
    khatmas: khatmas,
    reviewItems: reviewItems,
    achievementSnapshot: achievementSnapshot,
    prayerTrackingsByDayKey: prayerTrackingsByDayKey,
    sessionPageById: sessionPageById,
  );

  return AnalyticsDashboardSummaryPolicy.build(
    periodType: periodType,
    current: currentSnapshot,
    previous: previousSnapshot,
  );
});

Future<Map<String, int>> _resolveSessionPages(
  List<ReadingSession> sessions,
  MemorizationAyahPageResolver resolveAyahPage,
) async {
  if (sessions.isEmpty) {
    return const <String, int>{};
  }

  final entries = await Future.wait(
    sessions.map((session) async {
      try {
        final pageNumber = await resolveAyahPage(
          session.surahNumber,
          session.ayahNumber,
        );
        return MapEntry(session.id, pageNumber);
      } catch (error, stackTrace) {
        AppLogger.error('_resolveSessionPages', error, stackTrace);
        return null;
      }
    }),
  );

  return {
    for (final entry in entries)
      if (entry != null) entry.key: entry.value,
  };
}
