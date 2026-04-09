import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  group('PageSnapshotCacheService', () {
    test('keeps most recent entries within max size', () {
      final cache = PageSnapshotCacheService(maxEntries: 2);

      cache.put(1, Uint8List.fromList([1]));
      cache.put(2, Uint8List.fromList([2]));
      cache.get(1);
      cache.put(3, Uint8List.fromList([3]));

      expect(cache.has(1), isTrue);
      expect(cache.has(2), isFalse);
      expect(cache.has(3), isTrue);
    });

    test('tracks pending pages without duplicating work', () {
      final cache = PageSnapshotCacheService(maxEntries: 2);

      expect(cache.markPending(10), isTrue);
      expect(cache.markPending(10), isFalse);

      cache.put(10, Uint8List.fromList([10]));

      expect(cache.isPending(10), isFalse);
      expect(cache.markPending(10), isFalse);
    });
  });
}
