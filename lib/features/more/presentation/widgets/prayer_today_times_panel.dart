import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/more/domain/prayer_time_models.dart';

class PrayerTodayTimesPanel extends StatelessWidget {
  const PrayerTodayTimesPanel({
    super.key,
    required this.rows,
  });

  final List<PrayerTimeSlotView> rows;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = context.l10n;

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
            localizations.prayerTodayTitle,
            key: const Key('prayer-today-title'),
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          for (final row in rows) ...[
            _PrayerTodayRow(
              row: row,
              key: Key('prayer-today-row-${row.entry.type.name}'),
            ),
            if (row != rows.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PrayerTodayRow extends StatelessWidget {
  const _PrayerTodayRow({
    super.key,
    required this.row,
  });

  final PrayerTimeSlotView row;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = context.l10n;
    final materialLocalizations = MaterialLocalizations.of(context);
    final statusColor = switch (row.status) {
      PrayerTimeSlotStatus.past => isDark ? Colors.white54 : AppColors.textMuted,
      PrayerTimeSlotStatus.current => AppColors.gold,
      PrayerTimeSlotStatus.upcoming =>
        isDark ? AppColors.textDark : AppColors.textLight,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: row.status == PrayerTimeSlotStatus.current
            ? AppColors.gold.withValues(alpha: isDark ? 0.18 : 0.12)
            : (isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.36)
                : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _prayerLabel(localizations, row.entry.type),
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusLabel(localizations, row.status),
                  key: Key(
                    'prayer-today-status-${row.entry.type.name}-${row.status.name}',
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            materialLocalizations.formatTimeOfDay(
              row.timeOfDay,
              alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
          if (row.isTracked) ...[
            const SizedBox(width: 10),
            Icon(
              Icons.check_circle_rounded,
              key: Key('prayer-today-tracked-${row.entry.type.name}'),
              color: AppColors.gold,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  String _prayerLabel(AppLocalizations l10n, PrayerType type) {
    return switch (type) {
      PrayerType.fajr => l10n.prayerLabelFajr,
      PrayerType.dhuhr => l10n.prayerLabelDhuhr,
      PrayerType.asr => l10n.prayerLabelAsr,
      PrayerType.maghrib => l10n.prayerLabelMaghrib,
      PrayerType.isha => l10n.prayerLabelIsha,
    };
  }

  String _statusLabel(AppLocalizations l10n, PrayerTimeSlotStatus status) {
    return switch (status) {
      PrayerTimeSlotStatus.past => l10n.prayerStatusPast,
      PrayerTimeSlotStatus.current => l10n.prayerStatusCurrent,
      PrayerTimeSlotStatus.upcoming => l10n.prayerStatusUpcoming,
    };
  }
}
