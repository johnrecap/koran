import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/reader/providers/ayah_notes_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test('saves and reloads a local note for the same ayah', () async {
    final notifier = AyahNotesNotifier();
    await notifier.ready;

    await notifier.saveNote(
      surahNumber: 2,
      ayahNumber: 255,
      content: 'Daily reflection',
    );

    final reloaded = AyahNotesNotifier();
    await reloaded.ready;

    expect(reloaded.noteFor(2, 255)?.content, 'Daily reflection');
  });

  test('deletes a saved local note', () async {
    final notifier = AyahNotesNotifier();
    await notifier.ready;
    await notifier.saveNote(
      surahNumber: 1,
      ayahNumber: 1,
      content: 'Opening note',
    );

    await notifier.deleteNote(
      surahNumber: 1,
      ayahNumber: 1,
    );

    expect(notifier.noteFor(1, 1), isNull);
  });
}
