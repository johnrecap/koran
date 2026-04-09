import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/features/library/domain/library_topic.dart';

abstract class LibraryTopicCatalogSource {
  Future<List<LibraryTopic>> loadTopics();
}

class AssetLibraryTopicCatalogSource implements LibraryTopicCatalogSource {
  AssetLibraryTopicCatalogSource({
    AssetBundle? bundle,
    this.assetPath = 'assets/topics/library_topics.json',
  }) : bundle = bundle ?? rootBundle;

  final AssetBundle bundle;
  final String assetPath;

  @override
  Future<List<LibraryTopic>> loadTopics() async {
    final raw = await bundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(LibraryTopic.fromMap)
        .toList(growable: false);
  }
}

abstract class LibraryTopicAyahResolver {
  Future<List<LibraryTopicReferenceResult>> resolveTopic(LibraryTopic topic);
}

class QuranDatabaseLibraryTopicAyahResolver implements LibraryTopicAyahResolver {
  const QuranDatabaseLibraryTopicAyahResolver();

  @override
  Future<List<LibraryTopicReferenceResult>> resolveTopic(
    LibraryTopic topic,
  ) async {
    final surahs = await QuranDatabase.getSurahs();
    final surahNames = <int, String>{
      for (final surah in surahs) surah.number: surah.nameArabic,
    };

    final results = await Future.wait(
      topic.references.map((reference) async {
        final ayah = await QuranDatabase.getAyah(
          reference.surahNumber,
          reference.ayahNumber,
        );
        if (ayah == null) {
          return null;
        }

        return LibraryTopicReferenceResult(
          ayah: ayah,
          surahName:
              surahNames[reference.surahNumber] ??
              reference.surahNumber.toString(),
        );
      }),
    );

    return results.whereType<LibraryTopicReferenceResult>().toList(
          growable: false,
        );
  }
}
