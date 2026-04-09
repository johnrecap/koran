import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';

/// Decorative Bismillah header — "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
/// with elongated decorative lines on both sides.
/// Shown at the top of every Surah except At-Tawbah (surah 9).
class BismillahHeader extends StatelessWidget {
  const BismillahHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          // Decorative line
          Row(
            children: [
              Expanded(child: _decorLine(isDark)),
              const SizedBox(width: 12),
              // Bismillah text
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(width: 12),
              Expanded(child: _decorLine(isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _decorLine(bool isDark) {
    return Container(
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.gold.withValues(alpha: 0.6),
            AppColors.gold,
            AppColors.gold.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
