import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/features/simplify/ai_simplify_button.dart';
import 'package:quran_kareem/features/ai/providers/ai_providers.dart';

void main() {
  testWidgets('renders the button when AI is available', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          aiAvailableProvider.overrideWith((ref) => true),
          aiQuotaExhaustedProvider.overrideWith((ref) async => false),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Simplify tafsir'), findsOneWidget);
  });

  testWidgets('hides the button when AI is unavailable', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          aiAvailableProvider.overrideWith((ref) => false),
          aiQuotaExhaustedProvider.overrideWith((ref) async => false),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AiSimplifyButton), findsOneWidget);
    expect(find.byKey(const Key('ai-simplify-button')), findsNothing);
  });

  testWidgets('disables the button when quota is exhausted', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          aiAvailableProvider.overrideWith((ref) => true),
          aiQuotaExhaustedProvider.overrideWith((ref) async => true),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('ai-simplify-button')),
    );

    expect(button.onPressed, isNull);
  });

  testWidgets('invokes onPressed when tapped', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          aiAvailableProvider.overrideWith((ref) => true),
          aiQuotaExhaustedProvider.overrideWith((ref) async => false),
        ],
        onPressed: () {
          tapCount += 1;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ai-simplify-button')));
    await tester.pump();

    expect(tapCount, 1);
  });
}

Widget _buildHarness({
  List<Override> overrides = const [],
  VoidCallback? onPressed,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Center(
          child: AiSimplifyButton(
            onPressed: onPressed ?? () {},
          ),
        ),
      ),
    ),
  );
}
