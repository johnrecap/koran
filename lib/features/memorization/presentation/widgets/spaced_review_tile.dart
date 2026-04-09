import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/domain/spaced_review_schedule_policy.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class SpacedReviewTile extends StatelessWidget {
  const SpacedReviewTile({
    super.key,
    required this.item,
    required this.now,
    this.onTap,
  });

  final SpacedReviewItem item;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.surfaceDarkNav
                    : AppColors.camel.withValues(alpha: 0.1),
              ),
              child: const Center(
                child: Icon(
                  Icons.schedule_rounded,
                  color: AppColors.gold,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.khatmaTitle,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${context.l10n.memorizationReviewsPageRange(
                      _formatNumber(
                        item.startPage,
                        Localizations.localeOf(context).languageCode,
                      ),
                      _formatNumber(
                        item.endPage,
                        Localizations.localeOf(context).languageCode,
                      ),
                    )} - ${_formatRelativeLabel(context, now, item.nextReviewAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_left,
                color: AppColors.textMuted.withValues(alpha: 0.5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

String formatSpacedReviewRelativeLabel(
  BuildContext context,
  DateTime now,
  DateTime target,
) {
  final languageCode = Localizations.localeOf(context).languageCode;
  final l10n = context.l10n;
  final offset = SpacedReviewSchedulePolicy.relativeDayOffset(
    now: now,
    target: target,
  );

  if (offset <= -1) {
    return l10n.memorizationReviewsOverdueDays(
      _formatNumber(offset.abs(), languageCode),
    );
  }
  if (offset == 0) {
    return l10n.memorizationReviewsToday;
  }
  if (offset == 1) {
    return l10n.memorizationReviewsTomorrow;
  }

  return l10n.memorizationReviewsInDays(
    _formatNumber(offset, languageCode),
  );
}

String _formatRelativeLabel(BuildContext context, DateTime now, DateTime target) {
  return formatSpacedReviewRelativeLabel(context, now, target);
}

String _formatNumber(int value, String languageCode) {
  if (languageCode == 'ar') {
    return VerseMarker.toArabicNumerals(value);
  }

  return value.toString();
}
