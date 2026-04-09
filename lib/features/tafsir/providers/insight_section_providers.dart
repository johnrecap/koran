import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_kareem/features/tafsir/data/asbaab_data_source.dart';
import 'package:quran_kareem/features/tafsir/data/related_ayahs_data_source.dart';
import 'package:quran_kareem/features/tafsir/data/word_meaning_data_source.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_state.dart';
import 'package:quran_kareem/features/tafsir/providers/tafsir_browser_providers.dart';

typedef InsightSectionProviderFamily =
    FutureProviderFamily<InsightSectionData, ReaderAyahInsightsTarget>;

final wordMeaningDataSourceProvider = Provider<WordMeaningDataSource>((ref) {
  return LocalWordMeaningDataSource();
});

final asbaabDataSourceProvider = Provider<AsbaabDataSource>((ref) {
  return LocalAsbaabDataSource();
});

final relatedAyahsDataSourceProvider = Provider<RelatedAyahsDataSource>((ref) {
  return LocalRelatedAyahsDataSource();
});

final wordMeaningSectionProvider =
    FutureProvider.family<InsightSectionData, ReaderAyahInsightsTarget>(
  (ref, target) {
    return ref.watch(wordMeaningDataSourceProvider).fetchForAyah(
      surahNumber: target.surahNumber,
      ayahNumber: target.ayahNumber,
    );
  },
);

final asbaabSectionProvider =
    FutureProvider.family<InsightSectionData, ReaderAyahInsightsTarget>(
  (ref, target) {
    return ref.watch(asbaabDataSourceProvider).fetchForAyah(
      surahNumber: target.surahNumber,
      ayahNumber: target.ayahNumber,
    );
  },
);

final relatedAyahsSectionProvider =
    FutureProvider.family<InsightSectionData, ReaderAyahInsightsTarget>(
  (ref, target) {
    return ref.watch(relatedAyahsDataSourceProvider).fetchForAyah(
      surahNumber: target.surahNumber,
      ayahNumber: target.ayahNumber,
    );
  },
);

final tafsirSectionProvider =
    FutureProvider.family<InsightSectionData, ReaderAyahInsightsTarget>(
  (ref, target) async {
    final state = await ref.watch(tafsirBrowserContentProvider(target).future);
    return switch (state) {
      TafsirBrowserLoadedContent() =>
        InsightSectionLoaded<TafsirBrowserLoadedContent>(state),
      TafsirBrowserSourceUnavailableContent() =>
        const InsightSectionUnavailable(),
      TafsirBrowserErrorContent(:final error) => InsightSectionError(error),
    };
  },
);

InsightSectionProviderFamily insightSectionProviderResolver(
  InsightSectionType type,
) {
  switch (type) {
    case InsightSectionType.tafsir:
      return tafsirSectionProvider;
    case InsightSectionType.wordMeaning:
      return wordMeaningSectionProvider;
    case InsightSectionType.asbaabAlNuzul:
      return asbaabSectionProvider;
    case InsightSectionType.relatedAyahs:
      return relatedAyahsSectionProvider;
  }
}
