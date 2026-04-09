import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/more/providers/more_providers.dart';
import 'package:quran_kareem/features/more/presentation/widgets/home_tools_icon_grid.dart';
import 'package:quran_kareem/features/more/presentation/widgets/prayer_times_hero_card.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/torn_paper_banner.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen>
    with WidgetsBindingObserver {
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
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final snapshotAsync = ref.watch(homePrayerSnapshotProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          TornPaperBanner(title: l10n.homeToolsTitle),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  snapshotAsync.when(
                    data: (snapshot) {
                      _schedulePrayerRefreshIfNeeded(snapshot);
                      return PrayerTimesHeroCard(
                        title: l10n.homeToolsPrayerTimes,
                        snapshot: snapshot,
                        nextPrayerLabel:
                            _prayerLabel(context, snapshot.nextPrayer),
                        openTrackerLabel: l10n.homeToolsOpenTracker,
                        onTap: () => context.push(
                          '/more/prayer-times',
                          extra: snapshot,
                        ),
                      );
                    },
                    loading: () => _MoreLoadingState(
                      message: l10n.homeToolsLoadingPrayerTimes,
                    ),
                    error: (error, stackTrace) => _MoreErrorState(
                      retryLabel: l10n.homeToolsRetry,
                      message: l10n.homeToolsPrayerError,
                      onRetry: () => ref.invalidate(homePrayerSnapshotProvider),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.homeToolsTitle,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  HomeToolsIconGrid(
                    prayerTimesLabel: l10n.homeToolsPrayerTimes,
                    qiblaLabel: l10n.homeToolsQibla,
                    azkarLabel: l10n.homeToolsAzkar,
                    analyticsLabel: l10n.analyticsTitle,
                    settingsLabel: l10n.homeToolsSettings,
                    onQiblaTap: () => context.push('/more/qibla'),
                    onAzkarTap: () => context.push('/more/adhkar'),
                    onAnalyticsTap: () => context.push('/analytics'),
                    onSettingsTap: () => context.push('/more/settings'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _prayerLabel(BuildContext context, PrayerType prayer) {
    final l10n = context.l10n;
    return switch (prayer) {
      PrayerType.fajr => l10n.prayerLabelFajr,
      PrayerType.dhuhr => l10n.prayerLabelDhuhr,
      PrayerType.asr => l10n.prayerLabelAsr,
      PrayerType.maghrib => l10n.prayerLabelMaghrib,
      PrayerType.isha => l10n.prayerLabelIsha,
    };
  }
}

class _MoreLoadingState extends StatelessWidget {
  const _MoreLoadingState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: AppColors.gold,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreErrorState extends StatelessWidget {
  const _MoreErrorState({
    required this.retryLabel,
    required this.message,
    required this.onRetry,
  });

  final String retryLabel;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.location_off_rounded,
            color: AppColors.gold,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}
