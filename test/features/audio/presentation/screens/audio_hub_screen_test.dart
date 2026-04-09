import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/audio/data/audio_hub_playback_service.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_playback_snapshot.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_option.dart';
import 'package:quran_kareem/features/audio/presentation/screens/audio_hub_screen.dart';
import 'package:quran_kareem/features/audio/providers/audio_providers.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';

void main() {
  testWidgets('shows a loading state while the audio hub initializes',
      (tester) async {
    final pendingInitialization = Completer<void>();
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 1,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: false,
        isPlaying: false,
        isBuffering: false,
        position: Duration.zero,
        duration: Duration.zero,
      ),
      ensureCompleter: pendingInitialization,
    );

    await tester.pumpWidget(
      _buildHarness(
        service: service,
      ),
    );
    await tester.pump();

    expect(find.text('Loading audio player...'), findsOneWidget);
  });

  testWidgets('renders the current surah and delegates play/select actions', (
    tester,
  ) async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 2,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: false,
        isBuffering: false,
        position: Duration(seconds: 10),
        duration: Duration(minutes: 3),
      ),
    );

    await tester.pumpWidget(
      _buildHarness(
        service: service,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_surahs[1].nameArabic), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Reader A'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    expect(service.playCalls, 1);

    await tester.tap(find.text('Select reciter'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Reader B'));
    await tester.tap(find.text('Reader B'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(service.lastSelectedReciterId, 'reader-b');

    await tester.tap(find.text('Select surah'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(_surahs[2].nameArabic));
    await tester.tap(find.text(_surahs[2].nameArabic), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(service.lastSelectedSurahNumber, 3);
    expect(service.lastAutoPlayValue, isTrue);
  });

  testWidgets('shows an app-owned retry state when initialization fails', (
    tester,
  ) async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 1,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: false,
        isPlaying: false,
        isBuffering: false,
        position: Duration.zero,
        duration: Duration.zero,
      ),
      initializeErrors: [
        TimeoutException(
          'Audio controller did not finish bootstrapping.',
          const Duration(seconds: 15),
        ),
      ],
    );

    await tester.pumpWidget(
      _buildHarness(
        service: service,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Unable to load the audio player right now.'),
        findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('retry recovers the audio screen after a bootstrap timeout', (
    tester,
  ) async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 2,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: false,
        isBuffering: false,
        position: Duration(seconds: 10),
        duration: Duration(minutes: 3),
      ),
      initializeErrors: [
        TimeoutException(
          'Audio controller did not finish bootstrapping.',
          const Duration(seconds: 15),
        ),
      ],
    );

    await tester.pumpWidget(
      _buildHarness(
        service: service,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(service.ensureInitializedCalls, 2);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Reader A'), findsOneWidget);
  });

  testWidgets('previews slider drag locally before sending seek on release', (
    tester,
  ) async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 2,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: false,
        isBuffering: false,
        position: Duration(seconds: 10),
        duration: Duration(minutes: 3),
      ),
    );

    await tester.pumpWidget(
      _buildHarness(
        service: service,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final initialSlider = tester.widget<Slider>(find.byType(Slider));
    expect(initialSlider.value, 10000);

    initialSlider.onChanged!(60000);
    await tester.pump();

    final previewSlider = tester.widget<Slider>(find.byType(Slider));
    expect(previewSlider.value, 60000);
    expect(service.lastSeekPosition, isNull);

    previewSlider.onChangeEnd!(60000);
    await tester.pump();

    expect(service.lastSeekPosition, const Duration(minutes: 1));
  });

  testWidgets('shows a snackbar when switching reciters fails', (tester) async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 2,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: false,
        isBuffering: false,
        position: Duration(seconds: 10),
        duration: Duration(minutes: 3),
      ),
      selectReciterError: StateError('switch failed'),
    );

    await tester.pumpWidget(
      _buildHarness(
        service: service,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select reciter'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Reader B'));
    await tester.tap(find.text('Reader B'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Unable to switch reciter right now.'), findsOneWidget);
  });

  testWidgets('opens the app-owned audio downloads route from the hub',
      (tester) async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 2,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: false,
        isBuffering: false,
        position: Duration(seconds: 10),
        duration: Duration(minutes: 3),
      ),
    );

    await tester.pumpWidget(
      _buildRouterHarness(
        service: service,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final downloadsEntry =
        find.byKey(const Key('audio-download-manager-entry'));
    expect(downloadsEntry, findsOneWidget);

    await tester.tap(downloadsEntry);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Downloads destination'), findsOneWidget);
  });
}

Widget _buildHarness({
  required FakeAudioHubPlaybackService service,
}) {
  return ProviderScope(
    overrides: [
      audioHubPlaybackServiceProvider.overrideWithValue(service),
      allSurahsProvider.overrideWith((ref) async => _surahs),
    ],
    child: const MaterialApp(
      locale: Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: AudioHubScreen(),
    ),
  );
}

Widget _buildRouterHarness({
  required FakeAudioHubPlaybackService service,
}) {
  final router = GoRouter(
    initialLocation: '/audio',
    routes: [
      GoRoute(
        path: '/audio',
        builder: (context, state) => const AudioHubScreen(),
      ),
      GoRoute(
        path: '/audio/downloads',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Downloads destination'),
          ),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      audioHubPlaybackServiceProvider.overrideWithValue(service),
      allSurahsProvider.overrideWith((ref) async => _surahs),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    ),
  );
}

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
    ayahCount: 286,
    revelationType: 'Medinan',
    page: 2,
  ),
  Surah(
    number: 3,
    nameArabic: 'آل عمران',
    nameEnglish: 'Ali Imran',
    nameTransliteration: 'Ali Imran',
    ayahCount: 200,
    revelationType: 'Medinan',
    page: 50,
  ),
];

class FakeAudioHubPlaybackService implements AudioHubPlaybackService {
  FakeAudioHubPlaybackService({
    required AudioHubPlaybackSnapshot initialSnapshot,
    this.ensureCompleter,
    this.initializeError,
    this.selectReciterError,
    List<Object> initializeErrors = const <Object>[],
  })  : _snapshot = initialSnapshot,
        _initializeErrors = List<Object>.from(initializeErrors);

  final Completer<void>? ensureCompleter;
  final Object? initializeError;
  final Object? selectReciterError;
  final List<Object> _initializeErrors;

  final _controller = StreamController<AudioHubPlaybackSnapshot>.broadcast();
  final AudioHubPlaybackSnapshot _snapshot;
  int ensureInitializedCalls = 0;
  int playCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;
  int? lastSelectedSurahNumber;
  bool? lastAutoPlayValue;
  String? lastSelectedReciterId;
  Duration? lastSeekPosition;

  @override
  List<AudioHubReciterOption> get availableReciters =>
      const <AudioHubReciterOption>[
        AudioHubReciterOption(index: 0, id: 'reader-a', name: 'Reader A'),
        AudioHubReciterOption(index: 1, id: 'reader-b', name: 'Reader B'),
      ];

  @override
  bool get hasActiveSession => _snapshot.hasActiveSession;

  @override
  Stream<bool> get sessionActivity => const Stream<bool>.empty();

  @override
  Stream<AudioHubPlaybackSnapshot> get snapshots => _controller.stream;

  @override
  Future<AudioHubPlaybackSnapshot> ensureInitialized() async {
    ensureInitializedCalls += 1;
    if (_initializeErrors.isNotEmpty) {
      throw _initializeErrors.removeAt(0);
    }
    if (initializeError != null) {
      throw initializeError!;
    }
    if (ensureCompleter != null) {
      await ensureCompleter!.future;
    }
    return _snapshot;
  }

  @override
  Future<void> pause() async {
    pauseCalls += 1;
  }

  @override
  Future<void> play() async {
    playCalls += 1;
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }

  @override
  Future<void> playNextSurah() async {}

  @override
  Future<void> playPreviousSurah() async {}

  @override
  Future<void> seek(Duration position) async {
    lastSeekPosition = position;
  }

  @override
  Future<void> selectSurah(int surahNumber, {bool autoPlay = true}) async {
    lastSelectedSurahNumber = surahNumber;
    lastAutoPlayValue = autoPlay;
  }

  @override
  Future<void> selectReciter(
    String reciterId, {
    bool restartPlayback = true,
  }) async {
    if (selectReciterError != null) {
      throw selectReciterError!;
    }
    lastSelectedReciterId = reciterId;
  }

  @override
  void dispose() {
    _controller.close();
  }
}
