import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/stories/domain/story_reading_progress.dart';
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

  group('StoryProgressRepository', () {
    test('loadAll returns an empty map when no story progress is stored',
        () async {
      final repository = StoryProgressRepository(await UserPreferences.prefs);

      expect(repository.loadAll(), isEmpty);
    });

    test('save merges progress and loadAll restores it by story id', () async {
      final repository = StoryProgressRepository(await UserPreferences.prefs);

      await repository.save(
        const StoryReadingProgress(
          storyId: 'adam',
          lastChapterIndex: 4,
        ),
      );
      await repository.save(
        StoryReadingProgress(
          storyId: 'yusuf',
          lastChapterIndex: 11,
          completedAt: DateTime.utc(2026, 4, 8, 14),
        ),
      );

      final allProgress = repository.loadAll();

      expect(allProgress.keys, containsAll(<String>['adam', 'yusuf']));
      expect(allProgress['adam']?.lastChapterIndex, 4);
      expect(allProgress['yusuf']?.isCompleted, isTrue);
      expect(
        (await UserPreferences.prefs)
            .getString(StoryProgressRepository.storageKey),
        isNotNull,
      );
    });

    test('loadAll returns an empty map when the stored payload is malformed',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        StoryProgressRepository.storageKey: 'not-json',
      });
      UserPreferences.resetCache();

      final repository = StoryProgressRepository(await UserPreferences.prefs);

      expect(repository.loadAll(), isEmpty);
    });

    test('clearAll removes every stored story progress entry', () async {
      final repository = StoryProgressRepository(await UserPreferences.prefs);

      await repository.save(
        const StoryReadingProgress(
          storyId: 'adam',
          lastChapterIndex: 4,
        ),
      );

      await repository.clearAll();

      expect(repository.loadAll(), isEmpty);
      expect(
        (await UserPreferences.prefs)
            .containsKey(StoryProgressRepository.storageKey),
        isFalse,
      );
    });
  });
}
