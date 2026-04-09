part of '/quran.dart';

class PageSnapshotCacheService {
  PageSnapshotCacheService({this.maxEntries = 6});

  static final PageSnapshotCacheService instance = PageSnapshotCacheService();

  final int maxEntries;
  final LinkedHashMap<int, Uint8List> _entries = LinkedHashMap<int, Uint8List>();
  final Set<int> _pendingPages = <int>{};

  Uint8List? get(int pageIndex) {
    final snapshot = _entries.remove(pageIndex);
    if (snapshot == null) {
      return null;
    }

    _entries[pageIndex] = snapshot;
    return snapshot;
  }

  bool has(int pageIndex) => _entries.containsKey(pageIndex);

  bool isPending(int pageIndex) => _pendingPages.contains(pageIndex);

  bool markPending(int pageIndex) {
    if (has(pageIndex) || isPending(pageIndex)) {
      return false;
    }

    _pendingPages.add(pageIndex);
    return true;
  }

  void put(int pageIndex, Uint8List bytes) {
    _pendingPages.remove(pageIndex);
    _entries.remove(pageIndex);
    _entries[pageIndex] = bytes;

    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void clearPending(int pageIndex) {
    _pendingPages.remove(pageIndex);
  }

  void remove(int pageIndex) {
    _pendingPages.remove(pageIndex);
    _entries.remove(pageIndex);
  }

  void clear() {
    _pendingPages.clear();
    _entries.clear();
  }
}
