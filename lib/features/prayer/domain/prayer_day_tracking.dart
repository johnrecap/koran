import 'prayer_time_models.dart';

class PrayerDayTracking {
  const PrayerDayTracking({
    required this.dateKey,
    required this.completedPrayers,
  });

  final String dateKey;
  final Set<PrayerType> completedPrayers;

  bool isCompleted(PrayerType prayer) => completedPrayers.contains(prayer);

  bool get isComplete => completedPrayers.length == PrayerType.values.length;

  PrayerDayTracking copyWith({
    String? dateKey,
    Set<PrayerType>? completedPrayers,
  }) {
    return PrayerDayTracking(
      dateKey: dateKey ?? this.dateKey,
      completedPrayers: completedPrayers ?? this.completedPrayers,
    );
  }
}
