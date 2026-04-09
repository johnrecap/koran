import 'package:quran_kareem/core/utils/id_generator.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';

abstract final class KhatmaFactory {
  static Khatma create({
    required String title,
    required int targetDays,
    DateTime? now,
    String Function()? generateId,
  }) {
    final createdAt = now ?? DateTime.now();
    final resolveId = generateId ?? IdGenerator.uniqueId;

    return Khatma(
      id: resolveId(),
      title: title,
      targetDays: targetDays,
      startDate: createdAt,
    );
  }
}
