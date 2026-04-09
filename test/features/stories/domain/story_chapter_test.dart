import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/stories/domain/story_chapter.dart';

void main() {
  test('parses a story chapter with multiple verses', () {
    final chapter = StoryChapter.fromJson(const <String, dynamic>{
      'id': 'ch1',
      'order': 1,
      'title_ar': 'العنوان العربي',
      'title_en': 'English title',
      'narrative_ar': 'narrative',
      'lesson_ar': 'lesson ar',
      'lesson_en': 'lesson en',
      'verses': <Map<String, dynamic>>[
        {
          'surah': 2,
          'ayah_start': 30,
          'ayah_end': 30,
          'text_ar': 'verse 1',
          'context_ar': 'context 1',
        },
        {
          'surah': 2,
          'ayah_start': 31,
          'ayah_end': 33,
          'text_ar': 'verse 2',
          'context_ar': 'context 2',
        },
      ],
    });

    expect(chapter.id, 'ch1');
    expect(chapter.order, 1);
    expect(chapter.titleAr, 'العنوان العربي');
    expect(chapter.titleEn, 'English title');
    expect(chapter.narrativeAr, 'narrative');
    expect(chapter.lessonAr, 'lesson ar');
    expect(chapter.lessonEn, 'lesson en');
    expect(chapter.verses, hasLength(2));
    expect(chapter.verses.last.isRange, isTrue);
  });

  test('parses a story chapter with no verses as an empty list', () {
    final chapter = StoryChapter.fromJson(const <String, dynamic>{
      'id': 'ch2',
      'order': 2,
      'title_ar': 'بدون آيات',
      'title_en': 'No verses',
      'narrative_ar': 'narrative',
      'lesson_ar': 'lesson ar',
      'lesson_en': 'lesson en',
      'verses': <Map<String, dynamic>>[],
    });

    expect(chapter.verses, isEmpty);
  });
}
