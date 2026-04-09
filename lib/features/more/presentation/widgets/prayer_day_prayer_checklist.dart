import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/features/more/domain/prayer_day_tracking.dart';
import 'package:quran_kareem/features/more/domain/prayer_time_models.dart';

class PrayerDayPrayerChecklist extends StatelessWidget {
  const PrayerDayPrayerChecklist({
    super.key,
    required this.title,
    required this.tracking,
    required this.fajrLabel,
    required this.dhuhrLabel,
    required this.asrLabel,
    required this.maghribLabel,
    required this.ishaLabel,
    required this.onChanged,
  });

  final String title;
  final PrayerDayTracking tracking;
  final String fajrLabel;
  final String dhuhrLabel;
  final String asrLabel;
  final String maghribLabel;
  final String ishaLabel;
  final Future<void> Function(PrayerType prayer, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDark ? AppColors.surfaceDarkNav : Colors.white;
    final items = <({PrayerType type, String label})>[
      (type: PrayerType.fajr, label: fajrLabel),
      (type: PrayerType.dhuhr, label: dhuhrLabel),
      (type: PrayerType.asr, label: asrLabel),
      (type: PrayerType.maghrib, label: maghribLabel),
      (type: PrayerType.isha, label: ishaLabel),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items)
            CheckboxListTile(
              value: tracking.isCompleted(item.type),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.gold,
              contentPadding: EdgeInsets.zero,
              title: Text(
                item.label,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 17,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              onChanged: (value) async {
                if (value == null) {
                  return;
                }
                await onChanged(item.type, value);
              },
            ),
        ],
      ),
    );
  }
}
