import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_option.dart';

class AudioHubReciterPolicy {
  const AudioHubReciterPolicy._();

  static int resolveReaderIndex({
    required List<AudioHubReciterOption> options,
    required String? persistedReciterId,
    required int fallbackIndex,
  }) {
    if (options.isEmpty) {
      return 0;
    }

    if (persistedReciterId != null) {
      for (final option in options) {
        if (option.id == persistedReciterId) {
          return option.index;
        }
      }
    }

    return fallbackIndex.clamp(0, options.length - 1);
  }
}
