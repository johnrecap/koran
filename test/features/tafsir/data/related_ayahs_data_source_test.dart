import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/tafsir/data/related_ayahs_data_source.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';

import 'fake_asset_bundle.dart';

void main() {
  test('returns loaded related ayahs when references exist', () async {
    final source = LocalRelatedAyahsDataSource(
      bundle: FakeAssetBundle(
        values: const {
          'assets/data/related_ayahs/references.json': '''
{
  "2:255": [
    {"surah": 3, "ayah": 18, "tag": "thematic", "snippet": "شهد الله"},
    {"surah": 112, "ayah": 1, "tag": "linguistic"}
  ]
}
''',
        },
      ),
    );

    final result = await source.fetchForAyah(surahNumber: 2, ayahNumber: 255);

    expect(result, isA<InsightSectionLoaded<List<RelatedAyahEntry>>>());
    final content =
        (result as InsightSectionLoaded<List<RelatedAyahEntry>>).content;
    expect(content, hasLength(2));
    expect(content.first.surahNumber, 3);
    expect(content.first.snippet, 'شهد الله');
    expect(content.last.tag, 'linguistic');
  });

  test('returns unavailable when there are no related references', () async {
    final source = LocalRelatedAyahsDataSource(
      bundle: FakeAssetBundle(
        values: const {
          'assets/data/related_ayahs/references.json': '''
{
  "2:286": [
    {"surah": 1, "ayah": 1, "tag": "thematic"}
  ]
}
''',
        },
      ),
    );

    final result = await source.fetchForAyah(surahNumber: 2, ayahNumber: 255);

    expect(result, isA<InsightSectionUnavailable>());
  });

  test('returns an error state when the related ayahs payload is malformed',
      () async {
    final source = LocalRelatedAyahsDataSource(
      bundle: FakeAssetBundle(
        values: const {
          'assets/data/related_ayahs/references.json': '{"2:255":"bad"}',
        },
      ),
    );

    final result = await source.fetchForAyah(surahNumber: 2, ayahNumber: 255);

    expect(result, isA<InsightSectionError>());
  });
}
