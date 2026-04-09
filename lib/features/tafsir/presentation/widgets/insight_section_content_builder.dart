import 'package:flutter/material.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_config.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_state.dart';
import 'package:quran_kareem/features/tafsir/presentation/widgets/asbaab_section_view.dart';
import 'package:quran_kareem/features/tafsir/presentation/widgets/related_ayahs_section_view.dart';
import 'package:quran_kareem/features/tafsir/presentation/widgets/tafsir_browser_content_view.dart';
import 'package:quran_kareem/features/tafsir/presentation/widgets/word_meaning_section_view.dart';

typedef InsightSectionAyahNavigator = void Function(int surahNumber, int ayahNumber);

Widget buildInsightSectionChild({
  required BuildContext context,
  required InsightSectionConfig config,
  required InsightSectionData data,
  required InsightSectionAyahNavigator onNavigateToAyah,
}) {
  if (data is! InsightSectionLoaded) {
    return const SizedBox.shrink();
  }

  switch (config.type) {
    case InsightSectionType.tafsir:
      return TafsirBrowserContentView.section(
        content: data.content as TafsirBrowserLoadedContent,
      );
    case InsightSectionType.wordMeaning:
      return WordMeaningSectionView(
        entries: List<WordMeaningEntry>.from(data.content as List),
      );
    case InsightSectionType.asbaabAlNuzul:
      return AsbaabSectionView(
        entries: List<AsbaabEntry>.from(data.content as List),
      );
    case InsightSectionType.relatedAyahs:
      return RelatedAyahsSectionView(
        entries: List<RelatedAyahEntry>.from(data.content as List),
        onTap: (entry) => onNavigateToAyah(entry.surahNumber, entry.ayahNumber),
      );
  }
}
