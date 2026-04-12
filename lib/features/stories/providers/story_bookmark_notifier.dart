import 'package:quran_kareem/core/providers/persistent_state_notifier.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/stories/providers/story_bookmark_repository.dart';

typedef StoryBookmarksLoader = Future<Set<String>> Function();
typedef StoryBookmarkToggler = Future<void> Function(String storyId);

class StoryBookmarkNotifier extends PersistentStateNotifier<Set<String>> {
  StoryBookmarkNotifier({
    StoryBookmarksLoader? loadBookmarks,
    StoryBookmarkToggler? toggleBookmark,
  })  : _loadBookmarks = loadBookmarks ?? _defaultLoadBookmarks,
        _toggleBookmark = toggleBookmark ?? _defaultToggleBookmark,
        super(const <String>{});

  final StoryBookmarksLoader _loadBookmarks;
  final StoryBookmarkToggler _toggleBookmark;

  @override
  Future<Set<String>> loadPersistedState() async {
    return _loadBookmarks();
  }

  static Future<Set<String>> _defaultLoadBookmarks() async {
    final repository = StoryBookmarkRepository(await UserPreferences.prefs);
    return repository.loadAll();
  }

  static Future<void> _defaultToggleBookmark(String storyId) async {
    final repository = StoryBookmarkRepository(await UserPreferences.prefs);
    await repository.toggle(storyId);
  }

  @override
  Set<String> normalizeState(Set<String> state) {
    return state.toSet();
  }

  @override
  Future<void> persistState(
    Set<String> previousState,
    Set<String> currentState,
  ) async {
    final changedIds = <String>{
      ...previousState.difference(currentState),
      ...currentState.difference(previousState),
    };

    for (final storyId in changedIds) {
      await _toggleBookmark(storyId);
    }
  }

  Future<void> toggle(String storyId) async {
    await updateState((current) {
      final nextBookmarks = current.toSet();
      if (!nextBookmarks.add(storyId)) {
        nextBookmarks.remove(storyId);
      }

      return nextBookmarks;
    });
  }

  bool isBookmarked(String storyId) => state.contains(storyId);
}
