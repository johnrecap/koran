import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_payload.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_tadabbur_sheet.dart';
import 'package:quran_kareem/features/reader/providers/ayah_notes_provider.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_tadabbur_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  testWidgets('keeps the share action disabled while the reflection is empty', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        surahsProvider.overrideWith((ref) async => _surahs),
        readerTadabburAyahLoaderProvider.overrideWithValue(
          const _FakeReaderTadabburAyahLoader(_ayahs),
        ),
        readerTadabburAutosaveDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 10),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(ayahNotesProvider.notifier).ready;

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: ReaderTadabburSheet(
          entryAyah: _entryAyah,
          onClose: (_) {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    final disabledShareButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey<String>('reader-tadabbur-share')),
    );
    expect(disabledShareButton.onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey<String>('reader-tadabbur-reflection-field')),
      'Fresh reflection',
    );
    await tester.pump();

    final enabledShareButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey<String>('reader-tadabbur-share')),
    );
    expect(enabledShareButton.onPressed, isNotNull);
  });

  testWidgets('moves to the next ayah and loads its saved reflection', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        surahsProvider.overrideWith((ref) async => _surahs),
        readerTadabburAyahLoaderProvider.overrideWithValue(
          const _FakeReaderTadabburAyahLoader(_ayahs),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(ayahNotesProvider.notifier).ready;
    await container.read(ayahNotesProvider.notifier).saveNote(
          surahNumber: _nextAyah.surahNumber,
          ayahNumber: _nextAyah.ayahNumber,
          content: 'Second ayah reflection',
        );

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: ReaderTadabburSheet(
          entryAyah: _entryAyah,
          onClose: (_) {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    await tester
        .tap(find.byKey(const ValueKey<String>('reader-tadabbur-next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    expect(find.text('Second ayah reflection'), findsOneWidget);
    expect(find.text(_nextAyah.text), findsOneWidget);
  });

  testWidgets('shares ayah text reference and reflection through the callback',
      (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        surahsProvider.overrideWith((ref) async => _surahs),
        readerTadabburAyahLoaderProvider.overrideWithValue(
          const _FakeReaderTadabburAyahLoader(_ayahs),
        ),
        readerTadabburAutosaveDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 10),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(ayahNotesProvider.notifier).ready;

    Ayah? sharedAyah;
    AyahShareCardPayload? sharedPayload;

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: ReaderTadabburSheet(
          entryAyah: _entryAyah,
          onClose: (_) {},
          onShareRequested: ({
            required ayah,
            required payload,
          }) async {
            sharedAyah = ayah;
            sharedPayload = payload;
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    await tester.enterText(
      find.byKey(const ValueKey<String>('reader-tadabbur-reflection-field')),
      'Shared reflection',
    );
    await tester.pump();

    await tester
        .tap(find.byKey(const ValueKey<String>('reader-tadabbur-share')));
    await tester.pump();

    expect(sharedAyah, _entryAyah);
    expect(sharedPayload?.ayahText, _entryAyah.text);
    expect(sharedPayload?.referenceText, '[Surah Al-Baqarah]');
    expect(sharedPayload?.supportingText, 'Shared reflection');
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

class _FakeReaderTadabburAyahLoader implements ReaderTadabburAyahLoader {
  const _FakeReaderTadabburAyahLoader(this.ayahs);

  final Map<String, Ayah> ayahs;

  @override
  Future<Ayah?> loadAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    return ayahs['$surahNumber:$ayahNumber'];
  }
}

const _entryAyah = Ayah(
  id: 2003,
  surahNumber: 2,
  ayahNumber: 3,
  text: 'Third ayah',
  page: 2,
  juz: 1,
  hizb: 1,
);

const _nextAyah = Ayah(
  id: 3001,
  surahNumber: 3,
  ayahNumber: 1,
  text: 'Next ayah',
  page: 50,
  juz: 3,
  hizb: 1,
);

const _surahs = <Surah>[
  Surah(
    number: 1,
    nameArabic: 'الفاتحة',
    nameEnglish: 'Al-Fatihah',
    nameTransliteration: 'Al-Fatihah',
    ayahCount: 7,
    revelationType: 'Meccan',
    page: 1,
  ),
  Surah(
    number: 2,
    nameArabic: 'البقرة',
    nameEnglish: 'Al-Baqarah',
    nameTransliteration: 'Al-Baqarah',
    ayahCount: 3,
    revelationType: 'Medinan',
    page: 2,
  ),
  Surah(
    number: 3,
    nameArabic: 'آل عمران',
    nameEnglish: 'Ali Imran',
    nameTransliteration: 'Ali Imran',
    ayahCount: 5,
    revelationType: 'Medinan',
    page: 50,
  ),
];

const _ayahs = <String, Ayah>{
  '2:3': _entryAyah,
  '3:1': _nextAyah,
};
