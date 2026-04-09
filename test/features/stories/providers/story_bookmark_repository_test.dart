import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/stories/providers/story_bookmark_repository.dart';
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

  group('StoryBookmarkRepository', () {
    test('loadAll returns an empty set when no bookmarks are stored', () async {
      final repository = StoryBookmarkRepository(await UserPreferences.prefs);

      expect(repository.loadAll(), isEmpty);
    });

    test('toggle adds and removes bookmarks and isBookmarked reflects state',
        () async {
      final repository = StoryBookmarkRepository(await UserPreferences.prefs);

      await repository.toggle('adam');

      expect(repository.loadAll(), equals(<String>{'adam'}));
      expect(repository.isBookmarked('adam'), isTrue);

      await repository.toggle('adam');

      expect(repository.loadAll(), isEmpty);
      expect(repository.isBookmarked('adam'), isFalse);
      expect(
        StoryBookmarkRepository.storageKey,
        isNot(StoryProgressRepository.storageKey),
      );
    });

    test('loadAll returns an empty set when the stored payload is malformed',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        StoryBookmarkRepository.storageKey: 'not-json',
      });
      UserPreferences.resetCache();

      final repository = StoryBookmarkRepository(await UserPreferences.prefs);

      expect(repository.loadAll(), isEmpty);
    });
  });
}
