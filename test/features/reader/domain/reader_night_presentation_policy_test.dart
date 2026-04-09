import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_presentation_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_style.dart';

void main() {
  group('ReaderNightPresentationPolicy', () {
    test('defaults to normal when auto-enable is off and no session override exists', () {
      expect(
        ReaderNightPresentationPolicy.resolve(
          autoEnable: false,
          startMinutes: 20 * 60,
          endMinutes: 5 * 60,
          preferredNightStyle: ReaderNightStyle.amoled,
          nowLocal: DateTime(2026, 3, 31, 22, 0),
        ),
        ReaderNightPresentation.normal,
      );
    });

    test('uses the preferred night style during an active automatic window', () {
      expect(
        ReaderNightPresentationPolicy.resolve(
          autoEnable: true,
          startMinutes: 20 * 60,
          endMinutes: 5 * 60,
          preferredNightStyle: ReaderNightStyle.amoled,
          nowLocal: DateTime(2026, 3, 31, 22, 0),
        ),
        ReaderNightPresentation.amoled,
      );
    });

    test('falls back to normal outside the configured automatic window', () {
      expect(
        ReaderNightPresentationPolicy.resolve(
          autoEnable: true,
          startMinutes: 20 * 60,
          endMinutes: 5 * 60,
          preferredNightStyle: ReaderNightStyle.night,
          nowLocal: DateTime(2026, 3, 31, 12, 0),
        ),
        ReaderNightPresentation.normal,
      );
    });

    test('lets a normal session override beat automatic activation', () {
      expect(
        ReaderNightPresentationPolicy.resolve(
          autoEnable: true,
          startMinutes: 20 * 60,
          endMinutes: 5 * 60,
          preferredNightStyle: ReaderNightStyle.night,
          nowLocal: DateTime(2026, 3, 31, 22, 0),
          sessionOverride: ReaderNightPresentation.normal,
        ),
        ReaderNightPresentation.normal,
      );
    });

    test('lets a manual night session override apply outside the auto window', () {
      expect(
        ReaderNightPresentationPolicy.resolve(
          autoEnable: false,
          startMinutes: 20 * 60,
          endMinutes: 5 * 60,
          preferredNightStyle: ReaderNightStyle.night,
          nowLocal: DateTime(2026, 3, 31, 12, 0),
          sessionOverride: ReaderNightPresentation.amoled,
        ),
        ReaderNightPresentation.amoled,
      );
    });

    test('treats an invalid configured window as normal when no session override exists', () {
      expect(
        ReaderNightPresentationPolicy.resolve(
          autoEnable: true,
          startMinutes: 20 * 60,
          endMinutes: 20 * 60,
          preferredNightStyle: ReaderNightStyle.night,
          nowLocal: DateTime(2026, 3, 31, 22, 0),
        ),
        ReaderNightPresentation.normal,
      );
    });
  });
}
