import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/domain/muallim_models.dart';
import 'package:quran_kareem/features/reader/domain/muallim_policies.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

void main() {
  group('MuallimPageSyncPolicy', () {
    test('does not navigate when Muallim mode is disabled', () {
      expect(
        MuallimPageSyncPolicy.shouldNavigate(
          isEnabled: false,
          readerMode: ReaderMode.scroll,
          currentDisplayedPage: 12,
          currentAyahPage: 13,
        ),
        isFalse,
      );
    });

    test('does not navigate in page mode because package paging stays active',
        () {
      expect(
        MuallimPageSyncPolicy.shouldNavigate(
          isEnabled: true,
          readerMode: ReaderMode.page,
          currentDisplayedPage: 12,
          currentAyahPage: 13,
        ),
        isFalse,
      );
    });

    test('navigates in scroll mode when the current ayah moves to a new page',
        () {
      expect(
        MuallimPageSyncPolicy.shouldNavigate(
          isEnabled: true,
          readerMode: ReaderMode.scroll,
          currentDisplayedPage: 12,
          currentAyahPage: 13,
        ),
        isTrue,
      );
    });
  });

  group('MuallimSnapshot', () {
    test('merges enabled state with playback data', () {
      const playback = MuallimPlaybackSnapshot(
        playbackState: MuallimPlaybackState.playing,
        currentAyah: MuallimAyahPosition(
          surahNumber: 2,
          ayahNumber: 255,
          ayahUQNumber: 281,
          pageNumber: 42,
        ),
        position: Duration(seconds: 3),
        duration: Duration(seconds: 7),
        currentReciterId: 'reader-1',
        currentReciterName: 'Reader One',
      );

      final snapshot = MuallimSnapshot.fromPlayback(
        playback,
        isEnabled: true,
      );

      expect(snapshot.isEnabled, isTrue);
      expect(snapshot.playbackState, MuallimPlaybackState.playing);
      expect(snapshot.currentAyah?.ayahUQNumber, 281);
      expect(snapshot.currentReciterName, 'Reader One');
    });
  });
}
