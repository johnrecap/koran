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

  test('retains only the newest 200 manual bookmarks', () async {
    List<ManualBookmark> latestSavedState = const <ManualBookmark>[];

    final notifier = ManualBookmarksNotifier(
      loadBookmarks: () async => const <ManualBookmark>[],
      saveBookmarks: (bookmarks) async {
        latestSavedState = List<ManualBookmark>.from(bookmarks);
      },
    );

    await notifier.ready;

    for (var index = 0; index < 205; index += 1) {
      await notifier.toggle(
        1,
        index + 1,
        'Al-Fatihah',
      );
    }

    expect(notifier.state, hasLength(200));
    expect(notifier.state.first.ayahNumber, 205);
    expect(notifier.state.last.ayahNumber, 6);
    expect(latestSavedState, hasLength(200));
    expect(latestSavedState.first.ayahNumber, 205);
    expect(latestSavedState.last.ayahNumber, 6);
  });
}
