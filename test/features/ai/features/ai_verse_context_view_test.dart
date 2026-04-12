import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/domain/ai_response.dart';
import 'package:quran_kareem/features/ai/domain/verse_identifier.dart';
import 'package:quran_kareem/features/ai/features/context/ai_verse_context_view.dart';
import 'package:quran_kareem/features/ai/features/context/verse_context_provider.dart';

void main() {
  testWidgets('renders paragraph text on success', (tester) async {
    const verse = VerseIdentifier(surah: 2, ayah: 255);

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          verseContextProvider.overrideWith(
            (ref, arg) async => AiResponse.fromRaw(
              'This verse connects to the surrounding passage through divine authority and trust.',
              'test',
              100,
            ),
          ),
        ],
        child: const AiVerseContextView(verse: verse),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This verse connects to the surrounding passage through divine authority and trust.'), findsOneWidget);
    expect(find.byKey(const Key('ai-disclaimer-banner')), findsOneWidget);
  });

  testWidgets('shows shimmer while loading', (tester) async {
    const verse = VerseIdentifier(surah: 2, ayah: 255);

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          verseContextProvider.overrideWith(
            (ref, arg) => Future<AiResponse>.delayed(
              const Duration(seconds: 5),
              () => AiResponse.fromRaw(
                'Delayed context',
                'test',
                100,
              ),
            ),
          ),
        ],
        child: const AiVerseContextView(verse: verse),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('ai-loading-shimmer')), findsOneWidget);
  });
}

Widget _buildHarness({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: child),
    ),
  );
}
