import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

/// Tile showing a single reading session entry.
class SessionTile extends StatelessWidget {
  const SessionTile({
    super.key,
    required this.session,
    required this.onTap,
  });

  final ReadingSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final languageCode = Localizations.localeOf(context).languageCode;

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
        child: Directionality(
          textDirection: TextDirection.rtl,
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
                    Icons.menu_book_rounded,
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
                      session.surahName,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.memorizationAyahValue(_formatNumber(session.ayahNumber, languageCode))} - '
                      '${_formatDate(context, session.timestamp, languageCode)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (session.durationMinutes > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l10n.memorizationSessionDurationMinutes(
                      _formatNumber(session.durationMinutes, languageCode),
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_left,
                color: AppColors.textMuted.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(
    BuildContext context,
    DateTime timestamp,
    String languageCode,
  ) {
    final l10n = context.l10n;
    final difference = DateTime.now().difference(timestamp);

    if (difference.inMinutes < 60) {
      return l10n.memorizationMinutesAgo(
        _formatNumber(difference.inMinutes, languageCode),
      );
    }
    if (difference.inHours < 24) {
      return l10n.memorizationHoursAgo(
        _formatNumber(difference.inHours, languageCode),
      );
    }
    if (difference.inDays < 7) {
      return l10n.memorizationDaysAgo(
        _formatNumber(difference.inDays, languageCode),
      );
    }

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  String _formatNumber(int value, String languageCode) {
    if (languageCode == 'ar') {
      return VerseMarker.toArabicNumerals(value);
    }

    return value.toString();
  }
}
