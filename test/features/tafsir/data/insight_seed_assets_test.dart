import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/tafsir/data/asbaab_data_source.dart';
import 'package:quran_kareem/features/tafsir/data/related_ayahs_data_source.dart';
import 'package:quran_kareem/features/tafsir/data/word_meaning_data_source.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundles the minimum word-meaning seed files for Wave 7', () async {
    final directory = Directory('assets/data/word_meanings');

    expect(await directory.exists(), isTrue);
    expect(File('${directory.path}/1.json').existsSync(), isTrue);
    expect(File('${directory.path}/2.json').existsSync(), isTrue);
    expect(File('${directory.path}/112.json').existsSync(), isTrue);

    final fatiha = jsonDecode(
      await File('${directory.path}/1.json').readAsString(),
    ) as Map<String, dynamic>;
    final baqarah = jsonDecode(
      await File('${directory.path}/2.json').readAsString(),
    ) as Map<String, dynamic>;
    final ikhlas = jsonDecode(
      await File('${directory.path}/112.json').readAsString(),
    ) as Map<String, dynamic>;

    expect((fatiha['ayahs'] as Map<String, dynamic>)['1'], isNotNull);
    expect((baqarah['ayahs'] as Map<String, dynamic>)['255'], isNotNull);
    expect((ikhlas['ayahs'] as Map<String, dynamic>)['1'], isNotNull);
  });

  test('bundles at least ten asbaab entries for validation', () async {
    final file = File('assets/data/asbaab_nuzul/asbaab.json');

    expect(await file.exists(), isTrue);

    final decoded =
        jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final entryCount = decoded.values
        .whereType<List<dynamic>>()
        .fold<int>(0, (count, entries) => count + entries.length);

    expect(entryCount, greaterThanOrEqualTo(10));
  });

  test('bundles at least twenty related-ayah references for validation',
      () async {
    final file = File('assets/data/related_ayahs/references.json');

    expect(await file.exists(), isTrue);

    final decoded =
        jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final referenceCount = decoded.values
        .whereType<List<dynamic>>()
        .fold<int>(0, (count, entries) => count + entries.length);

    expect(referenceCount, greaterThanOrEqualTo(20));
  });

  test('registers the Wave 7 asset directories in pubspec', () async {
    final pubspec = await File('pubspec.yaml').readAsString();

    expect(pubspec, contains('assets/data/word_meanings/'));
    expect(pubspec, contains('assets/data/asbaab_nuzul/'));
    expect(pubspec, contains('assets/data/related_ayahs/'));
  });

  test('seed assets round-trip through the live insight data sources',
      () async {
    final wordMeanings = await LocalWordMeaningDataSource().fetchForAyah(
      surahNumber: 1,
      ayahNumber: 1,
    );
    final asbaab = await LocalAsbaabDataSource().fetchForAyah(
      surahNumber: 2,
      ayahNumber: 158,
    );
    final relatedAyahs = await LocalRelatedAyahsDataSource().fetchForAyah(
      surahNumber: 2,
      ayahNumber: 255,
    );

    expect(wordMeanings, isA<InsightSectionLoaded<List<WordMeaningEntry>>>());
    expect(asbaab, isA<InsightSectionLoaded<List<AsbaabEntry>>>());
    expect(
      relatedAyahs,
      isA<InsightSectionLoaded<List<RelatedAyahEntry>>>(),
    );

    final wordEntries =
        (wordMeanings as InsightSectionLoaded<List<WordMeaningEntry>>).content;
    final asbaabEntries =
        (asbaab as InsightSectionLoaded<List<AsbaabEntry>>).content;
    final relatedEntries =
        (relatedAyahs as InsightSectionLoaded<List<RelatedAyahEntry>>).content;

    expect(wordEntries, isNotEmpty);
    expect(asbaabEntries, isNotEmpty);
    expect(relatedEntries, isNotEmpty);
  });
}
