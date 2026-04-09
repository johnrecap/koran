import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/stories/providers/story_bookmark_repository.dart';

typedef StoryBookmarksLoader = Future<Set<String>> Function();
typedef StoryBookmarkToggler = Future<void> Function(String storyId);

class StoryBookmarkNotifier extends StateNotifier<Set<String>> {
  StoryBookmarkNotifier({
    StoryBookmarksLoader? loadBookmarks,
    StoryBookmarkToggler? toggleBookmark,
  })  : _loadBookmarks = loadBookmarks ?? _defaultLoadBookmarks,
        _toggleBookmark = toggleBookmark ?? _defaultToggleBookmark,
        super(const <String>{}) {
    _ready = _init();
  }

  final StoryBookmarksLoader _loadBookmarks;
  final StoryBookmarkToggler _toggleBookmark;

  late final Future<void> _ready;

  Future<void> get ready => _ready;

  Future<void> _init() async {
    state = await _loadBookmarks();
  }

  static Future<Set<String>> _defaultLoadBookmarks() async {
    final repository = StoryBookmarkRepository(await UserPreferences.prefs);
    return repository.loadAll();
  }

  static Future<void> _defaultToggleBookmark(String storyId) async {
    final repository = StoryBookmarkRepository(await UserPreferences.prefs);
    await repository.toggle(storyId);
  }

  Future<void> toggle(String storyId) async {
    await _ready;

    final nextBookmarks = state.toSet();
    if (!nextBookmarks.add(storyId)) {
      nextBookmarks.remove(storyId);
    }

    state = nextBookmarks;
    await _toggleBookmark(storyId);
  }

  bool isBookmarked(String storyId) => state.contains(storyId);
}
