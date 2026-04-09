import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';

class StoryIndexDataSource {
  StoryIndexDataSource({
    AssetBundle? bundle,
    this.assetPath = 'assets/stories/_index.json',
  }) : bundle = bundle ?? rootBundle;

  final AssetBundle bundle;
  final String assetPath;

  Future<List<QuranStory>> loadIndex() async {
    try {
      final raw = await bundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        throw const FormatException('Story index must decode to a list.');
      }

      return decoded.map((entry) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('Story index entries must be maps.');
        }
        return QuranStory.fromIndexJson(entry);
      }).toList(growable: false);
    } catch (error, stackTrace) {
      AppLogger.error('StoryIndexDataSource.loadIndex', error, stackTrace);
      return const <QuranStory>[];
    }
  }
}
