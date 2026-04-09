import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

/// A single Surah tile in the Surah List.
/// Shows surah number in gold circle, Arabic name, ayah count, and revelation type.
class SurahTile extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const SurahTile({
    super.key,
    required this.surah,
    required this.onTap,
  });

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
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              // Surah number in gold circle
              _buildNumberCircle(),
              const SizedBox(width: 14),

              // Surah info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Surah name
                    Text(
                      surah.nameArabic,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Ayah count + revelation type
                    Text(
                      'آيات: ${VerseMarker.toArabicNumerals(surah.ayahCount)} | ${_revelationLabel(surah.revelationType)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),

              // Chevron
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

  Widget _buildNumberCircle() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.gold,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          VerseMarker.toArabicNumerals(surah.number),
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _revelationLabel(String type) {
    switch (type.toLowerCase()) {
      case 'meccan':
      case 'makkah':
      case 'mecca':
        return 'مكية';
      case 'medinan':
      case 'madinah':
      case 'medina':
        return 'مدنية';
      default:
        return type;
    }
  }
}
