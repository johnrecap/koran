import 'package:quran_kareem/features/memorization/domain/achievement_definition.dart';

class AchievementBadgeState {
  const AchievementBadgeState({
    required this.definition,
    required this.currentValue,
    required this.targetValue,
    required this.progress,
    required this.isUnlocked,
  });

  final AchievementDefinition definition;
  final int currentValue;
  final int targetValue;
  final double progress;
  final bool isUnlocked;

  String get id => definition.id;
  AchievementBadgeCategory get category => definition.category;
  String get titleKey => definition.titleKey;
  String get descriptionKey => definition.descriptionKey;
}

class AchievementRecord {
  const AchievementRecord({
    required this.id,
    required this.labelKey,
    required this.value,
  });

  final String id;
  final String labelKey;
  final int value;
}

enum AchievementUnlockType {
  level,
  badge,
}

class AchievementUnlock {
  const AchievementUnlock.level(this.level)
      : type = AchievementUnlockType.level,
        badgeId = null,
        id = 'level:$level';

  const AchievementUnlock.badge(this.badgeId)
      : type = AchievementUnlockType.badge,
        level = null,
        id = 'badge:$badgeId';

  final AchievementUnlockType type;
  final int? level;
  final String? badgeId;
  final String id;
}

class AchievementDashboardSummary {
  const AchievementDashboardSummary({
    required this.totalXp,
    required this.level,
    required this.currentLevelStartXp,
    required this.nextLevelXp,
    required this.progressToNextLevel,
    required this.badges,
    required this.records,
    required this.unlocks,
    required this.totalVisits,
    required this.totalTrackedMinutes,
    required this.completedKhatmas,
    required this.reviewedReviews,
  });

  final int totalXp;
  final int level;
  final int currentLevelStartXp;
  final int nextLevelXp;
  final double progressToNextLevel;
  final List<AchievementBadgeState> badges;
  final List<AchievementRecord> records;
  final List<AchievementUnlock> unlocks;
  final int totalVisits;
  final int totalTrackedMinutes;
  final int completedKhatmas;
  final int reviewedReviews;

  int get unlockedBadgeCount =>
      badges.where((badge) => badge.isUnlocked).length;

  int get lockedBadgeCount => badges.length - unlockedBadgeCount;

  bool get hasCompletedBadgeCatalog => lockedBadgeCount == 0;

  double get badgeCompletionRate {
    if (badges.isEmpty) {
      return 1.0;
    }

    return unlockedBadgeCount / badges.length;
  }

  Iterable<AchievementBadgeState> get unlockedBadges =>
      badges.where((badge) => badge.isUnlocked);

  Iterable<AchievementBadgeState> get lockedBadges =>
      badges.where((badge) => !badge.isUnlocked);

  AchievementBadgeState? get nextBadge {
    AchievementBadgeState? selected;

    for (final badge in lockedBadges) {
      if (selected == null || _isBetterNextBadgeCandidate(badge, selected)) {
        selected = badge;
      }
    }

    return selected;
  }

  AchievementBadgeState? badgeById(String id) {
    for (final badge in badges) {
      if (badge.id == id) {
        return badge;
      }
    }

    return null;
  }

  bool _isBetterNextBadgeCandidate(
    AchievementBadgeState candidate,
    AchievementBadgeState selected,
  ) {
    if (candidate.progress != selected.progress) {
      return candidate.progress > selected.progress;
    }

    final candidateRemaining = candidate.targetValue - candidate.currentValue;
    final selectedRemaining = selected.targetValue - selected.currentValue;
    if (candidateRemaining != selectedRemaining) {
      return candidateRemaining < selectedRemaining;
    }

    return candidate.targetValue < selected.targetValue;
  }
}
