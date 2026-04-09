import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/reader_tadabbur_session_state.dart';
import 'package:quran_kareem/features/reader/providers/ayah_notes_provider.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_tadabbur_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test('loads the existing ayah note into the initial tadabbur draft',
      () async {
    final container = ProviderContainer(
      overrides: [
        surahsProvider.overrideWith((ref) async => _surahs),
        readerTadabburAyahLoaderProvider.overrideWithValue(
          const _FakeReaderTadabburAyahLoader(_ayahs),
        ),
        readerTadabburAutosaveDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 20),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(ayahNotesProvider.notifier).ready;
    await container.read(ayahNotesProvider.notifier).saveNote(
          surahNumber: _entryAyah.surahNumber,
          ayahNumber: _entryAyah.ayahNumber,
          content: 'Existing reflection',
        );
    final subscription = _keepSessionAlive(container);
    addTearDown(subscription.close);

    final controller = container.read(
      readerTadabburSessionControllerProvider(_entryAyah).notifier,
    );
    await controller.ready;

    expect(
      container
          .read(readerTadabburSessionControllerProvider(_entryAyah))
          .draftReflection,
      'Existing reflection',
    );
  });

  test('autosaves the draft after the configured debounce window', () async {
    final container = ProviderContainer(
      overrides: [
        surahsProvider.overrideWith((ref) async => _surahs),
        readerTadabburAyahLoaderProvider.overrideWithValue(
          const _FakeReaderTadabburAyahLoader(_ayahs),
        ),
        readerTadabburAutosaveDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 20),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = _keepSessionAlive(container);
    addTearDown(subscription.close);

    await container.read(ayahNotesProvider.notifier).ready;

    final controller = container.read(
      readerTadabburSessionControllerProvider(_entryAyah).notifier,
    );
    await controller.ready;

    controller.updateReflection('Fresh reflection');

    expect(
      container.read(ayahNotesProvider.notifier).noteFor(
            _entryAyah.surahNumber,
            _entryAyah.ayahNumber,
          ),
      isNull,
    );

    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(
      container
          .read(ayahNotesProvider.notifier)
          .noteFor(
            _entryAyah.surahNumber,
            _entryAyah.ayahNumber,
          )
          ?.content,
      'Fresh reflection',
    );
  });

  test('flushes the pending draft before moving to the next ayah', () async {
    final container = ProviderContainer(
      overrides: [
        surahsProvider.overrideWith((ref) async => _surahs),
        readerTadabburAyahLoaderProvider.overrideWithValue(
          const _FakeReaderTadabburAyahLoader(_ayahs),
        ),
        readerTadabburAutosaveDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 1),
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
    final subscription = _keepSessionAlive(container);
    addTearDown(subscription.close);

    final controller = container.read(
      readerTadabburSessionControllerProvider(_entryAyah).notifier,
    );
    await controller.ready;

    controller.updateReflection('Boundary reflection');
    await controller.goToNext();

    expect(
      container
          .read(ayahNotesProvider.notifier)
          .noteFor(
            _entryAyah.surahNumber,
            _entryAyah.ayahNumber,
          )
          ?.content,
      'Boundary reflection',
    );

    final state = container.read(
      readerTadabburSessionControllerProvider(_entryAyah),
    );
    expect(state.currentAyah, _nextAyah);
    expect(state.draftReflection, 'Second ayah reflection');
  });

  test('keeps the timer idle until the user starts it manually', () async {
    final container = ProviderContainer(
      overrides: [
        surahsProvider.overrideWith((ref) async => _surahs),
        readerTadabburAyahLoaderProvider.overrideWithValue(
          const _FakeReaderTadabburAyahLoader(_ayahs),
        ),
        readerTadabburTimerTickProvider.overrideWithValue(
          const Duration(milliseconds: 10),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = _keepSessionAlive(container);
    addTearDown(subscription.close);

    await container.read(ayahNotesProvider.notifier).ready;

    final controller = container.read(
      readerTadabburSessionControllerProvider(_entryAyah).notifier,
    );
    await controller.ready;

    final initialState = container.read(
      readerTadabburSessionControllerProvider(_entryAyah),
    );
    expect(initialState.isTimerRunning, isFalse);
    expect(
      initialState.remainingTimerDuration,
      initialState.selectedTimerDuration,
    );

    controller.startTimer();
    await Future<void>.delayed(const Duration(milliseconds: 35));

    final runningState = container.read(
      readerTadabburSessionControllerProvider(_entryAyah),
    );
    expect(runningState.isTimerRunning, isTrue);
    expect(
      runningState.remainingTimerDuration.inMilliseconds,
      lessThan(runningState.selectedTimerDuration.inMilliseconds),
    );
  });

  test('resets the timer when the active ayah changes', () async {
    final container = ProviderContainer(
      overrides: [
        surahsProvider.overrideWith((ref) async => _surahs),
        readerTadabburAyahLoaderProvider.overrideWithValue(
          const _FakeReaderTadabburAyahLoader(_ayahs),
        ),
        readerTadabburTimerTickProvider.overrideWithValue(
          const Duration(milliseconds: 10),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = _keepSessionAlive(container);
    addTearDown(subscription.close);

    await container.read(ayahNotesProvider.notifier).ready;

    final controller = container.read(
      readerTadabburSessionControllerProvider(_entryAyah).notifier,
    );
    await controller.ready;

    controller.startTimer();
    await Future<void>.delayed(const Duration(milliseconds: 35));
    await controller.goToNext();

    final state = container.read(
      readerTadabburSessionControllerProvider(_entryAyah),
    );
    expect(state.currentAyah, _nextAyah);
    expect(state.isTimerRunning, isFalse);
    expect(state.remainingTimerDuration, state.selectedTimerDuration);
  });
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

ProviderSubscription<ReaderTadabburSessionState> _keepSessionAlive(
  ProviderContainer container,
) {
  return container.listen(
    readerTadabburSessionControllerProvider(_entryAyah),
    (_, __) {},
    fireImmediately: true,
  );
}

const _entryAyah = Ayah(
  id: 2003,
  surahNumber: 2,
  ayahNumber: 3,
  text: 'ثالث آية',
  page: 2,
  juz: 1,
  hizb: 1,
);

const _nextAyah = Ayah(
  id: 3001,
  surahNumber: 3,
  ayahNumber: 1,
  text: 'أول آية',
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
