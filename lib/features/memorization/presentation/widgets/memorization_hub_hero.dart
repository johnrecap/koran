import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/memorization/domain/memorization_hub_summary.dart';
import 'package:quran_kareem/features/memorization/presentation/widgets/progress_ring.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

class MemorizationHubHero extends StatelessWidget {
  const MemorizationHubHero({
    super.key,
    required this.summary,
    required this.onPrimaryAction,
  });

  final MemorizationHubSummary summary;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final subtitle = !summary.hasActiveKhatma
        ? l10n.memorizationHubNoActiveSubtitle
        : (summary.activeKhatmaSession == null
            ? l10n.memorizationHubStartSubtitle
            : l10n.memorizationHubResumeSubtitle);
    final primaryLabel = summary.hasActiveKhatma
        ? l10n.memorizationHubResume
        : l10n.memorizationKhatmasNew;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isDark ? 0.18 : 0.22),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.camel.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.memorizationHubHeroEyebrow,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.activeKhatma?.title ?? l10n.memorizationHubNoActiveTitle,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: onPrimaryAction,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: Icon(
                        summary.hasActiveKhatma
                            ? Icons.play_arrow_rounded
                            : Icons.add_rounded,
                      ),
                      label: Text(
                        primaryLabel,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ProgressRing(
                progress: summary.activeKhatma?.progress ?? 0,
                label: l10n.memorizationHubProgressLabel,
                size: 104,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MemorizationStatChip(
                value: _formatNumber(context, summary.activeKhatmaCount),
                label: l10n.memorizationHubStatActiveKhatmas,
                icon: Icons.auto_stories_rounded,
              ),
              _MemorizationStatChip(
                value: _formatNumber(context, summary.recentSessionCount),
                label: l10n.memorizationHubStatRecentSessions,
                icon: Icons.history_rounded,
              ),
              _MemorizationStatChip(
                value: _formatNumber(context, summary.manualBookmarkCount),
                label: l10n.memorizationHubStatBookmarks,
                icon: Icons.bookmark_rounded,
              ),
            ],
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

class _MemorizationStatChip extends StatelessWidget {
  const _MemorizationStatChip({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.camel.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
