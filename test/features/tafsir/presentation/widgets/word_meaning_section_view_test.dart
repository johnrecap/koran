import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';
import 'package:quran_kareem/features/tafsir/presentation/widgets/word_meaning_section_view.dart';

void main() {
  testWidgets('renders word chips and shows the root badge when present',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: const WordMeaningSectionView(
          entries: <WordMeaningEntry>[
            WordMeaningEntry(
              word: 'اللَّهُ',
              meaning: 'Allah',
              root: 'أله',
            ),
            WordMeaningEntry(
              word: 'الرحمن',
              meaning: 'The Most Merciful',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('اللَّهُ'), findsOneWidget);
    expect(find.text('Allah'), findsOneWidget);
    expect(find.text('الرحمن'), findsOneWidget);
    expect(find.text('The Most Merciful'), findsOneWidget);
    expect(find.text('Root: أله'), findsOneWidget);
    expect(find.textContaining('Root:'), findsOneWidget);
  });

  testWidgets('renders the localized root label and keeps RTL layout in Arabic',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        locale: const Locale('ar'),
        child: const WordMeaningSectionView(
          entries: <WordMeaningEntry>[
            WordMeaningEntry(
              word: 'اللَّه',
              meaning: 'الله',
              root: 'أ ل ه',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الجذر: أ ل ه'), findsOneWidget);

    final directionality = tester.widget<Directionality>(
      find.descendant(
        of: find.byType(WordMeaningSectionView),
        matching: find.byType(Directionality),
      ),
    );
    expect(directionality.textDirection, TextDirection.rtl);
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
    home: Scaffold(body: child),
  );
}
