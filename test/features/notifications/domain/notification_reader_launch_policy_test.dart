import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/notifications/domain/notification_reader_launch_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';

void main() {
  test('daily wird target resumes from the last saved reading position', () {
    final target = NotificationReaderLaunchPolicy.dailyWirdTarget(
      ReadingPosition(
        surahNumber: 5,
        ayahNumber: 10,
        page: 108,
        savedAt: DateTime(2026, 4, 4, 8),
      ),
    );

    expect(
      target,
      const ReaderNavigationTarget(
        surahNumber: 5,
        ayahNumber: 10,
        pageNumber: 108,
      ),
    );
  });

  test('daily wird target falls back to the default reader target', () {
    expect(
      NotificationReaderLaunchPolicy.dailyWirdTarget(null),
      NotificationReaderLaunchPolicy.defaultReaderTarget,
    );
  });
}
