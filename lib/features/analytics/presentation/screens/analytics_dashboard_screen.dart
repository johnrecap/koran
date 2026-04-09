import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/analytics/presentation/widgets/analytics_empty_state.dart';
import 'package:quran_kareem/features/analytics/presentation/widgets/analytics_memorization_card.dart';
import 'package:quran_kareem/features/analytics/presentation/widgets/analytics_period_selector.dart';
import 'package:quran_kareem/features/analytics/presentation/widgets/analytics_prayer_card.dart';
import 'package:quran_kareem/features/analytics/presentation/widgets/analytics_reading_detail_card.dart';
import 'package:quran_kareem/features/analytics/presentation/widgets/analytics_reading_hero_card.dart';
import 'package:quran_kareem/features/analytics/presentation/widgets/analytics_top_surahs_card.dart';
import 'package:quran_kareem/features/analytics/providers/analytics_providers.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/memorization_hub_section.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/torn_paper_banner.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(analyticsDashboardSummaryProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          TornPaperBanner(title: l10n.analyticsTitle),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: summaryAsync.when(
                data: (summary) {
                  if (!summary.current.hasAnyData) {
                    return Column(
                      key: const Key('analytics-dashboard-screen'),
                      children: [
                        const AnalyticsPeriodSelector(),
                        const SizedBox(height: 16),
                        AnalyticsEmptyState(
                          key: const Key('analytics-overall-empty-state'),
                          icon: Icons.query_stats_rounded,
                          title: l10n.analyticsEmptyTitle,
                          subtitle: l10n.analyticsEmptySubtitle,
                        ),
                      ],
                    );
                  }

                  return Column(
                    key: const Key('analytics-dashboard-screen'),
                    children: [
                      const AnalyticsPeriodSelector(),
                      const SizedBox(height: 16),
                      AnalyticsReadingHeroCard(summary: summary),
                      MemorizationHubSection(
                        title: l10n.analyticsReadingSectionTitle,
                        subtitle: l10n.analyticsReadingSectionSubtitle,
                        child: AnalyticsReadingDetailCard(
                          snapshot: summary.current,
                        ),
                      ),
                      MemorizationHubSection(
                        title: l10n.analyticsTopSurahsTitle,
                        subtitle: l10n.analyticsTopSurahsSubtitle,
                        child: AnalyticsTopSurahsCard(
                          topSurahs: summary.current.reading.topSurahs,
                        ),
                      ),
                      MemorizationHubSection(
                        title: l10n.analyticsMemorizationSectionTitle,
                        subtitle: l10n.analyticsMemorizationSectionSubtitle,
                        child: AnalyticsMemorizationCard(
                          snapshot: summary.current,
                        ),
                      ),
                      MemorizationHubSection(
                        title: l10n.analyticsPrayerSectionTitle,
                        subtitle: l10n.analyticsPrayerSectionSubtitle,
                        child: AnalyticsPrayerCard(
                          snapshot: summary.current,
                          delta: summary.prayerCompletionDelta,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => _AnalyticsLoadingState(
                  message: l10n.analyticsLoading,
                ),
                error: (error, stackTrace) => _AnalyticsErrorState(
                  message: l10n.analyticsError,
                  retryLabel: l10n.homeToolsRetry,
                  onRetry: () {
                    ref.invalidate(analyticsDashboardSummaryProvider);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsLoadingState extends StatelessWidget {
  const _AnalyticsLoadingState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: AppColors.gold,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsErrorState extends StatelessWidget {
  const _AnalyticsErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('analytics-error-state'),
      children: [
        AnalyticsEmptyState(
          icon: Icons.insights_outlined,
          title: message,
          subtitle: context.l10n.analyticsEmptySubtitle,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onRetry,
          child: Text(retryLabel),
        ),
      ],
    );
  }
}
