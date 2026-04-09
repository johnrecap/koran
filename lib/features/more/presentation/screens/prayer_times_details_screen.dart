import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';
import 'package:quran_kareem/features/more/presentation/widgets/prayer_adherence_summary.dart';
import 'package:quran_kareem/features/more/presentation/widgets/prayer_day_prayer_checklist.dart';
import 'package:quran_kareem/features/more/presentation/widgets/prayer_today_times_panel.dart';
import 'package:quran_kareem/features/more/presentation/widgets/prayer_times_calendar.dart';
import 'package:quran_kareem/features/more/presentation/widgets/prayer_weekly_strip.dart';

class PrayerTimesDetailsScreen extends ConsumerStatefulWidget {
  const PrayerTimesDetailsScreen({
    super.key,
    this.initialSnapshot,
  });

  final HomePrayerSnapshot? initialSnapshot;

  @override
  ConsumerState<PrayerTimesDetailsScreen> createState() =>
      _PrayerTimesDetailsScreenState();
}

class _PrayerTimesDetailsScreenState
    extends ConsumerState<PrayerTimesDetailsScreen>
    with WidgetsBindingObserver {
  HijriMonthReference? _selectedMonth;
  String? _selectedDateKey;
  String? _lastPrayerRefreshSignature;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(homePrayerSnapshotProvider);
    }
  }

  void _schedulePrayerRefreshIfNeeded(HomePrayerSnapshot snapshot) {
    final now = ref.read(prayerNowProvider)();
    final needsRefresh = PrayerTimesPolicies.shouldRefreshHomeSnapshot(
      snapshot: snapshot,
      now: now,
    );
    if (!needsRefresh) {
      _lastPrayerRefreshSignature = null;
      return;
    }

    final signature =
        '${snapshot.gregorianDate.toIso8601String()}|${snapshot.nextPrayerTime.toIso8601String()}|${snapshot.cachedFetchedAt?.toIso8601String() ?? 'none'}';
    if (_lastPrayerRefreshSignature == signature) {
      return;
    }
    _lastPrayerRefreshSignature = signature;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.invalidate(homePrayerSnapshotProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final liveSnapshotAsync = ref.watch(homePrayerSnapshotProvider);
    final snapshot = liveSnapshotAsync.valueOrNull ?? widget.initialSnapshot;

    if (snapshot == null) {
      return liveSnapshotAsync.when(
        data: (_) => const SizedBox.shrink(),
        loading: () => const Scaffold(
          body: _CenteredMessage(
            child: CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 2,
            ),
          ),
        ),
        error: (error, stackTrace) => Scaffold(
          body: _CenteredMessage(
            child: ElevatedButton(
              onPressed: () => ref.invalidate(homePrayerSnapshotProvider),
              child: Text(context.l10n.homeToolsRetry),
            ),
          ),
        ),
      );
    }

    _schedulePrayerRefreshIfNeeded(snapshot);

    final activeMonth = _selectedMonth ?? snapshot.hijriMonthReference;
    final monthAsync = ref.watch(hijriMonthCalendarViewProvider(activeMonth));
    final adherenceAsync = ref.watch(prayerAdherenceSummaryProvider);
    final todayPanelAsync = ref.watch(todayPrayerTimesPanelProvider);
    final weeklyAsync = ref.watch(prayerWeeklyStripProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: isDark ? AppColors.textDark : AppColors.textLight,
        title: Text(
          context.l10n.prayerDetailsTitle,
          style: const TextStyle(fontFamily: 'Amiri'),
        ),
      ),
      body: monthAsync.when(
        data: (monthView) {
          final selectedDay = _resolveSelectedDay(monthView);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              ..._buildAsyncSection<DailyAdherenceSummary>(
                value: adherenceAsync,
                builder: (summary) => PrayerAdherenceSummary(summary: summary),
              ),
              ..._buildAsyncSection<List<PrayerTimeSlotView>>(
                value: todayPanelAsync,
                builder: (rows) => PrayerTodayTimesPanel(rows: rows),
              ),
              ..._buildAsyncSection<List<WeeklyDaySnapshot>>(
                value: weeklyAsync,
                builder: (week) => PrayerWeeklyStrip(week: week),
              ),
              _MonthHeader(
                monthLabel: _monthLabel(context, monthView.reference),
                onPrevious: () {
                  setState(() {
                    _selectedMonth = HijriMonthReference(
                      year: monthView.reference.month == 1
                          ? monthView.reference.year - 1
                          : monthView.reference.year,
                      month: monthView.reference.month == 1
                          ? 12
                          : monthView.reference.month - 1,
                      monthNameArabic: monthView.reference.monthNameArabic,
                      monthNameEnglish: monthView.reference.monthNameEnglish,
                    );
                    _selectedDateKey = null;
                  });
                },
                onNext: () {
                  setState(() {
                    _selectedMonth = HijriMonthReference(
                      year: monthView.reference.month == 12
                          ? monthView.reference.year + 1
                          : monthView.reference.year,
                      month: monthView.reference.month == 12
                          ? 1
                          : monthView.reference.month + 1,
                      monthNameArabic: monthView.reference.monthNameArabic,
                      monthNameEnglish: monthView.reference.monthNameEnglish,
                    );
                    _selectedDateKey = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              PrayerTimesCalendar(
                monthView: monthView,
                selectedDateKey: selectedDay?.gregorianDateKey,
                onSelectDay: (day) {
                  setState(() {
                    _selectedDateKey = day.gregorianDateKey;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (selectedDay != null)
                PrayerDayPrayerChecklist(
                  title:
                      '${context.l10n.prayerDetailsTrackPrayers} ${selectedDay.dayOfMonth}',
                  tracking: selectedDay.tracking,
                  fajrLabel: context.l10n.prayerLabelFajr,
                  dhuhrLabel: context.l10n.prayerLabelDhuhr,
                  asrLabel: context.l10n.prayerLabelAsr,
                  maghribLabel: context.l10n.prayerLabelMaghrib,
                  ishaLabel: context.l10n.prayerLabelIsha,
                  onChanged: (prayer, value) async {
                    await ref
                        .read(prayerTrackingLocalDataSourceProvider)
                        .setPrayerCompleted(
                          dateKey: selectedDay.gregorianDateKey,
                          prayer: prayer,
                          completed: value,
                        );
                    ref.invalidate(
                      prayerMonthTrackingsProvider(activeMonth),
                    );
                    ref.invalidate(todayPrayerTrackingProvider);
                    ref.invalidate(todayPrayerTimesPanelProvider);
                    ref.invalidate(prayerAdherenceSummaryProvider);
                    ref.invalidate(prayerWeeklyStripProvider);
                  },
                ),
            ],
          );
        },
        loading: () => _CenteredMessage(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.gold,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.prayerDetailsLoadingMonth,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: isDark ? AppColors.textDark : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        error: (error, stackTrace) => _CenteredMessage(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off_rounded,
                color: AppColors.gold,
                size: 52,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.prayerDetailsError,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(hijriMonthCalendarViewProvider(activeMonth));
                },
                child: Text(context.l10n.homeToolsRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  HijriCalendarDayView? _resolveSelectedDay(HijriCalendarMonthView monthView) {
    if (monthView.days.isEmpty) {
      return null;
    }

    for (final day in monthView.days) {
      if (day.gregorianDateKey == _selectedDateKey) {
        return day;
      }
    }

    final todayKey =
        PrayerTimesPolicies.dateKey(ref.watch(prayerNowProvider)());
    for (final day in monthView.days) {
      if (day.gregorianDateKey == todayKey) {
        return day;
      }
    }

    return monthView.days.first;
  }

  String _monthLabel(BuildContext context, HijriMonthReference reference) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final name = languageCode == 'ar'
        ? reference.monthNameArabic
        : reference.monthNameEnglish;
    final suffix = languageCode == 'ar' ? 'هـ' : 'AH';
    return '$name ${reference.year} $suffix';
  }

  List<Widget> _buildAsyncSection<T>({
    required AsyncValue<T> value,
    required Widget Function(T data) builder,
  }) {
    return value.when(
      data: (data) => [
        builder(data),
        const SizedBox(height: 16),
      ],
      loading: () => const <Widget>[],
      error: (error, stackTrace) => const <Widget>[],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.monthLabel,
    required this.onPrevious,
    required this.onNext,
  });

  final String monthLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.gold,
          ),
          Expanded(
            child: Text(
              monthLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}
