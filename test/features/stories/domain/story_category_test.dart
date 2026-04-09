import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/stories/domain/story_category.dart';

void main() {
  test('maps storage values to story categories and falls back safely', () {
    expect(
      StoryCategory.fromStorageValue('prophets'),
      StoryCategory.prophets,
    );
    expect(
      StoryCategory.fromStorageValue('quranic'),
      StoryCategory.quranic,
    );
    expect(
      StoryCategory.fromStorageValue('unknown'),
      StoryCategory.quranic,
    );
    expect(StoryCategory.prophets.storageValue, 'prophets');
    expect(StoryCategory.quranic.storageValue, 'quranic');
  });
}
