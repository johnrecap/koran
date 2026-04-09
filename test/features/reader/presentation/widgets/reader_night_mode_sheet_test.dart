import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_style.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_night_mode_sheet.dart';

void main() {
  testWidgets('renders Normal, Night, and AMOLED and reports selections', (
    tester,
  ) async {
    ReaderNightPresentation? selectedPresentation;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: ReaderNightModeSheet(
            currentPresentation: ReaderNightPresentation.normal,
            onSelected: (presentation) {
              selectedPresentation = presentation;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('reader-night-mode-normal')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('reader-night-mode-night')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('reader-night-mode-amoled')),
        findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('reader-night-mode-amoled')),
    );
    await tester.pump();

    expect(selectedPresentation, ReaderNightPresentation.amoled);
  });
}
