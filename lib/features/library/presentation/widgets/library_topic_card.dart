import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/features/library/domain/library_topic.dart';

class LibraryTopicCard extends StatelessWidget {
  const LibraryTopicCard({
    super.key,
    required this.topic,
    required this.languageCode,
    required this.onTap,
  });

  final LibraryTopic topic;
  final String languageCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = topic.localizedTitle(languageCode);
    final description = topic.localizedDescription(languageCode);
    final titleColor = isDark ? AppColors.textDark : AppColors.textLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDarkNav
        : AppColors.camel.withValues(alpha: 0.08);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.22),
            ),
          ),
          child: Stack(
            children: [
              PositionedDirectional(
                top: 14,
                end: 12,
                child: Icon(
                  _iconForKey(topic.iconKey),
                  size: 44,
                  color: AppColors.gold.withValues(alpha: 0.12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _iconForKey(topic.iconKey),
                        color: AppColors.gold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${topic.references.length}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
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

  static IconData _iconForKey(String key) {
    switch (key) {
      case 'person':
        return Icons.person_rounded;
      case 'sailing':
        return Icons.sailing_rounded;
      case 'waves':
        return Icons.waves_rounded;
      case 'schedule':
        return Icons.schedule_rounded;
      case 'volunteer_activism':
        return Icons.volunteer_activism_rounded;
      case 'gavel':
        return Icons.gavel_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'hourglass_bottom':
        return Icons.hourglass_bottom_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }
}
