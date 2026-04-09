import 'package:flutter_test/flutter_test.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  group('PageMotionDecision', () {
    test('keeps the settled active page live even when a snapshot exists', () {
      final decision = PageMotionDecision.resolve(
        pagePosition: 12.0,
        pageIndex: 12,
        hasSnapshot: true,
        isCapturePending: false,
      );

      expect(decision.showLive, isTrue);
      expect(decision.showSnapshot, isFalse);
      expect(decision.shouldCapture, isFalse);
    });

    test('uses the snapshot during motion for cached pages', () {
      final decision = PageMotionDecision.resolve(
        pagePosition: 12.35,
        pageIndex: 12,
        hasSnapshot: true,
        isCapturePending: false,
      );

      expect(decision.showLive, isFalse);
      expect(decision.showSnapshot, isTrue);
      expect(decision.shouldCapture, isFalse);
    });

    test('requests capture for nearby settled pages without snapshots', () {
      final decision = PageMotionDecision.resolve(
        pagePosition: 12.0,
        pageIndex: 13,
        hasSnapshot: false,
        isCapturePending: false,
      );

      expect(decision.showLive, isTrue);
      expect(decision.showSnapshot, isFalse);
      expect(decision.shouldCapture, isTrue);
    });
  });
}
