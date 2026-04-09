import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/stories/domain/story_verse.dart';

void main() {
  test('parses story verse json and preserves it through toJson', () {
    final verse = StoryVerse.fromJson(const <String, dynamic>{
      'surah': 2,
      'ayah_start': 30,
      'ayah_end': 33,
      'text_ar': 'sample verse text',
      'context_ar': 'sample context',
    });

    expect(verse.surah, 2);
    expect(verse.ayahStart, 30);
    expect(verse.ayahEnd, 33);
    expect(verse.textAr, 'sample verse text');
    expect(verse.contextAr, 'sample context');
    expect(verse.isRange, isTrue);
    expect(verse.toJson(), <String, dynamic>{
      'surah': 2,
      'ayah_start': 30,
      'ayah_end': 33,
      'text_ar': 'sample verse text',
      'context_ar': 'sample context',
    });
  });

  test('treats a single ayah verse as a non-range', () {
    final verse = StoryVerse.fromJson(const <String, dynamic>{
      'surah': 105,
      'ayah_start': 1,
      'ayah_end': 1,
      'text_ar': 'single ayah',
      'context_ar': 'context',
    });

    expect(verse.isRange, isFalse);
  });
}
