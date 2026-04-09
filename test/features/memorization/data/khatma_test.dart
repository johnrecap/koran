import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';

void main() {
  group('Khatma', () {
    test('daysElapsed uses the provided clock value', () {
      final khatma = Khatma(
        id: 'khatma-1',
        title: 'Monthly Khatma',
        targetDays: 30,
        startDate: DateTime(2026, 4, 1),
      );

      expect(khatma.daysElapsed(DateTime(2026, 4, 6)), 5);
    });

    test('daysRemaining uses the provided clock value', () {
      final khatma = Khatma(
        id: 'khatma-1',
        title: 'Monthly Khatma',
        targetDays: 30,
        startDate: DateTime(2026, 4, 1),
      );

      expect(khatma.daysRemaining(DateTime(2026, 4, 6)), 25);
    });
  });
}
