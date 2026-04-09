import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/stories/domain/story_reading_progress.dart';
import 'package:quran_kareem/features/stories/providers/story_progress_repository.dart';

typedef StoryProgressLoader = Future<Map<String, StoryReadingProgress>>
    Function();
typedef StoryProgressSaver = Future<void> Function(
    StoryReadingProgress progress);

class StoryProgressNotifier
    extends StateNotifier<Map<String, StoryReadingProgress>> {
  StoryProgressNotifier({
    StoryProgressLoader? loadProgress,
    StoryProgressSaver? saveProgress,
    DateTime Function()? now,
  })  : _loadProgress = loadProgress ?? _defaultLoadProgress,
        _saveProgress = saveProgress ?? _defaultSaveProgress,
        _now = now ?? DateTime.now,
        super(const <String, StoryReadingProgress>{}) {
    _ready = _init();
  }

  final StoryProgressLoader _loadProgress;
  final StoryProgressSaver _saveProgress;
  final DateTime Function() _now;

  late final Future<void> _ready;

  Future<void> get ready => _ready;

  Future<void> _init() async {
    state = await _loadProgress();
  }

  static Future<Map<String, StoryReadingProgress>>
      _defaultLoadProgress() async {
    final repository = StoryProgressRepository(await UserPreferences.prefs);
    return repository.loadAll();
  }

  static Future<void> _defaultSaveProgress(
    StoryReadingProgress progress,
  ) async {
    final repository = StoryProgressRepository(await UserPreferences.prefs);
    await repository.save(progress);
  }

  Future<void> updateProgress(
    String storyId,
    int lastChapter,
    int totalChapters,
  ) async {
    await _ready;

    final maxChapterIndex = totalChapters > 0 ? totalChapters - 1 : 0;
    final normalizedLastChapter = lastChapter.clamp(0, maxChapterIndex);
    final existing = state[storyId];
    final isCompleted =
        totalChapters > 0 && normalizedLastChapter >= maxChapterIndex;

    final progress = StoryReadingProgress(
      storyId: storyId,
      lastChapterIndex: normalizedLastChapter,
      completedAt: existing?.completedAt ?? (isCompleted ? _now() : null),
    );

    state = <String, StoryReadingProgress>{
      ...state,
      storyId: progress,
    };
    await _saveProgress(progress);
  }

  Future<void> markCompleted(String storyId) async {
    await _ready;

    final existing = state[storyId];
    final progress = StoryReadingProgress(
      storyId: storyId,
      lastChapterIndex: existing?.lastChapterIndex ?? 0,
      completedAt: existing?.completedAt ?? _now(),
    );

    state = <String, StoryReadingProgress>{
      ...state,
      storyId: progress,
    };
    await _saveProgress(progress);
  }

  StoryReadingProgress? getProgress(String storyId) => state[storyId];
}
