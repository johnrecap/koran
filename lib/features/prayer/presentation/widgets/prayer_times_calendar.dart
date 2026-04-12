import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/features/prayer/domain/hijri_calendar_month.dart';

class PrayerTimesCalendar extends StatelessWidget {
  const PrayerTimesCalendar({
    super.key,
    required this.monthView,
    required this.selectedDateKey,
    required this.onSelectDay,
  });

  final HijriCalendarMonthView monthView;
  final String? selectedDateKey;
  final ValueChanged<HijriCalendarDayView> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final firstDayOffset = monthView.days.isEmpty
        ? 0
        : _weekdayOffset(monthView.days.first.data.weekday);
    final cells = <Widget>[
      for (int index = 0; index < firstDayOffset; index++)
        const SizedBox.shrink(),
      for (final day in monthView.days)
        _CalendarDayCell(
          day: day,
          isSelected: selectedDateKey == day.gregorianDateKey,
          onTap: () => onSelectDay(day),
        ),
    ];

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: cells,
    );
  }

  int _weekdayOffset(int weekday) {
    return (weekday - DateTime.monday).clamp(0, 6);
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final HijriCalendarDayView day;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = switch (day.visualState) {
      PrayerCalendarDayVisualState.today =>
        AppColors.camel.withValues(alpha: isDark ? 0.28 : 0.22),
      PrayerCalendarDayVisualState.pastIncomplete =>
        Colors.grey.withValues(alpha: isDark ? 0.30 : 0.22),
      PrayerCalendarDayVisualState.completed =>
        AppColors.gold.withValues(alpha: isDark ? 0.22 : 0.16),
      PrayerCalendarDayVisualState.normal => isDark
          ? Colors.white.withValues(alpha: 0.04)
          : AppColors.camel.withValues(alpha: 0.06),
    };
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: backgroundColor,
            border: Border.all(
              color: isSelected
                  ? AppColors.gold
                  : AppColors.gold.withValues(alpha: 0.10),
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '${day.dayOfMonth}',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              if (day.tracking.isComplete)
                const PositionedDirectional(
                  top: 6,
                  end: 6,
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColors.gold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
