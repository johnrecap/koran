import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/stories/data/story_data_source_exception.dart';
import 'package:quran_kareem/features/stories/data/story_detail_data_source.dart';

import 'fake_asset_bundle.dart';

void main() {
  test('loads a full story from the bundled detail file', () async {
    final source = StoryDetailDataSource(
      bundle: FakeAssetBundle(
        values: const {
          'assets/stories/adam.json': '''
[
  {
    "id": "adam",
    "title_ar": "آدم",
    "title_en": "Adam",
    "category": "prophets",
    "icon_key": "user",
    "summary_ar": "summary ar",
    "summary_en": "summary en",
    "estimated_reading_minutes": 20,
    "main_surahs_ar": ["البقرة"],
    "main_surahs_numbers": [2],
    "chapters": [
      {
        "id": "ch1",
        "order": 1,
        "title_ar": "chapter",
        "title_en": "chapter",
        "narrative_ar": "narrative",
        "lesson_ar": "lesson ar",
        "lesson_en": "lesson en",
        "verses": [
          {
            "surah": 2,
            "ayah_start": 30,
            "ayah_end": 30,
            "text_ar": "verse",
            "context_ar": "context"
          }
        ]
      }
    ]
  }
]
''',
        },
      ),
    );

    final story = await source.loadStory('adam.json');

    expect(story.id, 'adam');
    expect(story.chapterCount, 1);
    expect(story.totalVerses, 1);
    expect(story.chapters, hasLength(1));
  });

  test('throws a typed exception when the detail payload is malformed',
      () async {
    final source = StoryDetailDataSource(
      bundle: FakeAssetBundle(
        values: const {
          'assets/stories/adam.json': '{"not":"a list"}',
        },
      ),
    );

    expect(
      () => source.loadStory('adam.json'),
      throwsA(
        isA<StoryDataSourceException>().having(
          (error) => error.assetPath,
          'assetPath',
          'assets/stories/adam.json',
        ),
      ),
    );
  });
}
