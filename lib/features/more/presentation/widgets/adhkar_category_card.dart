import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';

class AdhkarCategoryCard extends StatelessWidget {
  const AdhkarCategoryCard({
    super.key,
    required this.categoryId,
    required this.title,
    required this.subtitle,
    required this.entryCountLabel,
    required this.onTap,
  });

  final String categoryId;
  final String title;
  final String subtitle;
  final String entryCountLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNav : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.16),
        ),
      ),
      child: InkWell(
        key: Key('adhkar-category-card-$categoryId'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      AppColors.camel.withValues(alpha: isDark ? 0.18 : 0.12),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isDark ? AppColors.textDark : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entryCountLabel,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
