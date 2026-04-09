import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/stories/domain/quran_story.dart';
import 'package:quran_kareem/features/stories/domain/story_category.dart';

void main() {
  test('parses an index entry as metadata only', () {
    final story = QuranStory.fromIndexJson(const <String, dynamic>{
      'id': 'adam',
      'file': 'adam.json',
      'title_ar': 'آدم',
      'title_en': 'Adam',
      'category': 'prophets',
      'icon_key': 'user',
      'summary_ar': 'summary ar',
      'summary_en': 'summary en',
      'chapter_count': 10,
      'total_verses': 12,
      'estimated_reading_minutes': 20,
      'main_surahs_ar': <String>['البقرة'],
      'main_surahs_numbers': <int>[2],
      'order': 1,
    });

    expect(story.id, 'adam');
    expect(story.file, 'adam.json');
    expect(story.category, StoryCategory.prophets);
    expect(story.chapterCount, 10);
    expect(story.totalVerses, 12);
    expect(story.order, 1);
    expect(story.chapters, isNull);
  });

  test('parses a detail entry and derives missing metadata from chapters', () {
    final story = QuranStory.fromDetailJson(const <String, dynamic>{
      'id': 'adam',
      'title_ar': 'آدم',
      'title_en': 'Adam',
      'category': 'prophets',
      'icon_key': 'user',
      'summary_ar': 'summary ar',
      'summary_en': 'summary en',
      'estimated_reading_minutes': 20,
      'main_surahs_ar': <String>['البقرة'],
      'main_surahs_numbers': <int>[2],
      'chapters': <Map<String, dynamic>>[
        {
          'id': 'ch1',
          'order': 1,
          'title_ar': 'title 1',
          'title_en': 'title 1',
          'narrative_ar': 'narrative 1',
          'lesson_ar': 'lesson 1',
          'lesson_en': 'lesson 1',
          'verses': <Map<String, dynamic>>[
            {
              'surah': 2,
              'ayah_start': 30,
              'ayah_end': 30,
              'text_ar': 'verse 1',
              'context_ar': 'context 1',
            },
          ],
        },
        {
          'id': 'ch2',
          'order': 2,
          'title_ar': 'title 2',
          'title_en': 'title 2',
          'narrative_ar': 'narrative 2',
          'lesson_ar': 'lesson 2',
          'lesson_en': 'lesson 2',
          'verses': <Map<String, dynamic>>[
            {
              'surah': 2,
              'ayah_start': 31,
              'ayah_end': 31,
              'text_ar': 'verse 2',
              'context_ar': 'context 2',
            },
            {
              'surah': 2,
              'ayah_start': 32,
              'ayah_end': 33,
              'text_ar': 'verse 3',
              'context_ar': 'context 3',
            },
          ],
        },
      ],
    });

    expect(story.id, 'adam');
    expect(story.file, isNull);
    expect(story.order, isNull);
    expect(story.chapterCount, 2);
    expect(story.totalVerses, 3);
    expect(story.chapters, hasLength(2));
    expect(story.chapters!.last.verses, hasLength(2));
  });
}
