import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_kareem/features/tafsir/data/tafsir_browser_repository.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_state.dart';
import 'package:quran_kareem/features/tafsir/providers/tafsir_browser_providers.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  group('tafsir browser providers', () {
    test('resolve route params into a canonical insights target', () async {
      final container = ProviderContainer(
        overrides: [
          tafsirBrowserAyahLookupProvider.overrideWithValue(
            const _FakeTafsirBrowserAyahLookup(
              ayah: Ayah(
                id: 9999,
                surahNumber: 2,
                ayahNumber: 255,
                text: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
                page: 42,
                juz: 3,
                hizb: 1,
              ),
            ),
          ),
          tafsirBrowserCanonicalSurahsProvider.overrideWithValue(
            _canonicalSurahs,
          ),
          tafsirBrowserRepositoryProvider.overrideWithValue(
            _FakeTafsirBrowserRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final target = await container.read(
        tafsirBrowserTargetProvider(
          const TafsirBrowserRouteArgs(surahNumber: 2, ayahNumber: 255),
        ).future,
      );

      expect(target, isNotNull);
      expect(target!.surahNumber, 2);
      expect(target.ayahNumber, 255);
      expect(target.ayahUQNumber, 281);
      expect(target.pageNumber, 42);
    });

    test('projects the available tafsir sources from the repository', () async {
      final repository = _FakeTafsirBrowserRepository(
        sourceOptions: const [
          TafsirBrowserSourceOption(
            id: 'saadi',
            title: 'Tafsir Al-Saadi',
            bookName: 'Saadi',
            isTranslation: false,
            isSelected: true,
            isDownloaded: true,
          ),
          TafsirBrowserSourceOption(
            id: 'en',
            title: 'English Translation',
            bookName: 'English',
            isTranslation: true,
            isSelected: false,
            isDownloaded: true,
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          tafsirBrowserRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final options =
          await container.read(tafsirBrowserSourceOptionsProvider.future);

      expect(options, hasLength(2));
      expect(options.first.id, 'saadi');
      expect(options.first.isSelected, isTrue);
      expect(options.last.isTranslation, isTrue);
    });

    test('emits loading before yielding loaded tafsir content', () async {
      final completer = Completer<TafsirBrowserContentState>();
      final repository = _FakeTafsirBrowserRepository(
        loadContent: ({required target}) => completer.future,
      );
      final container = ProviderContainer(
        overrides: [
          tafsirBrowserRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final emitted = <AsyncValue<TafsirBrowserContentState>>[];
      final subscription = container.listen(
        tafsirBrowserContentProvider(_target),
        (_, next) => emitted.add(next),
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      expect(emitted, isNotEmpty);
      expect(emitted.first.isLoading, isTrue);

      completer.complete(
        const TafsirBrowserLoadedContent(
          verseText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
          bodyText: 'This is the tafsir body.',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(emitted.last.hasValue, isTrue);
      expect(emitted.last.value, isA<TafsirBrowserLoadedContent>());
      expect(
        (emitted.last.value! as TafsirBrowserLoadedContent).bodyText,
        'This is the tafsir body.',
      );
    });

    test('surfaces the source-unavailable state without throwing', () async {
      final container = ProviderContainer(
        overrides: [
          tafsirBrowserRepositoryProvider.overrideWithValue(
            _FakeTafsirBrowserRepository(
              loadContent: ({required target}) async =>
                  const TafsirBrowserSourceUnavailableContent(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final content =
          await container.read(tafsirBrowserContentProvider(_target).future);

      expect(content, isA<TafsirBrowserSourceUnavailableContent>());
    });
  });
}

const _target = ReaderAyahInsightsTarget(
  surahNumber: 2,
  ayahNumber: 255,
  ayahUQNumber: 281,
  pageNumber: 42,
);

final _canonicalSurahs = <SurahModel>[
  SurahModel(
    surahNumber: 2,
    arabicName: 'البقرة',
    englishName: 'Al-Baqarah',
    ayahs: [
      AyahModel(
        ayahUQNumber: 281,
        ayahNumber: 255,
        text: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
        ayaTextEmlaey: 'الله لا إله إلا هو',
        juz: 3,
        page: 42,
        surahNumber: 2,
      ),
    ],
  ),
];

class _FakeTafsirBrowserAyahLookup implements TafsirBrowserAyahLookup {
  const _FakeTafsirBrowserAyahLookup({
    required this.ayah,
  });

  final Ayah? ayah;

  @override
  Future<Ayah?> findAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    return ayah;
  }
}

class _FakeTafsirBrowserRepository implements TafsirBrowserRepository {
  _FakeTafsirBrowserRepository({
    this.sourceOptions = const [
      TafsirBrowserSourceOption(
        id: 'saadi',
        title: 'Tafsir Al-Saadi',
        bookName: 'Saadi',
        isTranslation: false,
        isSelected: true,
        isDownloaded: true,
      ),
    ],
    this.loadContent,
  });

  final List<TafsirBrowserSourceOption> sourceOptions;
  final Future<TafsirBrowserContentState> Function({
    required ReaderAyahInsightsTarget target,
  })? loadContent;

  @override
  Future<List<TafsirBrowserSourceOption>> fetchSourceOptions() async {
    return sourceOptions;
  }

  @override
  Future<TafsirBrowserContentState> fetchContent({
    required ReaderAyahInsightsTarget target,
  }) async {
    final loader = loadContent;
    if (loader != null) {
      return loader(target: target);
    }

    return const TafsirBrowserLoadedContent(
      verseText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
      bodyText: 'Default tafsir body.',
    );
  }

  @override
  Future<void> selectSource({
    required String sourceId,
    required int pageNumber,
  }) async {}
}
