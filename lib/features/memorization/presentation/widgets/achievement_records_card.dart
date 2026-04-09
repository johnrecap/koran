import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/domain/achievement_dashboard_summary.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class AchievementRecordsCard extends StatelessWidget {
  const AchievementRecordsCard({
    super.key,
    required this.records,
  });

  final List<AchievementRecord> records;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 520;
          final itemWidth =
              wide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final record in records)
                SizedBox(
                  width: itemWidth,
                  child: _RecordTile(record: record),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.record,
  });

  final AchievementRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.camel.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.08 : 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForRecord(record.id),
              color: AppColors.gold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.value(record.labelKey),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatNumber(context, record.value),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForRecord(String id) {
    switch (id) {
      case 'best_streak_days':
        return Icons.local_fire_department_rounded;
      case 'tracked_minutes':
        return Icons.schedule_rounded;
      case 'completed_khatmas':
        return Icons.auto_stories_rounded;
      case 'reviewed_reviews':
        return Icons.repeat_rounded;
      case 'total_visits':
        return Icons.menu_book_rounded;
      default:
        return Icons.workspace_premium_outlined;
    }
  }

  String _formatNumber(BuildContext context, int value) {
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return VerseMarker.toArabicNumerals(value);
    }

    return value.toString();
  }
}
