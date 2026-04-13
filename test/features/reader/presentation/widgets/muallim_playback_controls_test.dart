import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/reader/domain/muallim_models.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/muallim_playback_controls.dart';

void main() {
  testWidgets('renders current ayah and forwards playback callbacks',
      (tester) async {
    var previousTapped = false;
    var primaryTapped = false;
    var nextTapped = false;
    var stopTapped = false;
    var reciterTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: MuallimPlaybackControls(
            snapshot: MuallimSnapshot.fromPlayback(
              const MuallimPlaybackSnapshot(
                playbackState: MuallimPlaybackState.playing,
                currentAyah: MuallimAyahPosition(
                  surahNumber: 2,
                  ayahNumber: 255,
                  ayahUQNumber: 281,
                  pageNumber: 42,
                ),
                position: Duration(seconds: 3),
                duration: Duration(seconds: 7),
                currentReciterId: 'reader-1',
                currentReciterName: 'Reader One',
              ),
              isEnabled: true,
            ),
            onPreviousAyah: () => previousTapped = true,
            onPrimaryAction: () => primaryTapped = true,
            onNextAyah: () => nextTapped = true,
            onStop: () => stopTapped = true,
            onSelectReciter: () => reciterTapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('2:255'), findsOneWidget);
    expect(find.text('Reader One'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('muallim-prev')));
    await tester.pump();
    expect(previousTapped, isTrue);

    await tester.tap(find.byKey(const ValueKey<String>('muallim-primary')));
    await tester.pump();
    expect(primaryTapped, isTrue);

    await tester.tap(find.byKey(const ValueKey<String>('muallim-next')));
    await tester.pump();
    expect(nextTapped, isTrue);

    await tester.tap(find.byKey(const ValueKey<String>('muallim-stop')));
    await tester.pump();
    expect(stopTapped, isTrue);

    await tester.tap(find.byKey(const ValueKey<String>('muallim-reciter')));
    await tester.pump();
    expect(reciterTapped, isTrue);
  });
}
