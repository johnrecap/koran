import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/widgets/ai_disclaimer_banner.dart';

void main() {
  testWidgets('banner renders localized disclaimer text and info icon',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: const AiDisclaimerBanner(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This is a technical summary and does not replace the full tafsir.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
  });
}

Widget _buildHarness({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: child,
        ),
      ),
    ),
  );
}
