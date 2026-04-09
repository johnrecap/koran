import 'package:flutter/foundation.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_state.dart';
import 'package:quran_library/quran_library.dart';

abstract class TafsirBrowserAyahLookup {
  Future<Ayah?> findAyah({
    required int surahNumber,
    required int ayahNumber,
  });
}

class QuranDatabaseTafsirBrowserAyahLookup implements TafsirBrowserAyahLookup {
  const QuranDatabaseTafsirBrowserAyahLookup();

  @override
  Future<Ayah?> findAyah({
    required int surahNumber,
    required int ayahNumber,
  }) {
    return QuranDatabase.getAyah(surahNumber, ayahNumber);
  }
}

abstract class TafsirBrowserRepository {
  Future<List<TafsirBrowserSourceOption>> fetchSourceOptions();

  Future<TafsirBrowserContentState> fetchContent({
    required ReaderAyahInsightsTarget target,
  });

  Future<void> selectSource({
    required String sourceId,
    required int pageNumber,
  });
}

class PackageTafsirBrowserRepository implements TafsirBrowserRepository {
  PackageTafsirBrowserRepository({
    TafsirCtrl? controller,
    QuranCtrl? quranCtrl,
  })  : _controller = controller ?? TafsirCtrl.instance,
        _quranCtrl = quranCtrl ?? QuranCtrl.instance;

  final TafsirCtrl _controller;
  final QuranCtrl _quranCtrl;

  @override
  Future<List<TafsirBrowserSourceOption>> fetchSourceOptions() async {
    await _controller.initTafsir();

    return List<TafsirBrowserSourceOption>.generate(
      _controller.tafsirAndTranslationsItems.length,
      (index) {
        final item = _controller.tafsirAndTranslationsItems[index];
        return TafsirBrowserSourceOption(
          id: _sourceId(item),
          title: item.name,
          bookName: item.bookName,
          isTranslation: item.isTranslation,
          isSelected: _controller.radioValue.value == index,
          isDownloaded: _isDownloaded(index),
        );
      },
      growable: false,
    );
  }

  @override
  Future<TafsirBrowserContentState> fetchContent({
    required ReaderAyahInsightsTarget target,
  }) async {
    await _controller.initTafsir();
    final selectedIndex = _controller.radioValue.value;
    if (!_isDownloaded(selectedIndex)) {
      return const TafsirBrowserSourceUnavailableContent();
    }

    try {
      final verseText = _resolveVerseText(target);
      final selected = _controller.selectedTafsir;
      if (selected.isTranslation) {
        await _controller.fetchTranslate();
        final translation = _controller.getTranslationForAyah(
          target.surahNumber,
          target.ayahNumber,
        );
        final bodyText = translation?.cleanText.trim() ?? '';
        final footnotes = translation?.orderedFootnotesWithNumbers
                .map(
                  (entry) => TafsirBrowserFootnote(
                    number: entry.key,
                    text: entry.value.value.trim(),
                  ),
                )
                .where((entry) => entry.text.isNotEmpty)
                .toList(growable: false) ??
            const <TafsirBrowserFootnote>[];
        if (bodyText.isEmpty && footnotes.isEmpty) {
          return const TafsirBrowserSourceUnavailableContent();
        }

        return TafsirBrowserLoadedContent(
          verseText: verseText,
          bodyText: bodyText,
          footnotes: footnotes,
        );
      }

      await _controller.fetchData(target.pageNumber);
      final entries = await _controller.fetchTafsirAyah(target.ayahUQNumber);
      final bodyText = entries
          .map((entry) => entry.tafsirText.trim())
          .where((entry) => entry.isNotEmpty)
          .join('\n\n');
      if (bodyText.isEmpty) {
        return const TafsirBrowserSourceUnavailableContent();
      }

      return TafsirBrowserLoadedContent(
        verseText: verseText,
        bodyText: bodyText,
      );
    } catch (error) {
      return TafsirBrowserErrorContent(error: error);
    }
  }

  @override
  Future<void> selectSource({
    required String sourceId,
    required int pageNumber,
  }) async {
    await _controller.initTafsir();

    final selectedIndex = _controller.tafsirAndTranslationsItems.indexWhere(
      (item) => _sourceId(item) == sourceId,
    );
    if (selectedIndex < 0) {
      return;
    }
    if (!_isDownloaded(selectedIndex)) {
      return;
    }

    await _controller.handleRadioValueChanged(
      selectedIndex,
      pageNumber: pageNumber,
    );
  }

  bool _isDownloaded(int index) {
    if (kIsWeb) {
      return true;
    }

    final defaultTafsirIndex =
        _controller.tafsirAndTranslationsItems.indexWhere(
      (item) => item.databaseName == 'saadi.json.gz',
    );
    final translationIndex = _controller.translationsStartIndex;
    if (index == defaultTafsirIndex || index == translationIndex) {
      return true;
    }

    return _controller.tafsirDownloadStatus.value[index] == true ||
        _controller.tafsirDownloadIndexList.contains(index);
  }

  String _resolveVerseText(ReaderAyahInsightsTarget target) {
    for (final surah in _quranCtrl.surahs) {
      if (surah.surahNumber != target.surahNumber) {
        continue;
      }

      for (final ayah in surah.ayahs) {
        if (ayah.ayahNumber == target.ayahNumber) {
          return ayah.text;
        }
      }
    }

    return '';
  }

  String _sourceId(TafsirNameModel item) {
    if (item.isTranslation) {
      return 'translation:${item.fileName}';
    }

    return 'tafsir:${item.databaseName}';
  }
}
