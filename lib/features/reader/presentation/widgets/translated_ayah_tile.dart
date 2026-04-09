import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/ayah_translation.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_presentation_policy.dart';

class TranslatedAyahTile extends StatelessWidget {
  const TranslatedAyahTile({
    super.key,
    required this.ayah,
    required this.translation,
    required this.arabicFontSize,
    required this.translationFallbackText,
    required this.palette,
    this.isTarget = false,
    this.onLongPress,
  });

  final Ayah ayah;
  final AyahTranslation? translation;
  final double arabicFontSize;
  final String translationFallbackText;
  final ReaderNightPalette palette;
  final bool isTarget;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final borderColor = isTarget
        ? AppColors.gold
        : palette.cardBorderColor;
    final translationText = translation?.text ?? translationFallbackText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onLongPress: onLongPress,
        child: Ink(
          decoration: BoxDecoration(
            color: palette.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: palette.useDarkReaderLibrary ? 0.20 : 0.06,
                ),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        ayah.ayahNumber.toString(),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  ayah.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'ScheherazadeNew',
                    fontSize: arabicFontSize,
                    height: 1.9,
                    color: palette.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  translationText,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: palette.mutedTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
