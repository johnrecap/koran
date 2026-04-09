import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/memorization/domain/khatma_factory.dart';

void main() {
  test('create builds a khatma from injected clock and id generator', () {
    final now = DateTime(2026, 4, 4, 9, 30);

    final khatma = KhatmaFactory.create(
      title: 'ختمة ثلاثين يومًا',
      targetDays: 30,
      now: now,
      generateId: () => 'khatma-1',
    );

    expect(khatma.id, 'khatma-1');
    expect(khatma.title, 'ختمة ثلاثين يومًا');
    expect(khatma.targetDays, 30);
    expect(khatma.startDate, now);
    expect(khatma.completedSurahs, 0);
    expect(khatma.furthestPageRead, 0);
  });
}
