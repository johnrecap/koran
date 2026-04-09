import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/widgets/app_shell.dart';
import 'package:quran_kareem/features/audio/data/audio_hub_playback_service.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_playback_snapshot.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_option.dart';
import 'package:quran_kareem/features/audio/providers/audio_providers.dart';
import 'package:quran_kareem/features/reader/domain/reader_session_intent.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

void main() {
  testWidgets(
      'shows the shell mini player on non-audio tabs and delegates controls',
      (tester) async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 2,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: true,
        isBuffering: false,
        position: Duration(seconds: 20),
        duration: Duration(minutes: 3),
      ),
      initialSessionActive: true,
    );

    await tester.pumpWidget(
      _buildHarness(
        service: service,
        initialLocation: '/library',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reader A'), findsOneWidget);
    expect(find.text('Surah 2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(service.pauseCalls, 1);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(service.stopCalls, 1);

    await tester.tap(find.text('Reader A'));
    await tester.pumpAndSettle();
    expect(find.text('Audio route'), findsOneWidget);
  });

  testWidgets('hides the shell mini player on the audio route', (tester) async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 2,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: true,
        isBuffering: false,
        position: Duration(seconds: 20),
        duration: Duration(minutes: 3),
      ),
      initialSessionActive: true,
    );

    await tester.pumpWidget(
      _buildHarness(
        service: service,
        initialLocation: '/audio',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reader A'), findsNothing);
  });

  testWidgets('hides the shell mini player while reader fullscreen is active',
      (tester) async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 2,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: true,
        isPlaying: true,
        isBuffering: false,
        position: Duration(seconds: 20),
        duration: Duration(minutes: 3),
      ),
      initialSessionActive: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioHubPlaybackServiceProvider.overrideWithValue(service),
          readerFullscreenModeProvider.overrideWith((ref) => true),
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: _router(initialLocation: '/reader'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reader A'), findsNothing);
  });

  testWidgets('reader tab clears stale khatma intent before generic re-entry',
      (tester) async {
    final service = FakeAudioHubPlaybackService(
      initialSnapshot: const AudioHubPlaybackSnapshot(
        selectedSurahNumber: 2,
        currentReciterId: 'reader-a',
        currentReciterName: 'Reader A',
        hasActiveSession: false,
        isPlaying: false,
        isBuffering: false,
        position: Duration.zero,
        duration: Duration.zero,
      ),
      initialSessionActive: false,
    );
    final container = ProviderContainer(
      overrides: [
        audioHubPlaybackServiceProvider.overrideWithValue(service),
        readerSessionIntentProvider.overrideWith(
          (ref) => const ReaderSessionIntent.khatma('khatma-1'),
        ),
      ],
    );
    addTearDown(() {
      container.dispose();
      service.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: _router(initialLocation: '/library'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(readerSessionIntentProvider).trackedKhatmaId,
        'khatma-1');

    await tester.tap(find.byIcon(Icons.menu_book_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Reader route'), findsOneWidget);
    expect(container.read(readerSessionIntentProvider).isKhatmaOwned, isFalse);
    expect(container.read(readerSessionIntentProvider).trackedKhatmaId, isNull);
  });
}

Widget _buildHarness({
  required FakeAudioHubPlaybackService service,
  required String initialLocation,
}) {
  return ProviderScope(
    overrides: [
      audioHubPlaybackServiceProvider.overrideWithValue(service),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: _router(initialLocation: initialLocation),
    ),
  );
}

GoRouter _router({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/library',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Library route')),
            ),
          ),
          GoRoute(
            path: '/audio',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Audio route')),
            ),
          ),
          GoRoute(
            path: '/reader',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Reader route')),
            ),
          ),
        ],
      ),
    ],
  );
}

class FakeAudioHubPlaybackService implements AudioHubPlaybackService {
  FakeAudioHubPlaybackService({
    required AudioHubPlaybackSnapshot initialSnapshot,
    required bool initialSessionActive,
  })  : _snapshot = initialSnapshot,
        _hasActiveSession = initialSessionActive;

  final _snapshotController =
      StreamController<AudioHubPlaybackSnapshot>.broadcast();
  final _sessionController = StreamController<bool>.broadcast();
  final AudioHubPlaybackSnapshot _snapshot;
  final bool _hasActiveSession;
  int playCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;

  @override
  List<AudioHubReciterOption> get availableReciters =>
      const <AudioHubReciterOption>[
        AudioHubReciterOption(index: 0, id: 'reader-a', name: 'Reader A'),
      ];

  @override
  bool get hasActiveSession => _hasActiveSession;

  @override
  Stream<AudioHubPlaybackSnapshot> get snapshots => _snapshotController.stream;

  @override
  Stream<bool> get sessionActivity => _sessionController.stream;

  @override
  Future<AudioHubPlaybackSnapshot> ensureInitialized() async => _snapshot;

  @override
  Future<void> pause() async {
    pauseCalls += 1;
  }

  @override
  Future<void> play() async {
    playCalls += 1;
  }

  @override
  Future<void> playNextSurah() async {}

  @override
  Future<void> playPreviousSurah() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> selectReciter(
    String reciterId, {
    bool restartPlayback = true,
  }) async {}

  @override
  Future<void> selectSurah(int surahNumber, {bool autoPlay = true}) async {}

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }

  @override
  void dispose() {
    _snapshotController.close();
    _sessionController.close();
  }
}
