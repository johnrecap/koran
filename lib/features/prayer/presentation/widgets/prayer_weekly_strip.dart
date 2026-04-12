import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';

class PrayerWeeklyStrip extends StatelessWidget {
  const PrayerWeeklyStrip({
    super.key,
    required this.week,
  });

  final List<WeeklyDaySnapshot> week;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.prayerWeeklyTitle,
            key: const Key('prayer-weekly-title'),
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final day in week)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _PrayerWeeklyCell(
                      key: Key('prayer-weekly-cell-${day.dateKey}'),
                      day: day,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerWeeklyCell extends StatelessWidget {
  const _PrayerWeeklyCell({
    super.key,
    required this.day,
  });

  final WeeklyDaySnapshot day;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = MaterialLocalizations.of(context);
    final baseColor = day.completedCount == day.totalPrayers
        ? AppColors.gold.withValues(alpha: 0.18)
        : (isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.36)
            : AppColors.surfaceLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: day.isToday
              ? AppColors.gold
              : AppColors.gold.withValues(alpha: 0.08),
          width: day.isToday ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          if (day.isToday)
            Container(
              key: const Key('prayer-weekly-cell-today'),
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 14),
          Text(
            localizations.narrowWeekdays[day.date.weekday % 7],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${day.completedCount}/${day.totalPrayers}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: day.completedCount == day.totalPrayers
                  ? AppColors.gold
                  : (isDark ? AppColors.textDark : AppColors.textLight),
            ),
          ),
        ],
      ),
    );
  }
}
