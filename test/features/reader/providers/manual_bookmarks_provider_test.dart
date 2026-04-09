import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/providers/manual_bookmarks_provider.dart';

void main() {
  test(
    'toggle waits for stored bookmarks to load before mutating state',
    () async {
      final existingBookmark = ManualBookmark(
        surahNumber: 1,
        ayahNumber: 1,
        surahName: 'ط§ظ„ظپط§طھط­ط©',
        timestamp: DateTime(2026, 3, 27, 9),
      );
      final loadCompleter = Completer<List<ManualBookmark>>();
      final savedStates = <List<ManualBookmark>>[];

      final notifier = ManualBookmarksNotifier(
        loadBookmarks: () => loadCompleter.future,
        saveBookmarks: (bookmarks) async {
          savedStates.add(List<ManualBookmark>.from(bookmarks));
        },
      );

      final toggleFuture = notifier.toggle(
        existingBookmark.surahNumber,
        existingBookmark.ayahNumber,
        existingBookmark.surahName,
      );

      expect(notifier.state, isEmpty);

      loadCompleter.complete([existingBookmark]);
      await toggleFuture;

      expect(notifier.state, isEmpty);
      expect(savedStates, hasLength(1));
      expect(savedStates.single, isEmpty);
    },
  );
}
