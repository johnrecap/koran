import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/achievement_badge_tile.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/achievement_momentum_card.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/achievement_records_card.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/achievement_unlock_banner.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/achievements_hero_card.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/memorization_hub_section.dart';
import 'package:quran_kareem/features/memorization/providers/achievements_providers.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/torn_paper_banner.dart';

class AchievementsDashboardScreen extends ConsumerStatefulWidget {
  const AchievementsDashboardScreen({super.key});

  @override
  ConsumerState<AchievementsDashboardScreen> createState() =>
      _AchievementsDashboardScreenState();
}

class _AchievementsDashboardScreenState
    extends ConsumerState<AchievementsDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final snapshot = ref.watch(achievementsSnapshotProvider);
    final summary = ref.watch(achievementsSummaryProvider);
    final pendingUnlocks = ref.watch(achievementsPendingUnlocksProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppColors.surfaceDark,
                    const Color(0xFF241C15),
                  ]
                : [
                    AppColors.surfaceLight,
                    const Color(0xFFF6EEE0),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            TornPaperBanner(title: l10n.achievementsTitle),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  children: [
                    if (pendingUnlocks.isNotEmpty)
                      AchievementUnlockBanner(
                        summary: summary,
                        unlocks: pendingUnlocks,
                        onDismiss: () {
                          return ref
                              .read(
                                achievementsAcknowledgementsProvider.notifier,
                              )
                              .acknowledgeAll(
                                pendingUnlocks.map((unlock) => unlock.id),
                              );
                        },
                      ),
                    AchievementsHeroCard(summary: summary),
                    AchievementMomentumCard(summary: summary),
                    if (!snapshot.hasActivity) ...[
                      _AchievementsZeroState(
                        title: l10n.achievementsZeroTitle,
                        subtitle: l10n.achievementsZeroSubtitle,
                      ),
                      const SizedBox(height: 16),
                    ],
                    MemorizationHubSection(
                      title: l10n.achievementsBadgesTitle,
                      subtitle: l10n.achievementsBadgesSubtitle,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: summary.badges.length,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 260,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            mainAxisExtent: 236,
                          ),
                          itemBuilder: (context, index) {
                            return AchievementBadgeTile(
                              badge: summary.badges[index],
                            );
                          },
                        ),
                      ),
                    ),
                    MemorizationHubSection(
                      title: l10n.achievementsRecordsTitle,
                      subtitle: l10n.achievementsRecordsSubtitle,
                      child: AchievementRecordsCard(records: summary.records),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsZeroState extends StatelessWidget {
  const _AchievementsZeroState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDarkNav
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 34,
            color: AppColors.gold.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
