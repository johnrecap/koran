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

/// Individual ayah widget — manages gesture recognizer lifecycle properly.
/// Converted to StatefulWidget to create recognizers once and dispose them,
/// preventing native resource leaks on long surahs.
class _AyahWidget extends StatefulWidget {
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
  State<_AyahWidget> createState() => _AyahWidgetState();
}

class _AyahWidgetState extends State<_AyahWidget> {
  LongPressGestureRecognizer? _longPressRecognizer;
  TapGestureRecognizer? _tapRecognizer;

  @override
  void initState() {
    super.initState();
    _syncRecognizers();
  }

  @override
  void didUpdateWidget(covariant _AyahWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onLongPress != widget.onLongPress ||
        oldWidget.onNumberTap != widget.onNumberTap ||
        oldWidget.ayah != widget.ayah) {
      _disposeRecognizers();
      _syncRecognizers();
    }
  }

  void _syncRecognizers() {
    if (widget.onLongPress != null) {
      _longPressRecognizer = LongPressGestureRecognizer()
        ..onLongPress = () => widget.onLongPress!(widget.ayah);
    }
    if (widget.onNumberTap != null) {
      _tapRecognizer = TapGestureRecognizer()
        ..onTap = () => widget.onNumberTap!(widget.ayah);
    }
  }

  void _disposeRecognizers() {
    _longPressRecognizer?.dispose();
    _longPressRecognizer = null;
    _tapRecognizer?.dispose();
    _tapRecognizer = null;
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          // Verse text
          TextSpan(
            text: widget.ayah.text,
            style: TextStyle(
              fontFamily: 'ScheherazadeNew',
              fontSize: widget.fontSize,
              color: widget.textColor,
              height: 2.0,
              letterSpacing: 0,
              wordSpacing: 2,
            ),
            recognizer: _longPressRecognizer,
          ),
          // Verse number marker
          TextSpan(
            text:
                ' \uFD3F${VerseMarker.toArabicNumerals(widget.ayah.ayahNumber)}\uFD3E ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: widget.fontSize * 0.7,
              color: widget.bookmarked ? Colors.white : AppColors.gold,
              fontWeight: FontWeight.bold,
              backgroundColor:
                  widget.bookmarked ? AppColors.gold : Colors.transparent,
            ),
            recognizer: _tapRecognizer,
          ),
        ],
      ),
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
    );
  }
}
