import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_ayah_note_sheet.dart';
import 'package:quran_kareem/features/reader/providers/ayah_notes_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  testWidgets('prefills the existing note and shows delete', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(ayahNotesProvider.notifier).ready;
    await container.read(ayahNotesProvider.notifier).saveNote(
          surahNumber: _ayah.surahNumber,
          ayahNumber: _ayah.ayahNumber,
          content: 'Existing note',
        );

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: const ReaderAyahNoteSheet(ayah: _ayah),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Existing note'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('saves the written note through the local provider', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(ayahNotesProvider.notifier).ready;

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: const ReaderAyahNoteSheet(ayah: _ayah),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.enterText(find.byKey(const ValueKey('ayah-note-field')), 'New note');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      container.read(ayahNotesProvider.notifier).noteFor(
            _ayah.surahNumber,
            _ayah.ayahNumber,
          )?.content,
      'New note',
    );
  });
}

Widget _buildHarness({
  required ProviderContainer container,
  required Widget child,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: child),
    ),
  );
}

const _ayah = Ayah(
  id: 255,
  surahNumber: 2,
  ayahNumber: 255,
  text: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
  page: 42,
  juz: 3,
  hizb: 1,
);
