import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';

/// A manual bookmark â€” verse saved by tapping the verse number.
class ManualBookmark {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final DateTime timestamp;

  ManualBookmark({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.timestamp,
  });

  /// Unique key for this bookmark
  String get key => '$surahNumber:$ayahNumber';

  Map<String, dynamic> toMap() => {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'surahName': surahName,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ManualBookmark.fromMap(Map<String, dynamic> map) => ManualBookmark(
        surahNumber: map['surahNumber'] as int,
        ayahNumber: map['ayahNumber'] as int,
        surahName: map['surahName'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

/// Provider for manual bookmarks (verse number tap = dark = saved)
final manualBookmarksProvider =
    StateNotifierProvider<ManualBookmarksNotifier, List<ManualBookmark>>(
  (ref) => ManualBookmarksNotifier(),
);

typedef ManualBookmarksLoader = Future<List<ManualBookmark>> Function();
typedef ManualBookmarksSaver = Future<void> Function(
  List<ManualBookmark> bookmarks,
);

class ManualBookmarksNotifier extends StateNotifier<List<ManualBookmark>> {
  ManualBookmarksNotifier({
    ManualBookmarksLoader? loadBookmarks,
    ManualBookmarksSaver? saveBookmarks,
  })  : _loadBookmarks = loadBookmarks ?? _defaultLoadBookmarks,
        _saveBookmarks = saveBookmarks ?? _defaultSaveBookmarks,
        super([]) {
    _ready = _load();
  }

  final ManualBookmarksLoader _loadBookmarks;
  final ManualBookmarksSaver _saveBookmarks;
  late final Future<void> _ready;

  Future<void> get ready => _ready;

  Future<void> _load() async {
    state = await _loadBookmarks();
  }

  Future<void> _save() async {
    await _saveBookmarks(state);
  }

  static Future<List<ManualBookmark>> _defaultLoadBookmarks() async {
    final prefs = await UserPreferences.prefs;
    final json = prefs.getString('manualBookmarks');
    if (json == null) {
      return const <ManualBookmark>[];
    }

    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => ManualBookmark.fromMap(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (error, stackTrace) {
      AppLogger.error(
        'ManualBookmarksNotifier._defaultLoadBookmarks',
        error,
        stackTrace,
      );
      return const <ManualBookmark>[];
    }
  }

  static Future<void> _defaultSaveBookmarks(
    List<ManualBookmark> bookmarks,
  ) async {
    final prefs = await UserPreferences.prefs;
    await prefs.setString(
      'manualBookmarks',
      jsonEncode(bookmarks.map((bookmark) => bookmark.toMap()).toList()),
    );
  }

  /// Check if a specific verse is bookmarked in the in-memory state.
  bool isBookmarked(int surahNumber, int ayahNumber) {
    return state.any(
      (bookmark) =>
          bookmark.surahNumber == surahNumber &&
          bookmark.ayahNumber == ayahNumber,
    );
  }

  /// Toggle bookmark â€” add if not exists, remove if exists
  Future<void> toggle(
    int surahNumber,
    int ayahNumber,
    String surahName,
  ) async {
    await _ready;

    final exists = isBookmarked(surahNumber, ayahNumber);
    if (exists) {
      state = state
          .where((bookmark) =>
              !(bookmark.surahNumber == surahNumber &&
                  bookmark.ayahNumber == ayahNumber))
          .toList();
    } else {
      state = [
        ManualBookmark(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          surahName: surahName,
          timestamp: DateTime.now(),
        ),
        ...state,
      ];
    }

    await _save();
  }
}
