import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';

class LibraryAyahSearchResultTile extends StatelessWidget {
  const LibraryAyahSearchResultTile({
    super.key,
    required this.result,
    required this.query,
    required this.onTap,
  });

  final LibraryAyahSearchResult result;
  final String query;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textColor =
        (isDark ? AppColors.textDark : AppColors.textLight).withValues(
      alpha: 0.9,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDarkNav
                  : AppColors.camel.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.18),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          result.surahName,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                      ),
                      Text(
                        '${l10n.libraryAyahLabel} ${result.ayah.ayahNumber}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    key: const ValueKey<String>('library-search-result-text'),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'AmiriQuran',
                        fontSize: 24,
                        height: 1.8,
                        color: textColor,
                      ),
                      children: _buildHighlightedTextSpans(
                        text: result.ayah.text,
                        query: query,
                        highlightColor: AppColors.gold,
                        baseColor: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 16,
                        color: AppColors.gold.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${l10n.libraryPageLabel} ${result.ayah.page}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<InlineSpan> _buildHighlightedTextSpans({
    required String text,
    required String query,
    required Color highlightColor,
    required Color baseColor,
  }) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return <InlineSpan>[
        TextSpan(
          text: text,
          style: TextStyle(color: baseColor),
        ),
      ];
    }

    final spans = <InlineSpan>[];
    var start = 0;

    while (start < text.length) {
      final index = text.indexOf(normalizedQuery, start);
      if (index == -1) {
        spans.add(
          TextSpan(
            text: text.substring(start),
            style: TextStyle(color: baseColor),
          ),
        );
        break;
      }

      if (index > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, index),
            style: TextStyle(color: baseColor),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + normalizedQuery.length),
          style: TextStyle(
            color: highlightColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = index + normalizedQuery.length;
    }

    return spans;
  }
}
