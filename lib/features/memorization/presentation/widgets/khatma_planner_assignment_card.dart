import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/domain/khatma_planner_summary.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class KhatmaPlannerAssignmentCard extends StatelessWidget {
  const KhatmaPlannerAssignmentCard({
    super.key,
    required this.summary,
  });

  final KhatmaPlannerSummary summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final assignmentRange =
        '${_formatNumber(context, summary.assignmentStartPage)} - ${_formatNumber(context, summary.assignmentEndPage)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.memorizationPlannerDailyAssignment,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            assignmentRange,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          _PlannerInfoRow(
            label: context.l10n.memorizationPlannerNextPage,
            value: _formatNumber(context, summary.nextPageToRead),
          ),
          const SizedBox(height: 8),
          _PlannerInfoRow(
            label: context.l10n.memorizationPlannerExpectedToday,
            value: _formatNumber(context, summary.expectedPageToday),
          ),
        ],
      ),
    );
  }

  String _formatNumber(BuildContext context, int value) {
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return VerseMarker.toArabicNumerals(value);
    }

    return value.toString();
  }
}

class _PlannerInfoRow extends StatelessWidget {
  const _PlannerInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}
