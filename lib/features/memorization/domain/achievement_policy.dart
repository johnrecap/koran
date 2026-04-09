import 'package:quran_kareem/features/memorization/domain/achievement_dashboard_summary.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_definition.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_snapshot.dart';

abstract final class AchievementPolicy {
  static AchievementDashboardSummary build(AchievementSnapshot snapshot) {
    final badges = [
      for (final definition in AchievementCatalog.badges)
        _buildBadgeState(definition, snapshot),
    ];
    final totalXp = _calculateXp(snapshot);
    final level = _resolveLevel(totalXp);
    final currentLevelStartXp = xpThresholdForLevel(level);
    final nextLevelXp = xpThresholdForLevel(level + 1);
    final progressToNextLevel = nextLevelXp == currentLevelStartXp
        ? 1.0
        : ((totalXp - currentLevelStartXp) /
                (nextLevelXp - currentLevelStartXp))
            .clamp(0.0, 1.0);

    return AchievementDashboardSummary(
      totalXp: totalXp,
      level: level,
      currentLevelStartXp: currentLevelStartXp,
      nextLevelXp: nextLevelXp,
      progressToNextLevel: progressToNextLevel,
      badges: badges,
      records: _buildRecords(snapshot),
      unlocks: _buildUnlocks(level: level, badges: badges),
      totalVisits: snapshot.normalizedVisitCount,
      totalTrackedMinutes: snapshot.totalTrackedMinutes,
      completedKhatmas: snapshot.completedKhatmaCount,
      reviewedReviews: snapshot.reviewedReviewCount,
    );
  }

  static int xpThresholdForLevel(int level) {
    if (level <= 1) {
      return 0;
    }

    var threshold = 0;
    for (var currentLevel = 2; currentLevel <= level; currentLevel += 1) {
      threshold += 75 + ((currentLevel - 2) * 25);
    }

    return threshold;
  }

  static AchievementBadgeState _buildBadgeState(
    AchievementDefinition definition,
    AchievementSnapshot snapshot,
  ) {
    final currentValue = _metricValue(definition.metric, snapshot);
    final targetValue = definition.targetValue;
    final isUnlocked = currentValue >= targetValue;
    final progress =
        targetValue <= 0 ? 1.0 : (currentValue / targetValue).clamp(0.0, 1.0);

    return AchievementBadgeState(
      definition: definition,
      currentValue: currentValue,
      targetValue: targetValue,
      progress: progress,
      isUnlocked: isUnlocked,
    );
  }

  static List<AchievementRecord> _buildRecords(AchievementSnapshot snapshot) {
    return [
      AchievementRecord(
        id: 'best_streak_days',
        labelKey: 'achievementsRecordBestStreakDays',
        value: snapshot.bestReadingStreakDays,
      ),
      AchievementRecord(
        id: 'tracked_minutes',
        labelKey: 'achievementsRecordTrackedMinutes',
        value: snapshot.totalTrackedMinutes,
      ),
      AchievementRecord(
        id: 'completed_khatmas',
        labelKey: 'achievementsRecordCompletedKhatmas',
        value: snapshot.completedKhatmaCount,
      ),
      AchievementRecord(
        id: 'reviewed_reviews',
        labelKey: 'achievementsRecordReviewedReviews',
        value: snapshot.reviewedReviewCount,
      ),
      AchievementRecord(
        id: 'total_visits',
        labelKey: 'achievementsRecordTotalVisits',
        value: snapshot.normalizedVisitCount,
      ),
    ];
  }

  static List<AchievementUnlock> _buildUnlocks({
    required int level,
    required List<AchievementBadgeState> badges,
  }) {
    return [
      for (var unlockedLevel = 2; unlockedLevel <= level; unlockedLevel += 1)
        AchievementUnlock.level(unlockedLevel),
      for (final badge in badges)
        if (badge.isUnlocked) AchievementUnlock.badge(badge.id),
    ];
  }

  static int _metricValue(
    AchievementMetric metric,
    AchievementSnapshot snapshot,
  ) {
    switch (metric) {
      case AchievementMetric.normalizedVisits:
        return snapshot.normalizedVisitCount;
      case AchievementMetric.trackedMinutes:
        return snapshot.totalTrackedMinutes;
      case AchievementMetric.bestReadingStreakDays:
        return snapshot.bestReadingStreakDays;
      case AchievementMetric.completedKhatmas:
        return snapshot.completedKhatmaCount;
      case AchievementMetric.reviewedReviews:
        return snapshot.reviewedReviewCount;
      case AchievementMetric.reviewRepetitions:
        return snapshot.totalReviewRepetitions;
      case AchievementMetric.totalKhatmas:
        return snapshot.totalKhatmaCount;
    }
  }

  static int _calculateXp(AchievementSnapshot snapshot) {
    return (snapshot.normalizedVisitCount * 15) +
        snapshot.totalTrackedMinutes +
        (snapshot.bestReadingStreakDays * 10) +
        (snapshot.completedKhatmaCount * 80) +
        (snapshot.reviewedReviewCount * 25) +
        (snapshot.totalReviewRepetitions * 5);
  }

  static int _resolveLevel(int totalXp) {
    var level = 1;

    while (totalXp >= xpThresholdForLevel(level + 1)) {
      level += 1;
    }

    return level;
  }
}
