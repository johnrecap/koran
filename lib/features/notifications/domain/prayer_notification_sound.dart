import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';

/// Maps each prayer type to its corresponding Android raw resource sound file.
///
/// These short clips (3–4 seconds) are stored at:
///   `android/app/src/main/res/raw/prayer_<name>.mp3`
///
/// On Friday, Dhuhr is automatically replaced by the Jummah sound.
enum PrayerNotificationSound {
  fajr('prayer_fajr'),
  dhuhr('prayer_dhuhr'),
  asr('prayer_asr'),
  maghrib('prayer_maghrib'),
  isha('prayer_isha'),
  jummah('prayer_jummah');

  const PrayerNotificationSound(this.rawResourceName);

  /// The raw resource filename (without extension) under `res/raw/`.
  final String rawResourceName;

  /// Returns the correct sound for a prayer type, accounting for Friday.
  static PrayerNotificationSound forPrayer(
    PrayerType type, {
    bool isFriday = false,
  }) {
    if (isFriday && type == PrayerType.dhuhr) return jummah;
    return switch (type) {
      PrayerType.fajr => fajr,
      PrayerType.dhuhr => dhuhr,
      PrayerType.asr => asr,
      PrayerType.maghrib => maghrib,
      PrayerType.isha => isha,
    };
  }
}
