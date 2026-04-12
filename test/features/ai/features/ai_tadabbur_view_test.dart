import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/ai/domain/verse_identifier.dart';
import 'package:quran_kareem/features/ai/features/tadabbur/ai_tadabbur_view.dart';
import 'package:quran_kareem/features/ai/features/tadabbur/tadabbur_questions_provider.dart';

void main() {
  testWidgets('renders numbered question list', (tester) async {
    const verse = VerseIdentifier(surah: 2, ayah: 255);

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          tadabburQuestionsProvider.overrideWith(
            (ref, arg) async => const [
              'What does this verse teach about reliance on Allah?',
              'How should this meaning affect daily choices?',
            ],
          ),
        ],
        child: const AiTadabburView(verse: verse),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1. What does this verse teach about reliance on Allah?'), findsOneWidget);
    expect(find.text('2. How should this meaning affect daily choices?'), findsOneWidget);
  });

  testWidgets('shows disclaimer below questions', (tester) async {
    const verse = VerseIdentifier(surah: 2, ayah: 255);

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          tadabburQuestionsProvider.overrideWith(
            (ref, arg) async => const [
              'What meaning stands out to you most in this verse?',
            ],
          ),
        ],
        child: const AiTadabburView(verse: verse),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-disclaimer-banner')), findsOneWidget);
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
