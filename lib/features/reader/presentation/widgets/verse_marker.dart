import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/utils/arabic_digits.dart';

/// Gold ornamental verse number marker ﴿١﴾
/// Used inline with Quran text to mark verse boundaries.
class VerseMarker extends StatelessWidget {
  final int verseNumber;
  final double size;

  const VerseMarker({
    super.key,
    required this.verseNumber,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    // Convert to Arabic-Indic numerals
    final arabicNumber = toArabicNumerals(verseNumber);

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.gold,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          arabicNumber,
          style: TextStyle(
            color: AppColors.gold,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Convert number to Arabic-Indic numerals (٠١٢٣٤٥٦٧٨٩)
  static String toArabicNumerals(int number) {
    return toArabicDigits(number);
  }
}
