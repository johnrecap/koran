import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';

abstract class RelatedAyahsDataSource {
  Future<InsightSectionData> fetchForAyah({
    required int surahNumber,
    required int ayahNumber,
  });
}

class LocalRelatedAyahsDataSource implements RelatedAyahsDataSource {
  LocalRelatedAyahsDataSource({
    AssetBundle? bundle,
    this.assetPath = 'assets/data/related_ayahs/references.json',
  }) : bundle = bundle ?? rootBundle;

  final AssetBundle bundle;
  final String assetPath;

  @override
  Future<InsightSectionData> fetchForAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    try {
      final raw = await bundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Related ayahs payload must decode to a map.',
        );
      }

      final entryList = decoded['$surahNumber:$ayahNumber'];
      if (entryList == null) {
        return const InsightSectionUnavailable();
      }
      if (entryList is! List<dynamic>) {
        throw const FormatException(
          'Related ayah references must decode to a list.',
        );
      }
      if (entryList.isEmpty) {
        return const InsightSectionUnavailable();
      }

      final entries = entryList.map((entry) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException(
            'Related ayah list items must decode to maps.',
          );
        }
        return RelatedAyahEntry.fromMap(entry);
      }).toList(growable: false);

      return InsightSectionLoaded<List<RelatedAyahEntry>>(entries);
    } catch (error, stackTrace) {
      if (_isMissingAssetError(error)) {
        return const InsightSectionUnavailable();
      }

      AppLogger.error(
        'LocalRelatedAyahsDataSource.fetchForAyah',
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
