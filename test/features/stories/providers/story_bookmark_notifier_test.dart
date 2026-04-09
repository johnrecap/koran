import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/stories/providers/story_bookmark_notifier.dart';
import 'package:quran_kareem/features/stories/providers/story_bookmark_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  tearDown(() {
    UserPreferences.resetCache();
  });

  group('StoryBookmarkNotifier', () {
    test('toggle waits for stored bookmarks to load before mutating state',
        () async {
      final loadCompleter = Completer<Set<String>>();
      final toggledIds = <String>[];
      final notifier = StoryBookmarkNotifier(
        loadBookmarks: () => loadCompleter.future,
        toggleBookmark: (storyId) async {
          toggledIds.add(storyId);
        },
      );

      final toggleFuture = notifier.toggle('adam');

      expect(notifier.state, isEmpty);

      loadCompleter.complete(<String>{'musa'});
      await toggleFuture;

      expect(notifier.state, <String>{'musa', 'adam'});
      expect(toggledIds, <String>['adam']);
    });

    test('toggle persists add and remove cycles through the repository',
        () async {
      final repository = StoryBookmarkRepository(await UserPreferences.prefs);
      final notifier = StoryBookmarkNotifier(
        loadBookmarks: () async => repository.loadAll(),
        toggleBookmark: repository.toggle,
      );

      await notifier.ready;
      await notifier.toggle('adam');

      expect(notifier.isBookmarked('adam'), isTrue);
      expect(repository.loadAll(), <String>{'adam'});

      await notifier.toggle('adam');

      expect(notifier.isBookmarked('adam'), isFalse);
      expect(repository.loadAll(), isEmpty);
    });
  });
}
