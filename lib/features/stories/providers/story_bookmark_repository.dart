import 'dart:convert';

import 'package:quran_kareem/core/constants/storage_keys.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryBookmarkRepository {
  StoryBookmarkRepository(this._prefs);

  static const String storageKey = StorageKeys.storyBookmarks;

  final SharedPreferences _prefs;

  Set<String> loadAll() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const <String>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const <String>{};
      }

      return decoded.whereType<String>().toSet();
    } catch (error, stackTrace) {
      AppLogger.error('StoryBookmarkRepository.loadAll', error, stackTrace);
      return const <String>{};
    }
  }

  Future<void> toggle(String storyId) async {
    final bookmarks = loadAll().toSet();
    if (!bookmarks.add(storyId)) {
      bookmarks.remove(storyId);
    }

    if (bookmarks.isEmpty) {
      await _prefs.remove(storageKey);
      return;
    }

    await _prefs.setString(
      storageKey,
      jsonEncode(bookmarks.toList(growable: false)),
    );
  }

  bool isBookmarked(String storyId) {
    return loadAll().contains(storyId);
  }
}
