import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/bismillah_header.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_marker.dart';

/// Page-by-page Quran view with swipe navigation.
/// Each page shows a chunk of verses that fit the screen.
class QuranPageView extends StatefulWidget {
  final List<Ayah> ayahs;
  final int surahNumber;
  final double fontSize;
  final ValueChanged<int>? onPageChanged;

  const QuranPageView({
    super.key,
    required this.ayahs,
    required this.surahNumber,
    this.fontSize = 22,
    this.onPageChanged,
  });

  @override
  State<QuranPageView> createState() => _QuranPageViewState();
}

class _QuranPageViewState extends State<QuranPageView> {
  late PageController _pageController;
  late List<List<Ayah>> _pages;

  @override
  void initState() {
    super.initState();
    _pages = _splitIntoPages(widget.ayahs);
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(QuranPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ayahs != widget.ayahs) {
      _pages = _splitIntoPages(widget.ayahs);
    }
  }

  /// Split ayahs into page-sized chunks (~10 verses per page).
  List<List<Ayah>> _splitIntoPages(List<Ayah> ayahs) {
    const versesPerPage = 8;
    final pages = <List<Ayah>>[];
    for (int i = 0; i < ayahs.length; i += versesPerPage) {
      final end = (i + versesPerPage > ayahs.length)
          ? ayahs.length
          : i + versesPerPage;
      pages.add(ayahs.sublist(i, end));
    }
    if (pages.isEmpty) pages.add([]);
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Column(
      children: [
        // Page content
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            reverse: true, // RTL: swipe right = next page
            itemCount: _pages.length,
            onPageChanged: (index) {
              widget.onPageChanged?.call(index);
            },
            itemBuilder: (context, pageIndex) {
              final pageAyahs = _pages[pageIndex];

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    // Bismillah on first page only
                    if (pageIndex == 0 &&
                        widget.surahNumber != 9 &&
                        widget.surahNumber != 1)
                      const BismillahHeader(),

                    // Quran text
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text.rich(
                        _buildVerseSpans(pageAyahs, textColor),
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Page indicator
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${VerseMarker.toArabicNumerals(_pages.length)} / ${VerseMarker.toArabicNumerals((_pageController.hasClients ? _pageController.page?.round() ?? 0 : 0) + 1)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textMuted : AppColors.textMuted,
                  fontFamily: 'Amiri',
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextSpan _buildVerseSpans(List<Ayah> ayahs, Color textColor) {
    final spans = <InlineSpan>[];
    for (final ayah in ayahs) {
      spans.add(TextSpan(
        text: ayah.text,
        style: TextStyle(
          fontFamily: 'ScheherazadeNew',
          fontSize: widget.fontSize,
          color: textColor,
          height: 2.0,
          letterSpacing: 0,
          wordSpacing: 2,
        ),
      ));
      spans.add(TextSpan(
        text: ' \uFD3F${VerseMarker.toArabicNumerals(ayah.ayahNumber)}\uFD3E ',
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: widget.fontSize * 0.7,
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
        ),
      ));
    }
    return TextSpan(children: spans);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
