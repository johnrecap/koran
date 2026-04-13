import 'package:flutter/widgets.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_option.dart';
import 'package:quran_kareem/features/reader/domain/muallim_models.dart';

abstract class MuallimAyahAudioService {
  List<AudioHubReciterOption> get availableReciters;

  Stream<MuallimPlaybackSnapshot> get snapshots;

  Future<MuallimPlaybackSnapshot> ensureInitialized();

  Future<void> playFromAyah(
    MuallimAyahPosition ayah, {
    BuildContext? context,
    bool isDarkMode = false,
  });

  Future<void> pause();

  Future<void> resume({
    BuildContext? context,
    bool isDarkMode = false,
  });

  Future<void> stop();

  Future<void> nextAyah({
    BuildContext? context,
  });

  Future<void> previousAyah({
    BuildContext? context,
  });

  Future<void> selectReciter(
    String reciterId, {
    BuildContext? context,
    bool restartPlayback = true,
    bool isDarkMode = false,
  });

  void clearSelectionHighlights();

  void dispose();
}
