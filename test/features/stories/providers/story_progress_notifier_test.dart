import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/stories/domain/story_reading_progress.dart';
import 'package:quran_kareem/features/stories/providers/story_progress_notifier.dart';
import 'package:quran_kareem/features/stories/providers/story_progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  tearDown(() {
    UserPreferences.resetCache();
  });

  group('StoryProgressNotifier', () {
    test(
        'updateProgress waits for stored progress to load before mutating state',
        () async {
      final loadCompleter = Completer<Map<String, StoryReadingProgress>>();
      final persisted = <StoryReadingProgress>[];

      final notifier = StoryProgressNotifier(
        loadProgress: () => loadCompleter.future,
        saveProgress: (progress) async {
          persisted.add(progress);
        },
        now: () => DateTime.utc(2026, 4, 8, 12),
      );

      final updateFuture = notifier.updateProgress('adam', 2, 5);

      expect(notifier.state, isEmpty);

      loadCompleter.complete(<String, StoryReadingProgress>{
        'adam': const StoryReadingProgress(
          storyId: 'adam',
          lastChapterIndex: 1,
        ),
      });
      await updateFuture;

      expect(notifier.getProgress('adam')?.lastChapterIndex, 2);
      expect(persisted.single.lastChapterIndex, 2);
    });

    test(
        'updateProgress persists progress and marks the final chapter as completed',
        () async {
      final repository = StoryProgressRepository(await UserPreferences.prefs);
      final completedAt = DateTime.utc(2026, 4, 8, 15);
      final notifier = StoryProgressNotifier(
        loadProgress: () async => repository.loadAll(),
        saveProgress: repository.save,
        now: () => completedAt,
      );

      await notifier.ready;
      await notifier.updateProgress('yusuf', 11, 12);

      final progress = notifier.getProgress('yusuf');
      final stored = repository.loadAll()['yusuf'];

      expect(progress, isNotNull);
      expect(progress?.lastChapterIndex, 11);
      expect(progress?.isCompleted, isTrue);
      expect(progress?.completedAt, completedAt);
      expect(stored?.completedAt, completedAt);
    });

    test(
        'markCompleted preserves the last chapter index and persists completion',
        () async {
      final repository = StoryProgressRepository(await UserPreferences.prefs);
      await repository.save(
        const StoryReadingProgress(
          storyId: 'musa',
          lastChapterIndex: 7,
        ),
      );

      final completedAt = DateTime.utc(2026, 4, 8, 18);
      final notifier = StoryProgressNotifier(
        loadProgress: () async => repository.loadAll(),
        saveProgress: repository.save,
        now: () => completedAt,
      );

      await notifier.ready;
      await notifier.markCompleted('musa');

      final progress = notifier.getProgress('musa');
      final stored = repository.loadAll()['musa'];

      expect(progress?.lastChapterIndex, 7);
      expect(progress?.completedAt, completedAt);
      expect(stored?.completedAt, completedAt);
    });
  });
}
