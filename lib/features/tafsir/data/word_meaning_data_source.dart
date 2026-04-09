import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';

abstract class WordMeaningDataSource {
  Future<InsightSectionData> fetchForAyah({
    required int surahNumber,
    required int ayahNumber,
  });
}

class LocalWordMeaningDataSource implements WordMeaningDataSource {
  LocalWordMeaningDataSource({
    AssetBundle? bundle,
    this.directoryPath = 'assets/data/word_meanings',
  }) : bundle = bundle ?? rootBundle;

  final AssetBundle bundle;
  final String directoryPath;

  @override
  Future<InsightSectionData> fetchForAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final assetPath = '$directoryPath/$surahNumber.json';

    try {
      final raw = await bundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Word meanings asset must decode to a map.',
        );
      }

      final ayahs = decoded['ayahs'];
      if (ayahs is! Map<String, dynamic>) {
        throw const FormatException(
          'Word meanings asset must contain an "ayahs" map.',
        );
      }

      final entryList = ayahs['$ayahNumber'];
      if (entryList == null) {
        return const InsightSectionUnavailable();
      }
      if (entryList is! List<dynamic>) {
        throw const FormatException('Word meanings ayah entry must be a list.');
      }
      if (entryList.isEmpty) {
        return const InsightSectionUnavailable();
      }

      final entries = entryList.map((entry) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException(
            'Word meanings list items must decode to maps.',
          );
        }
        return WordMeaningEntry.fromMap(entry);
      }).toList(growable: false);

      return InsightSectionLoaded<List<WordMeaningEntry>>(entries);
    } catch (error, stackTrace) {
      if (_isMissingAssetError(error)) {
        return const InsightSectionUnavailable();
      }

      AppLogger.error(
        'LocalWordMeaningDataSource.fetchForAyah',
        error,
        stackTrace,
      );
      return InsightSectionError(error);
    }
  }
}

bool _isMissingAssetError(Object error) {
  final message = error.toString();
  return message.contains('Unable to load asset') ||
      message.contains('Missing asset');
}
