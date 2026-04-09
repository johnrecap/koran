import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';

abstract final class NotificationReaderLaunchPolicy {
  static const ReaderNavigationTarget defaultReaderTarget =
      ReaderEntryTargetPolicy.defaultTarget;

  static ReaderNavigationTarget dailyWirdTarget(ReadingPosition? position) {
    return ReaderEntryTargetPolicy.fromReadingPosition(position);
  }
}
