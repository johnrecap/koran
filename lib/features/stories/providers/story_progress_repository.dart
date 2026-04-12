import 'dart:convert';

import 'package:quran_kareem/core/constants/storage_keys.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/stories/domain/story_reading_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryProgressRepository {
  StoryProgressRepository(this._prefs);

  static const String storageKey = StorageKeys.storyProgress;

  final SharedPreferences _prefs;

  Map<String, StoryReadingProgress> loadAll() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const <String, StoryReadingProgress>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const <String, StoryReadingProgress>{};
      }

      return decoded.map(
        (key, value) => MapEntry(
          key,
          StoryReadingProgress.fromMap(Map<String, dynamic>.from(value as Map)),
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error('StoryProgressRepository.loadAll', error, stackTrace);
      return const <String, StoryReadingProgress>{};
    }
  }

  Future<void> save(StoryReadingProgress progress) async {
    final nextEntries = <String, StoryReadingProgress>{
      ...loadAll(),
      progress.storyId: progress,
    };

    await _prefs.setString(
      storageKey,
      jsonEncode(
        nextEntries.map(
          (key, value) => MapEntry(key, value.toMap()),
        ),
      ),
    );
  }

  Future<void> clearAll() async {
    await _prefs.remove(storageKey);
  }
}
