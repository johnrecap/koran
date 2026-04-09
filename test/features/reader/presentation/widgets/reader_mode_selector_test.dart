import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/reader/domain/reader_mode_policy.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/reader_mode_selector.dart';

void main() {
  testWidgets('exposes the three reader modes explicitly', (tester) async {
    ReaderMode? selectedMode;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: Center(
            child: ReaderModeSelector(
              currentMode: ReaderMode.scroll,
              onChanged: (mode) => selectedMode = mode,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('reader-mode-scroll')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('reader-mode-page')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('reader-mode-translation')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('reader-mode-translation')),
    );
    await tester.pump();

    expect(selectedMode, ReaderMode.translation);
  });
}
