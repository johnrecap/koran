import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:quran_kareem/core/constants/app_constants.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_option.dart';
import 'package:quran_kareem/features/reader/data/muallim_ayah_audio_service.dart';
import 'package:quran_kareem/features/reader/data/muallim_session_store.dart';
import 'package:quran_kareem/features/reader/data/word_timing_cache_data_source.dart';
import 'package:quran_kareem/features/reader/data/word_timing_remote_data_source.dart';
import 'package:quran_kareem/features/reader/domain/muallim_models.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/domain/word_timing_models.dart';
import 'package:quran_kareem/features/reader/providers/muallim_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _supportedReciterId = 'Abdul_Basit_Murattal_192kbps';
const _supportedReciterName = 'Abdul Basit Murattal';
const _alternateReciterId = 'Minshawy_Murattal_128kbps';
const _alternateReciterName = 'Minshawy Murattal';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    UserPreferences.resetCache();
  });

  test('enables Muallim mode and starts playback from a specific ayah',
      () async {
    final service = _FakeMuallimAyahAudioService();
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);

    final notifier = container.read(muallimStateProvider.notifier);
    await notifier.enable();
    await notifier.startFromAyah(
      const MuallimAyahPosition(
        surahNumber: 2,
        ayahNumber: 5,
        ayahUQNumber: 12,
        pageNumber: 2,
      ),
    );

    final state = container.read(muallimStateProvider);
    expect(state.isEnabled, isTrue);
    expect(state.playbackState, MuallimPlaybackState.loading);
    expect(service.lastPlayedAyahUQNumber, 12);
  });

  test(
      'exposes an auto-navigation target when scroll mode crosses into a new page',
      () async {
    final service = _FakeMuallimAyahAudioService();
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);

    container.read(readerModeProvider.notifier).state = ReaderMode.scroll;
    container.read(quranPageIndexProvider.notifier).state = 10;
    await container.read(muallimStateProvider.notifier).enable();

    service.emit(
      const MuallimPlaybackSnapshot(
        playbackState: MuallimPlaybackState.playing,
        currentAyah: MuallimAyahPosition(
          surahNumber: 3,
          ayahNumber: 7,
          ayahUQNumber: 300,
          pageNumber: 11,
        ),
        position: Duration(seconds: 2),
        duration: Duration(seconds: 5),
        currentReciterId: _supportedReciterId,
        currentReciterName: _supportedReciterName,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final target = container.read(muallimAutoNavigationTargetProvider);
    expect(
      target,
      const ReaderNavigationTarget(
        surahNumber: 3,
        ayahNumber: 7,
        pageNumber: 11,
      ),
    );
  });

  test('updates the selected reciter in Muallim state', () async {
    final service = _FakeMuallimAyahAudioService();
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);

    await container.read(muallimStateProvider.notifier).selectReciter(
          _alternateReciterId,
          restartPlayback: false,
        );

    final state = container.read(muallimStateProvider);
    expect(state.currentReciterId, _alternateReciterId);
    expect(state.currentReciterName, _alternateReciterName);
  });

  test('resolves the current word index after loading remote timing data',
      () async {
    final service = _FakeMuallimAyahAudioService();
    final cache = _FakeWordTimingCacheDataSource();
    final remote = _FakeWordTimingRemoteDataSource(
      response: _timingDataWithContiguousSegments(),
    );
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
        muallimWordTimingCacheProvider.overrideWithValue(cache),
        muallimWordTimingRemoteProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);
    await container.read(muallimStateProvider.notifier).enable();

    service.emit(_playbackSnapshot(positionMs: 0));
    await Future<void>.delayed(Duration.zero);

    service.emit(_playbackSnapshot(positionMs: 1500));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(muallimStateProvider);
    final highlight = container.read(muallimWordHighlightProvider);

    expect(remote.fetchCallCount, 2);
    expect(
      remote.fetchRequests.first,
      (surahNumber: 1, readerNamePath: _supportedReciterId),
    );
    expect(
      cache.cachedDataByKey.containsKey(
        (surahNumber: 1, reciterId: _supportedReciterId),
      ),
      isTrue,
    );
    expect(state.currentWordIndex, 1);
    expect(highlight.ayahUQNumber, 1);
    expect(highlight.wordIndex, 1);
  });

  test('prefetches next surah timing after current timing loads', () async {
    final service = _FakeMuallimAyahAudioService();
    final cache = _FakeWordTimingCacheDataSource();
    final remote = _FakeWordTimingRemoteDataSource(
      responsesBySurah: {
        1: _timingDataWithContiguousSegments(),
        2: _timingDataForSurah(2),
      },
    );
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
        muallimWordTimingCacheProvider.overrideWithValue(cache),
        muallimWordTimingRemoteProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    await _flushAsyncWork();
    await container.read(muallimStateProvider.notifier).enable();

    service.emit(_playbackSnapshot(positionMs: 0));
    await _flushAsyncWork();

    final state = container.read(muallimStateProvider);
    expect(
      remote.fetchRequests,
      [
        (surahNumber: 1, readerNamePath: _supportedReciterId),
        (surahNumber: 2, readerNamePath: _supportedReciterId),
      ],
    );
    expect(
      cache.cachedDataByKey.containsKey(
        (surahNumber: 2, reciterId: _supportedReciterId),
      ),
      isTrue,
    );
    expect(state.currentAyah?.surahNumber, 1);
    expect(state.currentWordIndex, 0);
    expect(state.timingStatus, MuallimTimingStatus.available);
  });

  test('skips remote prefetch when next surah timing is already cached',
      () async {
    final service = _FakeMuallimAyahAudioService();
    final cache = _FakeWordTimingCacheDataSource(
      cachedDataByKey: {
        (surahNumber: 2, reciterId: _supportedReciterId):
            _timingDataForSurah(2),
      },
    );
    final remote = _FakeWordTimingRemoteDataSource(
      responsesBySurah: {
        1: _timingDataWithContiguousSegments(),
      },
    );
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
        muallimWordTimingCacheProvider.overrideWithValue(cache),
        muallimWordTimingRemoteProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    await _flushAsyncWork();
    await container.read(muallimStateProvider.notifier).enable();

    service.emit(_playbackSnapshot(positionMs: 0));
    await _flushAsyncWork();

    expect(
      remote.fetchRequests,
      [
        (surahNumber: 1, readerNamePath: _supportedReciterId),
      ],
    );
    expect(
      cache.getRequests,
      contains((surahNumber: 2, reciterId: _supportedReciterId)),
    );
  });

  test('does not prefetch beyond the last surah boundary', () async {
    final service = _FakeMuallimAyahAudioService();
    final cache = _FakeWordTimingCacheDataSource();
    final remote = _FakeWordTimingRemoteDataSource(
      responsesBySurah: {
        AppConstants.totalSurahs: _timingDataForSurah(AppConstants.totalSurahs),
      },
    );
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
        muallimWordTimingCacheProvider.overrideWithValue(cache),
        muallimWordTimingRemoteProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    await _flushAsyncWork();
    await container.read(muallimStateProvider.notifier).enable();

    service.emit(
      _playbackSnapshot(
        surahNumber: AppConstants.totalSurahs,
        ayahUQNumber: 9999,
        pageNumber: 604,
        positionMs: 0,
      ),
    );
    await _flushAsyncWork();

    expect(
      remote.fetchRequests,
      [
        (
          surahNumber: AppConstants.totalSurahs,
          readerNamePath: _supportedReciterId,
        ),
      ],
    );
    expect(
      cache.getRequests,
      isNot(contains((
        surahNumber: AppConstants.totalSurahs + 1,
        reciterId: _supportedReciterId,
      ))),
    );
  });

  test('keeps word index null when playback is between cached word segments',
      () async {
    final service = _FakeMuallimAyahAudioService();
    final cache = _FakeWordTimingCacheDataSource(
      cachedData: _timingDataWithSegmentGap(),
    );
    final remote = _FakeWordTimingRemoteDataSource(
      responsesBySurah: {
        2: _timingDataForSurah(2),
      },
    );
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
        muallimWordTimingCacheProvider.overrideWithValue(cache),
        muallimWordTimingRemoteProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);
    await container.read(muallimStateProvider.notifier).enable();

    service.emit(_playbackSnapshot(positionMs: 0));
    await Future<void>.delayed(Duration.zero);

    service.emit(_playbackSnapshot(positionMs: 1000));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(muallimStateProvider);
    final highlight = container.read(muallimWordHighlightProvider);

    expect(cache.getCallCount, greaterThanOrEqualTo(1));
    expect(
      remote.fetchRequests,
      [
        (surahNumber: 2, readerNamePath: _supportedReciterId),
      ],
    );
    expect(state.currentWordIndex, isNull);
    expect(highlight.ayahUQNumber, 1);
    expect(highlight.wordIndex, isNull);
  });

  test('restores the last Muallim ayah and reciter when mode is re-enabled',
      () async {
    final service = _FakeMuallimAyahAudioService();
    final store = _FakeMuallimSessionStore(
      savedSession: const MuallimResumeSession(
        ayah: MuallimAyahPosition(
          surahNumber: 2,
          ayahNumber: 255,
          ayahUQNumber: 281,
          pageNumber: 42,
        ),
        reciterId: _alternateReciterId,
        reciterName: _alternateReciterName,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
        muallimSessionStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);
    await container.read(muallimStateProvider.notifier).enable();

    final state = container.read(muallimStateProvider);
    expect(state.isEnabled, isTrue);
    expect(
      state.currentAyah,
      const MuallimAyahPosition(
        surahNumber: 2,
        ayahNumber: 255,
        ayahUQNumber: 281,
        pageNumber: 42,
      ),
    );
    expect(state.currentReciterId, _alternateReciterId);
    expect(state.currentReciterName, _alternateReciterName);
    expect(service.lastSelectedReciterId, _alternateReciterId);
  });

  test(
      'reports loadError timing status and keeps ayah-level fallback on fetch failure',
      () async {
    final service = _FakeMuallimAyahAudioService();
    final cache = _FakeWordTimingCacheDataSource();
    final remote = _ThrowingWordTimingRemoteDataSource(
      exception: const WordTimingRemoteException('Network error: offline'),
    );
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
        muallimWordTimingCacheProvider.overrideWithValue(cache),
        muallimWordTimingRemoteProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);
    await container.read(muallimStateProvider.notifier).enable();

    service.emit(_playbackSnapshot(positionMs: 750));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(muallimStateProvider);
    expect(state.currentWordIndex, isNull);
    expect(state.timingStatus, MuallimTimingStatus.loadError);
  });

  test(
      'reports unmappedReciter timing status when the reciter has no timing mapping',
      () async {
    final service = _FakeMuallimAyahAudioService();
    final cache = _FakeWordTimingCacheDataSource();
    final remote = _FakeWordTimingRemoteDataSource(
      response: _timingDataWithContiguousSegments(),
    );
    final container = ProviderContainer(
      overrides: [
        muallimAyahAudioServiceProvider.overrideWithValue(service),
        muallimWordTimingCacheProvider.overrideWithValue(cache),
        muallimWordTimingRemoteProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);
    await container.read(muallimStateProvider.notifier).enable();

    service.emit(
      _playbackSnapshot(
        positionMs: 500,
        reciterId: 'Fares_Abbad_64kbps',
        reciterName: 'Fares Abbad',
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final state = container.read(muallimStateProvider);
    expect(state.currentWordIndex, isNull);
    expect(state.timingStatus, MuallimTimingStatus.unmappedReciter);
    expect(remote.fetchCallCount, 0);
  });
}

class _FakeMuallimAyahAudioService implements MuallimAyahAudioService {
  final StreamController<MuallimPlaybackSnapshot> _controller =
      StreamController<MuallimPlaybackSnapshot>.broadcast();

  int? lastPlayedAyahUQNumber;
  String? lastSelectedReciterId;
  String _currentReciterId = _supportedReciterId;
  String _currentReciterName = _supportedReciterName;

  @override
  List<AudioHubReciterOption> get availableReciters => const [
        AudioHubReciterOption(
          index: 0,
          id: _supportedReciterId,
          name: _supportedReciterName,
        ),
        AudioHubReciterOption(
          index: 1,
          id: _alternateReciterId,
          name: _alternateReciterName,
        ),
      ];

  @override
  Stream<MuallimPlaybackSnapshot> get snapshots => _controller.stream;

  @override
  Future<MuallimPlaybackSnapshot> ensureInitialized() async {
    return MuallimPlaybackSnapshot(
      playbackState: MuallimPlaybackState.idle,
      currentAyah: null,
      position: Duration.zero,
      duration: Duration.zero,
      currentReciterId: _currentReciterId,
      currentReciterName: _currentReciterName,
    );
  }

  @override
  Future<void> nextAyah({
    BuildContext? context,
  }) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> playFromAyah(
    MuallimAyahPosition ayah, {
    BuildContext? context,
    bool isDarkMode = false,
  }) async {
    lastPlayedAyahUQNumber = ayah.ayahUQNumber;
  }

  @override
  Future<void> previousAyah({
    BuildContext? context,
  }) async {}

  @override
  Future<void> resume({
    BuildContext? context,
    bool isDarkMode = false,
  }) async {}

  @override
  Future<void> selectReciter(
    String reciterId, {
    BuildContext? context,
    bool restartPlayback = true,
    bool isDarkMode = false,
  }) async {
    lastSelectedReciterId = reciterId;
    for (final reciter in availableReciters) {
      if (reciter.id == reciterId) {
        _currentReciterId = reciter.id;
        _currentReciterName = reciter.name;
        break;
      }
    }
  }

  @override
  void clearSelectionHighlights() {}

  @override
  Future<void> stop() async {}

  @override
  void dispose() {
    _controller.close();
  }

  void emit(MuallimPlaybackSnapshot snapshot) {
    _controller.add(snapshot);
  }
}

class _FakeMuallimSessionStore implements MuallimSessionStore {
  _FakeMuallimSessionStore({this.savedSession});

  MuallimResumeSession? savedSession;

  @override
  Future<void> clear() async {
    savedSession = null;
  }

  @override
  Future<MuallimResumeSession?> load() async => savedSession;

  @override
  Future<void> save(MuallimResumeSession session) async {
    savedSession = session;
  }
}

class _FakeWordTimingCacheDataSource extends WordTimingCacheDataSource {
  _FakeWordTimingCacheDataSource({
    SurahTimingData? cachedData,
    Map<SurahTimingKey, SurahTimingData>? cachedDataByKey,
  }) : cachedDataByKey = {
          if (cachedData != null)
            (
              surahNumber: cachedData.surahNumber,
              reciterId: cachedData.reciterId
            ): cachedData,
          ...?cachedDataByKey,
        };

  final Map<SurahTimingKey, SurahTimingData> cachedDataByKey;
  SurahTimingData? lastPutData;
  int getCallCount = 0;
  final List<SurahTimingKey> getRequests = [];
  final List<SurahTimingData> putRequests = [];

  @override
  Future<SurahTimingData?> get({
    required int surahNumber,
    required String reciterId,
  }) async {
    getCallCount += 1;
    getRequests.add((surahNumber: surahNumber, reciterId: reciterId));
    return cachedDataByKey[(surahNumber: surahNumber, reciterId: reciterId)];
  }

  @override
  Future<void> put(SurahTimingData data) async {
    lastPutData = data;
    putRequests.add(data);
    cachedDataByKey[(
      surahNumber: data.surahNumber,
      reciterId: data.reciterId
    )] = data;
  }
}

class _FakeWordTimingRemoteDataSource extends WordTimingRemoteDataSource {
  _FakeWordTimingRemoteDataSource({
    SurahTimingData? response,
    Map<int, SurahTimingData>? responsesBySurah,
  })  : responsesBySurah = {
          if (response != null) response.surahNumber: response,
          ...?responsesBySurah,
        },
        super(
          client: MockClient((_) async => throw UnimplementedError()),
          baseUrl: 'https://test.example.com',
        );

  final Map<int, SurahTimingData> responsesBySurah;
  int fetchCallCount = 0;
  int? lastSurahNumber;
  String? lastReaderNamePath;
  final List<({int surahNumber, String readerNamePath})> fetchRequests = [];

  @override
  Future<SurahTimingData> fetchSurahTimings({
    required int surahNumber,
    required String readerNamePath,
  }) async {
    fetchCallCount += 1;
    lastSurahNumber = surahNumber;
    lastReaderNamePath = readerNamePath;
    fetchRequests.add(
      (surahNumber: surahNumber, readerNamePath: readerNamePath),
    );
    final response = responsesBySurah[surahNumber];
    if (response == null) {
      throw StateError(
        'No fake timing response configured for surah $surahNumber.',
      );
    }
    return response;
  }
}

class _ThrowingWordTimingRemoteDataSource extends WordTimingRemoteDataSource {
  _ThrowingWordTimingRemoteDataSource({
    required this.exception,
  }) : super(
          client: MockClient((_) async => throw UnimplementedError()),
          baseUrl: 'https://test.example.com',
        );

  final Exception exception;

  @override
  Future<SurahTimingData> fetchSurahTimings({
    required int surahNumber,
    required String readerNamePath,
  }) async {
    throw exception;
  }
}

MuallimPlaybackSnapshot _playbackSnapshot({
  required int positionMs,
  int surahNumber = 1,
  int ayahNumber = 1,
  int? ayahUQNumber,
  int pageNumber = 1,
  String reciterId = _supportedReciterId,
  String reciterName = _supportedReciterName,
}) {
  return MuallimPlaybackSnapshot(
    playbackState: MuallimPlaybackState.playing,
    currentAyah: MuallimAyahPosition(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      ayahUQNumber: ayahUQNumber ?? surahNumber,
      pageNumber: pageNumber,
    ),
    position: Duration(milliseconds: positionMs),
    duration: const Duration(seconds: 5),
    currentReciterId: reciterId,
    currentReciterName: reciterName,
  );
}

Future<void> _flushAsyncWork([int turns = 6]) async {
  for (var i = 0; i < turns; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

SurahTimingData _timingDataWithContiguousSegments() {
  return _timingDataForSurah(1);
}

SurahTimingData _timingDataWithSegmentGap() {
  return const SurahTimingData(
    surahNumber: 1,
    reciterId: _supportedReciterId,
    audioUrl: 'https://cdn.example.com/1.mp3',
    hasWordSegments: true,
    ayahTimings: [
      AyahTimingData(
        verseKey: '1:1',
        surahNumber: 1,
        ayahNumber: 1,
        timestampFrom: 0,
        timestampTo: 3200,
        segments: [
          WordTimingSegment(wordIndex: 0, startMs: 0, endMs: 800),
          WordTimingSegment(wordIndex: 1, startMs: 1200, endMs: 1800),
          WordTimingSegment(wordIndex: 2, startMs: 2000, endMs: 3200),
        ],
      ),
    ],
  );
}

SurahTimingData _timingDataForSurah(
  int surahNumber, {
  String reciterId = _supportedReciterId,
}) {
  return SurahTimingData(
    surahNumber: surahNumber,
    reciterId: reciterId,
    audioUrl: 'https://cdn.example.com/$surahNumber.mp3',
    hasWordSegments: true,
    ayahTimings: [
      AyahTimingData(
        verseKey: '$surahNumber:1',
        surahNumber: surahNumber,
        ayahNumber: 1,
        timestampFrom: 0,
        timestampTo: 3200,
        segments: const [
          WordTimingSegment(wordIndex: 0, startMs: 0, endMs: 900),
          WordTimingSegment(wordIndex: 1, startMs: 901, endMs: 1800),
          WordTimingSegment(wordIndex: 2, startMs: 1801, endMs: 3200),
        ],
      ),
    ],
  );
}
