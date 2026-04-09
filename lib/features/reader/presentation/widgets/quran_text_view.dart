import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

/// Displays Quran text with inline verse markers.
/// Optimized: renders each ayah as a separate widget for lazy building.
/// Supports long-press on verse text → action menu callback.
/// Supports tap on verse number → manual bookmark callback.
class QuranTextView extends StatelessWidget {
  final List<Ayah> ayahs;
  final double fontSize;
  final void Function(Ayah ayah)? onVerseLongPress;
  final void Function(Ayah ayah)? onVerseNumberTap;
  final bool Function(int surahNumber, int ayahNumber)? isBookmarked;

  const QuranTextView({
    super.key,
    required this.ayahs,
    this.fontSize = 22,
    this.onVerseLongPress,
    this.onVerseNumberTap,
    this.isBookmarked,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < ayahs.length; i++)
              _AyahWidget(
                key: ValueKey('${ayahs[i].surahNumber}_${ayahs[i].ayahNumber}'),
                ayah: ayahs[i],
                fontSize: fontSize,
                textColor: textColor,
                bookmarked: isBookmarked?.call(
                        ayahs[i].surahNumber, ayahs[i].ayahNumber) ??
                    false,
                onLongPress: onVerseLongPress,
                onNumberTap: onVerseNumberTap,
              ),
          ],
        ),
      ),
    );
  }
}

/// Individual ayah widget — lightweight, only rebuilds when its own data changes.
class _AyahWidget extends StatelessWidget {
  final Ayah ayah;
  final double fontSize;
  final Color textColor;
  final bool bookmarked;
  final void Function(Ayah)? onLongPress;
  final void Function(Ayah)? onNumberTap;

  const _AyahWidget({
    super.key,
    required this.ayah,
    required this.fontSize,
    required this.textColor,
    required this.bookmarked,
    this.onLongPress,
    this.onNumberTap,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          // Verse text
          TextSpan(
            text: ayah.text,
            style: TextStyle(
              fontFamily: 'ScheherazadeNew',
              fontSize: fontSize,
              color: textColor,
              height: 2.0,
              letterSpacing: 0,
              wordSpacing: 2,
            ),
            recognizer: onLongPress != null
                ? (LongPressGestureRecognizer()
                  ..onLongPress = () => onLongPress!(ayah))
                : null,
          ),
          // Verse number marker
          TextSpan(
            text:
                ' \uFD3F${VerseMarker.toArabicNumerals(ayah.ayahNumber)}\uFD3E ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: fontSize * 0.7,
              color: bookmarked ? Colors.white : AppColors.gold,
              fontWeight: FontWeight.bold,
              backgroundColor:
                  bookmarked ? AppColors.gold : Colors.transparent,
            ),
            recognizer: onNumberTap != null
                ? (TapGestureRecognizer()
                  ..onTap = () => onNumberTap!(ayah))
                : null,
          ),
        ],
      ),
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
    );
  }
}
