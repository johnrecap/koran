import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/progress_ring.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

/// Card showing a khatma with progress and basic schedule details.
class KhatmaCard extends StatelessWidget {
  const KhatmaCard({
    super.key,
    required this.khatma,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  final Khatma khatma;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final languageCode = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final daysRemaining = khatma.daysRemaining(now);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDarkNav : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: AppColors.camel.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              ProgressRing(
                progress: khatma.progress,
                label: l10n.memorizationHubProgressLabel,
                size: 70,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            khatma.title,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (khatma.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF4CAF50,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.memorizationKhatmaCompletedBadge,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.memorizationSurahProgress(
                        _formatNumber(khatma.completedSurahs, languageCode),
                        _formatNumber(114, languageCode),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (!khatma.isCompleted)
                      Text(
                        l10n.memorizationDaysRemaining(
                          _formatNumber(daysRemaining, languageCode),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: daysRemaining <= 3
                              ? const Color(0xFFFF9800)
                              : AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int value, String languageCode) {
    if (languageCode == 'ar') {
      return VerseMarker.toArabicNumerals(value);
    }

    return value.toString();
  }
}
