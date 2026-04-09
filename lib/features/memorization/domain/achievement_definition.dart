enum AchievementBadgeCategory {
  reading,
  streak,
  khatma,
  review,
}

enum AchievementMetric {
  normalizedVisits,
  trackedMinutes,
  bestReadingStreakDays,
  completedKhatmas,
  reviewedReviews,
  reviewRepetitions,
  totalKhatmas,
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.category,
    required this.metric,
    required this.targetValue,
    required this.titleKey,
    required this.descriptionKey,
  });

  final String id;
  final AchievementBadgeCategory category;
  final AchievementMetric metric;
  final int targetValue;
  final String titleKey;
  final String descriptionKey;
}

abstract final class AchievementCatalog {
  static const List<AchievementDefinition> badges = [
    AchievementDefinition(
      id: 'first_steps',
      category: AchievementBadgeCategory.reading,
      metric: AchievementMetric.normalizedVisits,
      targetValue: 1,
      titleKey: 'achievementsBadgeFirstStepsTitle',
      descriptionKey: 'achievementsBadgeFirstStepsDescription',
    ),
    AchievementDefinition(
      id: 'steady_reader',
      category: AchievementBadgeCategory.reading,
      metric: AchievementMetric.normalizedVisits,
      targetValue: 5,
      titleKey: 'achievementsBadgeSteadyReaderTitle',
      descriptionKey: 'achievementsBadgeSteadyReaderDescription',
    ),
    AchievementDefinition(
      id: 'focus_minutes',
      category: AchievementBadgeCategory.reading,
      metric: AchievementMetric.trackedMinutes,
      targetValue: 30,
      titleKey: 'achievementsBadgeFocusMinutesTitle',
      descriptionKey: 'achievementsBadgeFocusMinutesDescription',
    ),
    AchievementDefinition(
      id: 'deep_focus',
      category: AchievementBadgeCategory.reading,
      metric: AchievementMetric.trackedMinutes,
      targetValue: 120,
      titleKey: 'achievementsBadgeDeepFocusTitle',
      descriptionKey: 'achievementsBadgeDeepFocusDescription',
    ),
    AchievementDefinition(
      id: 'streak_guardian',
      category: AchievementBadgeCategory.streak,
      metric: AchievementMetric.bestReadingStreakDays,
      targetValue: 5,
      titleKey: 'achievementsBadgeStreakGuardianTitle',
      descriptionKey: 'achievementsBadgeStreakGuardianDescription',
    ),
    AchievementDefinition(
      id: 'streak_lighthouse',
      category: AchievementBadgeCategory.streak,
      metric: AchievementMetric.bestReadingStreakDays,
      targetValue: 10,
      titleKey: 'achievementsBadgeStreakLighthouseTitle',
      descriptionKey: 'achievementsBadgeStreakLighthouseDescription',
    ),
    AchievementDefinition(
      id: 'first_khatma',
      category: AchievementBadgeCategory.khatma,
      metric: AchievementMetric.completedKhatmas,
      targetValue: 1,
      titleKey: 'achievementsBadgeFirstKhatmaTitle',
      descriptionKey: 'achievementsBadgeFirstKhatmaDescription',
    ),
    AchievementDefinition(
      id: 'khatma_builder',
      category: AchievementBadgeCategory.khatma,
      metric: AchievementMetric.totalKhatmas,
      targetValue: 2,
      titleKey: 'achievementsBadgeKhatmaBuilderTitle',
      descriptionKey: 'achievementsBadgeKhatmaBuilderDescription',
    ),
    AchievementDefinition(
      id: 'khatma_finisher',
      category: AchievementBadgeCategory.khatma,
      metric: AchievementMetric.completedKhatmas,
      targetValue: 3,
      titleKey: 'achievementsBadgeKhatmaFinisherTitle',
      descriptionKey: 'achievementsBadgeKhatmaFinisherDescription',
    ),
    AchievementDefinition(
      id: 'review_starter',
      category: AchievementBadgeCategory.review,
      metric: AchievementMetric.reviewedReviews,
      targetValue: 1,
      titleKey: 'achievementsBadgeReviewStarterTitle',
      descriptionKey: 'achievementsBadgeReviewStarterDescription',
    ),
    AchievementDefinition(
      id: 'review_keeper',
      category: AchievementBadgeCategory.review,
      metric: AchievementMetric.reviewRepetitions,
      targetValue: 5,
      titleKey: 'achievementsBadgeReviewKeeperTitle',
      descriptionKey: 'achievementsBadgeReviewKeeperDescription',
    ),
    AchievementDefinition(
      id: 'review_archivist',
      category: AchievementBadgeCategory.review,
      metric: AchievementMetric.reviewedReviews,
      targetValue: 3,
      titleKey: 'achievementsBadgeReviewArchivistTitle',
      descriptionKey: 'achievementsBadgeReviewArchivistDescription',
    ),
  ];
}
