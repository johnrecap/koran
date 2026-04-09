import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_config.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';
import 'package:quran_kareem/features/tafsir/presentation/widgets/insight_section_shell.dart';

void main() {
  testWidgets('shows the localized header and child when data is loaded',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: const InsightSectionShell(
          config: tafsirInsightSectionConfig,
          data: InsightSectionLoaded<String>('tafsir body'),
          child: Text('Loaded body'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tafsir'), findsOneWidget);
    expect(find.text('Loaded body'), findsOneWidget);
    expect(find.text('Collapse'), findsOneWidget);
  });

  testWidgets('returns a shrink box when the section is unavailable',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: const InsightSectionShell(
          config: tafsirInsightSectionConfig,
          data: InsightSectionUnavailable(),
          child: Text('Hidden body'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hidden body'), findsNothing);
    expect(find.text('Tafsir'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox && widget.width == 0 && widget.height == 0,
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows a compact localized error state when the section fails',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: InsightSectionShell(
          config: tafsirInsightSectionConfig,
          data: InsightSectionError(StateError('boom')),
          child: const Text('Unused body'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tafsir'), findsOneWidget);
    expect(find.text('Unable to load this data right now.'), findsOneWidget);
    expect(find.text('Unused body'), findsNothing);
  });
}

Widget _buildHarness({required Widget child}) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: Center(child: child)),
  );
}
