import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/stories/data/story_index_data_source.dart';
import 'package:quran_kareem/features/stories/domain/story_category.dart';

import 'fake_asset_bundle.dart';

void main() {
  test('loads story index metadata from the bundled catalog', () async {
    final source = StoryIndexDataSource(
      bundle: FakeAssetBundle(
        values: const {
          'assets/stories/_index.json': '''
[
  {
    "id": "adam",
    "file": "adam.json",
    "title_ar": "آدم",
    "title_en": "Adam",
    "category": "prophets",
    "icon_key": "user",
    "summary_ar": "summary ar",
    "summary_en": "summary en",
    "chapter_count": 10,
    "total_verses": 12,
    "estimated_reading_minutes": 20,
    "main_surahs_ar": ["البقرة"],
    "main_surahs_numbers": [2],
    "order": 1
  }
]
''',
        },
      ),
    );

    final stories = await source.loadIndex();

    expect(stories, hasLength(1));
    expect(stories.first.id, 'adam');
    expect(stories.first.file, 'adam.json');
    expect(stories.first.category, StoryCategory.prophets);
  });

  test('returns an empty list when the bundled index payload is malformed',
      () async {
    final source = StoryIndexDataSource(
      bundle: FakeAssetBundle(
        values: const {
          'assets/stories/_index.json': '{"not":"a list"}',
        },
      ),
    );

    final stories = await source.loadIndex();

    expect(stories, isEmpty);
  });
}
