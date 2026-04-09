import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/stories/domain/story_reading_progress.dart';

void main() {
  test('round-trips story reading progress through map serialization', () {
    final progress = StoryReadingProgress(
      storyId: 'adam',
      lastChapterIndex: 4,
      completedAt: DateTime.utc(2026, 4, 8, 12, 30),
    );

    final restored = StoryReadingProgress.fromMap(progress.toMap());

    expect(restored.storyId, 'adam');
    expect(restored.lastChapterIndex, 4);
    expect(restored.completedAt, DateTime.utc(2026, 4, 8, 12, 30));
    expect(restored.isCompleted, isTrue);
  });

  test('reports completion state and percent safely', () {
    const inProgress = StoryReadingProgress(
      storyId: 'adam',
      lastChapterIndex: 4,
    );
    final completed = StoryReadingProgress(
      storyId: 'adam',
      lastChapterIndex: 9,
      completedAt: DateTime.utc(2026, 4, 8),
    );

    expect(inProgress.isCompleted, isFalse);
    expect(inProgress.completionPercent(10), 50);
    expect(inProgress.completionPercent(0), 0);
    expect(completed.isCompleted, isTrue);
    expect(completed.completionPercent(10), 100);
  });
}
