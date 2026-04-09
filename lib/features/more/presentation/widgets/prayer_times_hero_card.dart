import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/more/domain/prayer_time_models.dart';

class PrayerTimesHeroCard extends StatelessWidget {
  const PrayerTimesHeroCard({
    super.key,
    required this.title,
    required this.snapshot,
    required this.nextPrayerLabel,
    required this.openTrackerLabel,
    required this.onTap,
  });

  final String title;
  final HomePrayerSnapshot snapshot;
  final String nextPrayerLabel;
  final String openTrackerLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.surfaceDarkNav
        : Colors.white.withValues(alpha: 0.96);
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final timeLabel = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(snapshot.nextPrayerTime),
      alwaysUse24HourFormat: true,
    );
    final cachedLabel = _cachedDataLabel(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('home-tools-prayer-hero'),
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.camel.withValues(alpha: isDark ? 0.18 : 0.14),
                surfaceColor,
                AppColors.gold.withValues(alpha: isDark ? 0.10 : 0.08),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            snapshot.locationLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                          if (cachedLabel != null) ...[
                            const SizedBox(height: 8),
                            _StaleDataBadge(label: cachedLabel),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.schedule_rounded,
                        color: AppColors.gold,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _HeroMetric(
                        label: snapshot.weekdayLabel,
                        value: snapshot.hijriLabel,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HeroMetric(
                        label: nextPrayerLabel,
                        value: timeLabel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _CountdownPill(
                        target: snapshot.nextPrayerTime,
                        textColor: textColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: AppColors.camel.withValues(alpha: 0.12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            openTrackerLabel,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: AppColors.gold,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _cachedDataLabel(BuildContext context) {
    if (!snapshot.isUsingCachedData) {
      return null;
    }

    final fetchedAt = snapshot.cachedFetchedAt;
    if (fetchedAt == null) {
      return context.l10n.homeToolsPrayerCached;
    }

    final formattedTime = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(fetchedAt),
      alwaysUse24HourFormat: true,
    );
    return context.l10n.homeToolsPrayerCachedAt(formattedTime);
  }
}

class _StaleDataBadge extends StatelessWidget {
  const _StaleDataBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home-tools-prayer-stale-badge'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.gold.withValues(alpha: 0.14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.history_rounded,
            size: 14,
            color: AppColors.gold,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.camel.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownPill extends StatefulWidget {
  const _CountdownPill({
    required this.target,
    required this.textColor,
  });

  final DateTime target;
  final Color textColor;

  @override
  State<_CountdownPill> createState() => _CountdownPillState();
}

class _CountdownPillState extends State<_CountdownPill>
    with WidgetsBindingObserver {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _now = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant _CountdownPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target && mounted) {
      setState(() {
        _now = DateTime.now();
      });
    }
    _syncTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncTimer(refreshNow: true);
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopTimer();
    }
  }

  bool get _isVisibleInTree => TickerMode.valuesOf(context).enabled;

  bool get _isAppActive {
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    return lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
  }

  bool get _shouldRunTimer => _isVisibleInTree && _isAppActive;

  void _syncTimer({bool refreshNow = false}) {
    if (!_shouldRunTimer) {
      _stopTimer();
      return;
    }

    if (refreshNow && mounted) {
      setState(() {
        _now = DateTime.now();
      });
    }

    _startTimerIfNeeded();
  }

  void _startTimerIfNeeded() {
    if (_timer != null) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_shouldRunTimer) {
        _stopTimer();
        return;
      }

      setState(() {
        _now = DateTime.now();
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.target.difference(_now);
    final safe = remaining.isNegative ? Duration.zero : remaining;
    final formatted =
        '${safe.inHours.toString().padLeft(2, '0')}:${(safe.inMinutes % 60).toString().padLeft(2, '0')}:${(safe.inSeconds % 60).toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.gold.withValues(alpha: 0.12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timelapse_rounded,
            color: AppColors.gold,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            formatted,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
