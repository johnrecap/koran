import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/stories/data/story_data_source_exception.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';

class StoryDetailDataSource {
  StoryDetailDataSource({
    AssetBundle? bundle,
    this.directoryPath = 'assets/stories',
  }) : bundle = bundle ?? rootBundle;

  final AssetBundle bundle;
  final String directoryPath;

  Future<QuranStory> loadStory(String file) async {
    final assetPath = '$directoryPath/$file';

    try {
      final raw = await bundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        throw const FormatException('Story detail must decode to a list.');
      }
      if (decoded.isEmpty) {
        throw const FormatException('Story detail list cannot be empty.');
      }

      final firstEntry = decoded.first;
      if (firstEntry is! Map<String, dynamic>) {
        throw const FormatException('Story detail entries must be maps.');
      }

      return QuranStory.fromDetailJson(firstEntry);
    } catch (error, stackTrace) {
      AppLogger.error('StoryDetailDataSource.loadStory', error, stackTrace);
      throw StoryDataSourceException(
        assetPath: assetPath,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
