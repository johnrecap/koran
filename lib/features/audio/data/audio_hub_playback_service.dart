import 'package:quran_kareem/features/audio/domain/audio_hub_playback_snapshot.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_option.dart';

abstract class AudioHubPlaybackService {
  List<AudioHubReciterOption> get availableReciters;
  bool get hasActiveSession;

  Stream<AudioHubPlaybackSnapshot> get snapshots;
  Stream<bool> get sessionActivity;

  Future<AudioHubPlaybackSnapshot> ensureInitialized();

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> playNextSurah();

  Future<void> playPreviousSurah();

  Future<void> seek(Duration position);

  Future<void> selectSurah(int surahNumber, {bool autoPlay = true});

  Future<void> selectReciter(
    String reciterId, {
    bool restartPlayback = true,
  });

  void dispose();
}
