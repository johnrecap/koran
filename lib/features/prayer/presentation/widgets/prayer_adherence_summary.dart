import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/prayer/domain/prayer_time_models.dart';

class PrayerAdherenceSummary extends StatelessWidget {
  const PrayerAdherenceSummary({
    super.key,
    required this.summary,
  });

  final DailyAdherenceSummary summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = context.l10n;
    final progress = summary.total == 0 ? 0.0 : summary.completed / summary.total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: AppColors.gold.withValues(alpha: 0.14),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.gold,
                  ),
                ),
                Center(
                  child: Text(
                    '${summary.completed}/${summary.total}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.prayerAdherenceToday,
                  key: const Key('prayer-adherence-title'),
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${summary.completed}/${summary.total}',
                  key: const Key('prayer-adherence-value'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                if (summary.streakDays >= 2) ...[
                  const SizedBox(height: 8),
                  Container(
                    key: const Key('prayer-adherence-streak'),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      localizations.prayerAdherenceStreak(
                        summary.streakDays.toString(),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
