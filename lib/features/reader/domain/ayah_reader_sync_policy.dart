import 'package:quran_library/quran_library.dart';

/// Maps a surah reciter selection to the closest ayah reader index.
///
/// The package maintains two independent reader lists:
/// - [ReadersConstants.activeSurahReaders] for full-surah audio
/// - [ReadersConstants.activeAyahReaders] for per-verse audio
///
/// When the user selects a reciter in the Audio Hub (surah-level),
/// this policy resolves the best-match ayah reader index so that
/// per-verse playback uses the same (or closest) reciter voice.
class AyahReaderSyncPolicy {
  const AyahReaderSyncPolicy._();

  /// Resolves the ayah reader index that best matches the given
  /// [surahReciterId] (a [ReaderInfo.readerNamePath] from the surah list).
  ///
  /// Returns the matched index into [ReadersConstants.activeAyahReaders],
  /// or `null` if no match is found (caller should keep the current index).
  static int? resolveAyahReaderIndex({
    required String surahReciterId,
  }) {
    final ayahReaders = ReadersConstants.activeAyahReaders;
    if (ayahReaders.isEmpty) return null;

    // 1. Exact match by readerNamePath
    for (int i = 0; i < ayahReaders.length; i++) {
      if (ayahReaders[i].readerNamePath == surahReciterId) {
        return i;
      }
    }

    // 2. Partial match — surah reciter path contains ayah reader path or
    //    vice versa (handles cases like "Alafasy" vs "Alafasy_128kbps")
    for (int i = 0; i < ayahReaders.length; i++) {
      final ayahPath = ayahReaders[i].readerNamePath.toLowerCase();
      final surahPath = surahReciterId.toLowerCase();
      if (ayahPath.contains(surahPath) || surahPath.contains(ayahPath)) {
        return i;
      }
    }

    // 3. Name-based match as last resort
    for (int i = 0; i < ayahReaders.length; i++) {
      final ayahName = ayahReaders[i].name.toLowerCase();
      final surahName = _surahReaderName(surahReciterId)?.toLowerCase();
      if (surahName != null &&
          (ayahName.contains(surahName) || surahName.contains(ayahName))) {
        return i;
      }
    }

    return null;
  }

  /// Syncs [AudioCtrl.state.ayahReaderIndex] to match the current surah
  /// reader selection. Call before [AudioCtrl.playAyah] to ensure the
  /// correct reciter voice is used for per-verse playback.
  static void syncFromCurrentSurahReader() {
    final audioCtrl = AudioCtrl.instance;
    final surahReaders = ReadersConstants.activeSurahReaders;
    final surahIndex = audioCtrl.state.surahReaderIndex.value;

    if (surahIndex < 0 || surahIndex >= surahReaders.length) return;

    final surahReciterId = surahReaders[surahIndex].readerNamePath;
    final matchedIndex = resolveAyahReaderIndex(
      surahReciterId: surahReciterId,
    );

    if (matchedIndex != null) {
      audioCtrl.state.ayahReaderIndex.value = matchedIndex;
    }
  }

  /// Looks up the display name of a surah reader by its path.
  static String? _surahReaderName(String readerNamePath) {
    final surahReaders = ReadersConstants.activeSurahReaders;
    for (final reader in surahReaders) {
      if (reader.readerNamePath == readerNamePath) {
        return reader.name;
      }
    }
    return null;
  }
}
