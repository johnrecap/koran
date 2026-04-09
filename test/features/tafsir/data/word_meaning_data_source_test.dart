import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/tafsir/data/word_meaning_data_source.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';

import 'fake_asset_bundle.dart';

void main() {
  test('returns loaded word meanings for an ayah when bundled data exists',
      () async {
    final source = LocalWordMeaningDataSource(
      bundle: FakeAssetBundle(
        values: const {
          'assets/data/word_meanings/2.json': '''
{
  "ayahs": {
    "255": [
      {"word": "الله", "meaning": "Allah", "root": "اله"},
      {"word": "لا", "meaning": "not"}
    ]
  }
}
''',
        },
      ),
    );

    final result = await source.fetchForAyah(surahNumber: 2, ayahNumber: 255);

    expect(result, isA<InsightSectionLoaded<List<WordMeaningEntry>>>());
    final content =
        (result as InsightSectionLoaded<List<WordMeaningEntry>>).content;
    expect(content, hasLength(2));
    expect(content.first.word, 'الله');
    expect(content.first.meaning, 'Allah');
    expect(content.first.root, 'اله');
  });

  test('returns unavailable when the ayah key is missing', () async {
    final source = LocalWordMeaningDataSource(
      bundle: FakeAssetBundle(
        values: const {
          'assets/data/word_meanings/2.json': '''
{
  "ayahs": {
    "1": [
      {"word": "الم", "meaning": "Alif Lam Mim"}
    ]
  }
}
''',
        },
      ),
    );

    final result = await source.fetchForAyah(surahNumber: 2, ayahNumber: 255);

    expect(result, isA<InsightSectionUnavailable>());
  });

  test('returns unavailable when the asset file is missing', () async {
    final source = LocalWordMeaningDataSource(bundle: FakeAssetBundle());

    final result = await source.fetchForAyah(surahNumber: 2, ayahNumber: 255);

    expect(result, isA<InsightSectionUnavailable>());
  });

  test('returns an error state when the bundled payload is malformed',
      () async {
    final source = LocalWordMeaningDataSource(
      bundle: FakeAssetBundle(
        values: const {
          'assets/data/word_meanings/2.json': '{"ayahs":"bad"}',
        },
      ),
    );

    final result = await source.fetchForAyah(surahNumber: 2, ayahNumber: 255);

    expect(result, isA<InsightSectionError>());
  });
}
