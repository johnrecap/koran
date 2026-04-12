import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/storage_keys.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/memorization/data/debounced_save_scheduler.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/domain/spaced_review_generation_policy.dart';
import 'package:quran_kareem/features/memorization/domain/spaced_review_queue_summary.dart';
import 'package:quran_kareem/features/memorization/domain/spaced_review_schedule_policy.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';

final spacedReviewNowProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final spacedReviewItemsProvider =
    StateNotifierProvider<SpacedReviewItemsNotifier, List<SpacedReviewItem>>(
  (ref) {
    final notifier = SpacedReviewItemsNotifier(ref);
    ref.listen<Khatma?>(activeKhatmaProvider, (previous, next) {
      if (_shouldSyncActiveKhatma(previous, next)) {
        unawaited(notifier.syncWithActiveKhatma(next));
      }
    });
    return notifier;
  },
);

final spacedReviewQueueSummaryProvider = Provider<SpacedReviewQueueSummary>((
  ref,
) {
  return SpacedReviewQueueSummaryPolicy.build(
    activeKhatma: ref.watch(activeKhatmaProvider),
    items: ref.watch(spacedReviewItemsProvider),
    now: ref.watch(spacedReviewNowProvider)(),
  );
});

final spacedReviewItemByIdProvider =
    Provider.family<SpacedReviewItem?, String>((ref, reviewId) {
  final items = ref.watch(spacedReviewItemsProvider);
  for (final item in items) {
    if (item.id == reviewId) {
      return item;
    }
  }

  return null;
});

class SpacedReviewItemsNotifier extends StateNotifier<List<SpacedReviewItem>> {
  SpacedReviewItemsNotifier(this.ref) : super(const <SpacedReviewItem>[]) {
    _loadFuture = _load();
    _readyFuture = _initialize();
  }

  static const String _storageKey = StorageKeys.spacedReviewItems;

  final Ref ref;
  late final Future<void> _loadFuture;
  late final Future<void> _readyFuture;
  final DebouncedSaveScheduler _saveScheduler = DebouncedSaveScheduler();

  Future<void> get ready => _readyFuture;

  Future<void> _initialize() async {
    await _loadFuture;
    await syncWithActiveKhatma(ref.read(activeKhatmaProvider));
  }

  Future<void> _load() async {
    final prefs = await UserPreferences.prefs;
    final json = prefs.getString(_storageKey);
    if (json == null) {
      state = const <SpacedReviewItem>[];
      return;
    }

    try {
      final list = jsonDecode(json) as List<dynamic>;
      state = list
          .map((item) => SpacedReviewItem.fromMap(item as Map<String, dynamic>))
          .toList()
        ..sort(_sortItems);
    } catch (error, stackTrace) {
      AppLogger.error('SpacedReviewItemsNotifier._load', error, stackTrace);
      state = const <SpacedReviewItem>[];
    }
  }

  Future<void> syncWithActiveKhatma(Khatma? khatma) async {
    await _loadFuture;
    if (khatma == null) {
      return;
    }

    final normalizedItems = [
      for (final item in state)
        if (item.khatmaId == khatma.id && item.khatmaTitle != khatma.title)
          item.copyWith(khatmaTitle: khatma.title)
        else
          item,
    ];
    final generatedItems = SpacedReviewGenerationPolicy.generateMissingItems(
      khatma: khatma,
      existingItems: normalizedItems,
      now: ref.read(spacedReviewNowProvider)(),
    );

    if (generatedItems.isEmpty && _sameItems(state, normalizedItems)) {
      return;
    }

    state = [...normalizedItems, ...generatedItems]..sort(_sortItems);
    await _scheduleSave();
  }

  Future<void> recordOutcome({
    required String reviewId,
    required ReviewOutcome outcome,
    required DateTime reviewedAt,
  }) async {
    await _loadFuture;

    state = [
      for (final item in state)
        if (item.id == reviewId)
          SpacedReviewSchedulePolicy.applyOutcome(
            item: item,
            outcome: outcome,
            reviewedAt: reviewedAt,
          )
        else
          item,
    ]..sort(_sortItems);

    await _scheduleSave();
  }

  Future<void> _save() async {
    final prefs = await UserPreferences.prefs;
    await prefs.setString(
      _storageKey,
      jsonEncode(state.map((item) => item.toMap()).toList()),
    );
  }

  Future<void> _scheduleSave() {
    return _saveScheduler.schedule(_save);
  }

  static int _sortItems(SpacedReviewItem first, SpacedReviewItem second) {
    return first.nextReviewAt.compareTo(second.nextReviewAt);
  }

  static bool _sameItems(
    List<SpacedReviewItem> first,
    List<SpacedReviewItem> second,
  ) {
    final firstJson = jsonEncode(first.map((item) => item.toMap()).toList());
    final secondJson = jsonEncode(second.map((item) => item.toMap()).toList());
    return firstJson == secondJson;
  }

  @override
  void dispose() {
    _saveScheduler.dispose();
    super.dispose();
  }
}

bool _shouldSyncActiveKhatma(Khatma? previous, Khatma? next) {
  if (previous == null && next == null) {
    return false;
  }
  if (previous == null || next == null) {
    return true;
  }

  return previous.id != next.id ||
      previous.title != next.title ||
      previous.startPage != next.startPage ||
      previous.furthestPageRead != next.furthestPageRead ||
      previous.targetDays != next.targetDays;
}
