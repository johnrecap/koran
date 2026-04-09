import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/tafsir/data/asbaab_data_source.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';

import 'fake_asset_bundle.dart';

void main() {
  test('returns loaded asbaab entries for an ayah when data exists', () async {
    final source = LocalAsbaabDataSource(
      bundle: FakeAssetBundle(
        values: const {
          'assets/data/asbaab_nuzul/asbaab.json': '''
{
  "2:255": [
    {"text": "سبب النزول الأول", "source": "الواحدي"},
    {"text": "سبب النزول الثاني", "source": "السيوطي", "narrator": "ابن عباس"}
  ]
}
''',
        },
      ),
    );

    final result = await source.fetchForAyah(surahNumber: 2, ayahNumber: 255);

    expect(result, isA<InsightSectionLoaded<List<AsbaabEntry>>>());
    final content = (result as InsightSectionLoaded<List<AsbaabEntry>>).content;
    expect(content, hasLength(2));
    expect(content.first.source, 'الواحدي');
    expect(content.last.narrator, 'ابن عباس');
  });

  test('returns unavailable when the ayah has no asbaab entries', () async {
    final source = LocalAsbaabDataSource(
      bundle: FakeAssetBundle(
        values: const {
          'assets/data/asbaab_nuzul/asbaab.json': '''
{
  "2:286": [
    {"text": "نص", "source": "الواحدي"}
  ]
}
''',
        },
      ),
    );

    final result = await source.fetchForAyah(surahNumber: 2, ayahNumber: 255);

    expect(result, isA<InsightSectionUnavailable>());
  });

  test('returns an error state when the asbaab payload is malformed', () async {
    final source = LocalAsbaabDataSource(
      bundle: FakeAssetBundle(
        values: const {
          'assets/data/asbaab_nuzul/asbaab.json': '{"2:255":"bad"}',
        },
      ),
    );

    final result = await source.fetchForAyah(surahNumber: 2, ayahNumber: 255);

    expect(result, isA<InsightSectionError>());
  });
}
