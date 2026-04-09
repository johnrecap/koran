import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_schedule_policy.dart';

void main() {
  group('ReaderNightSchedulePolicy', () {
    test('rejects equal start and end minutes as an invalid window', () {
      expect(
        ReaderNightSchedulePolicy.isValidWindow(
          startMinutes: 20 * 60,
          endMinutes: 20 * 60,
        ),
        isFalse,
      );
    });

    test('treats same-day windows as active only inside the configured range',
        () {
      expect(
        ReaderNightSchedulePolicy.isWithinWindow(
          startMinutes: 20 * 60,
          endMinutes: 22 * 60,
          nowLocal: DateTime(2026, 3, 31, 21, 0),
        ),
        isTrue,
      );
      expect(
        ReaderNightSchedulePolicy.isWithinWindow(
          startMinutes: 20 * 60,
          endMinutes: 22 * 60,
          nowLocal: DateTime(2026, 3, 31, 23, 0),
        ),
        isFalse,
      );
    });

    test('supports windows that cross midnight', () {
      expect(
        ReaderNightSchedulePolicy.isWithinWindow(
          startMinutes: 20 * 60,
          endMinutes: 5 * 60,
          nowLocal: DateTime(2026, 3, 31, 23, 30),
        ),
        isTrue,
      );
      expect(
        ReaderNightSchedulePolicy.isWithinWindow(
          startMinutes: 20 * 60,
          endMinutes: 5 * 60,
          nowLocal: DateTime(2026, 4, 1, 4, 45),
        ),
        isTrue,
      );
      expect(
        ReaderNightSchedulePolicy.isWithinWindow(
          startMinutes: 20 * 60,
          endMinutes: 5 * 60,
          nowLocal: DateTime(2026, 4, 1, 12, 0),
        ),
        isFalse,
      );
    });
  });
}
