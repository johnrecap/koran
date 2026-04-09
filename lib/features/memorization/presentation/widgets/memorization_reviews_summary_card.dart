import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/domain/spaced_review_queue_summary.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/spaced_review_tile.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class MemorizationReviewsSummaryCard extends StatelessWidget {
  const MemorizationReviewsSummaryCard({
    super.key,
    required this.summary,
    required this.now,
    required this.onStartReviews,
  });

  final SpacedReviewQueueSummary summary;
  final DateTime now;
  final VoidCallback onStartReviews;

  @override
  Widget build(BuildContext context) {
    if (!summary.hasActiveKhatma || !summary.hasItems) {
      return _MemorizationReviewsEmptyState(
        subtitle: context.l10n.memorizationReviewsQueueEmptySubtitle,
      );
    }

    final highlightedItem = summary.highlightedItem!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final dueCount = context.l10n.memorizationReviewsDueCount(
      _formatNumber(summary.dueCount, languageCode),
    );
    final nextLabel = formatSpacedReviewRelativeLabel(
      context,
      now,
      highlightedItem.nextReviewAt,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dueCount,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${context.l10n.memorizationReviewsNextReview}: $nextLabel',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onStartReviews,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(context.l10n.memorizationReviewsStart),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
        SpacedReviewTile(
          item: highlightedItem,
          now: now,
          onTap: onStartReviews,
        ),
      ],
    );
  }
}

class _MemorizationReviewsEmptyState extends StatelessWidget {
  const _MemorizationReviewsEmptyState({
    required this.subtitle,
  });

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.camel.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.16),
              ),
              child: const Icon(
                Icons.schedule_rounded,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatNumber(int value, String languageCode) {
  if (languageCode == 'ar') {
    return VerseMarker.toArabicNumerals(value);
  }

  return value.toString();
}
