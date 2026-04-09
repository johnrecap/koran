import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

/// Reading status for a surah in the current khatma
enum ReadingStatus {
  notRead, // ⭕ لم تُقرأ
  inProgress, // 🔄 قيد القراءة
  completed, // ✅ مقروءة
}

/// A surah tile showing reading status with tap-to-cycle.
/// Used in the reading tracker (حفظ القراءة) screen.
class ReadingSurahTile extends StatelessWidget {
  final Surah surah;
  final ReadingStatus status;
  final VoidCallback onTap;

  const ReadingSurahTile({
    super.key,
    required this.surah,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              // Surah number circle
              _buildNumberCircle(),
              const SizedBox(width: 12),

              // Surah name
              Expanded(
                child: Text(
                  surah.nameArabic,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),

              // Status badge
              _buildStatusBadge(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberCircle() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: Center(
        child: Text(
          VerseMarker.toArabicNumerals(surah.number),
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case ReadingStatus.completed:
        bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.15);
        textColor = const Color(0xFF4CAF50);
        label = 'مقروءة';
        icon = Icons.check_circle_rounded;
      case ReadingStatus.inProgress:
        bgColor = const Color(0xFFFF9800).withValues(alpha: 0.15);
        textColor = const Color(0xFFFF9800);
        label = 'قيد القراءة';
        icon = Icons.autorenew_rounded;
      case ReadingStatus.notRead:
        bgColor = isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05);
        textColor = AppColors.textMuted;
        label = 'لم تُقرأ';
        icon = Icons.radio_button_unchecked;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
