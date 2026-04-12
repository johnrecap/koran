import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/storage_keys.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_dashboard_summary.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_policy.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_snapshot.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/memorization/providers/spaced_review_providers.dart';

final achievementsNowProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final achievementsSnapshotProvider = Provider<AchievementSnapshot>((ref) {
  return AchievementSnapshotPolicy.build(
    sessions: ref.watch(sessionsProvider),
    khatmas: ref.watch(effectiveKhatmasProvider),
    reviewItems: ref.watch(spacedReviewItemsProvider),
    now: ref.watch(achievementsNowProvider)(),
  );
});

final achievementsSummaryProvider =
    Provider<AchievementDashboardSummary>((ref) {
  return AchievementPolicy.build(ref.watch(achievementsSnapshotProvider));
});

final achievementsAcknowledgementsProvider =
    StateNotifierProvider<AchievementsAcknowledgementsNotifier, Set<String>>(
  (ref) => AchievementsAcknowledgementsNotifier(),
);

final achievementsPendingUnlocksProvider = Provider<List<AchievementUnlock>>((
  ref,
) {
  final acknowledgements = ref.watch(achievementsAcknowledgementsProvider);
  final summary = ref.watch(achievementsSummaryProvider);

  return [
    for (final unlock in summary.unlocks)
      if (!acknowledgements.contains(unlock.id)) unlock,
  ];
});

class AchievementsAcknowledgementsNotifier extends StateNotifier<Set<String>> {
  AchievementsAcknowledgementsNotifier() : super(const <String>{}) {
    _ready = _load();
  }

  static const String _storageKey = StorageKeys.achievementAcknowledgements;

  late final Future<void> _ready;

  Future<void> get ready => _ready;

  Future<void> _load() async {
    final prefs = await UserPreferences.prefs;
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      state = <String>{};
      return;
    }

    try {
      final values = jsonDecode(raw) as List<dynamic>;
      state = values.map((value) => value.toString()).toSet();
    } catch (error, stackTrace) {
      AppLogger.error(
        'AchievementAcknowledgementsNotifier._load',
        error,
        stackTrace,
      );
      state = <String>{};
    }
  }

  Future<void> acknowledge(String unlockId) async {
    await acknowledgeAll(<String>[unlockId]);
  }

  Future<void> acknowledgeAll(Iterable<String> unlockIds) async {
    await _ready;
    final nextState = <String>{...state, ...unlockIds};
    if (nextState.length == state.length) {
      return;
    }

    state = nextState;
    await _save();
  }

  Future<void> _save() async {
    final prefs = await UserPreferences.prefs;
    final values = state.toList()..sort();
    await prefs.setString(_storageKey, jsonEncode(values));
  }
}
