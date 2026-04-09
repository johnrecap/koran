import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/spaced_review_tile.dart';
import 'package:quran_kareem/features/memorization/providers/spaced_review_providers.dart';

class ReviewQueueScreen extends ConsumerWidget {
  const ReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(spacedReviewQueueSummaryProvider);
    final now = ref.watch(spacedReviewNowProvider)();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.memorizationReviewsQueueTitle),
      ),
      body: !summary.hasActiveKhatma || !summary.hasItems
          ? _ReviewQueueEmptyState(
              title: context.l10n.memorizationReviewsQueueEmptyTitle,
              subtitle: context.l10n.memorizationReviewsQueueEmptySubtitle,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (summary.dueItems.isNotEmpty) ...[
                  FilledButton.icon(
                    onPressed: () {
                      _openReview(context, summary.dueItems.first.id);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(context.l10n.memorizationReviewsStart),
                  ),
                  const SizedBox(height: 16),
                ],
                if (summary.dueItems.isNotEmpty) ...[
                  _ReviewQueueSection(
                    title: context.l10n.memorizationReviewsDueSectionTitle,
                    items: summary.dueItems,
                    now: now,
                    onTap: (item) {
                      _openReview(context, item.id);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                if (summary.upcomingItems.isNotEmpty)
                  _ReviewQueueSection(
                    title: context.l10n.memorizationReviewsUpcomingSectionTitle,
                    items: summary.upcomingItems,
                    now: now,
                    onTap: (item) {
                      _openReview(context, item.id);
                    },
                  ),
              ],
            ),
    );
  }

  void _openReview(BuildContext context, String reviewId) {
    context.push('/memorization/reviews/$reviewId');
  }
}

class _ReviewQueueSection extends StatelessWidget {
  const _ReviewQueueSection({
    required this.title,
    required this.items,
    required this.now,
    required this.onTap,
  });

  final String title;
  final List<SpacedReviewItem> items;
  final DateTime now;
  final ValueChanged<SpacedReviewItem> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDarkNav : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: isDark ? 0.12 : 0.16),
            ),
          ),
          child: Column(
            children: [
              for (final item in items)
                SpacedReviewTile(
                  item: item,
                  now: now,
                  onTap: () {
                    onTap(item);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewQueueEmptyState extends StatelessWidget {
  const _ReviewQueueEmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.camel.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.14),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 14),
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
        ),
      ),
    );
  }
}
