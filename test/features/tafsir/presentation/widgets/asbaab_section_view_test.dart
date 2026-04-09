import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';
import 'package:quran_kareem/features/tafsir/presentation/widgets/asbaab_section_view.dart';

void main() {
  testWidgets('renders entries with localized source attribution and dividers',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        child: const AsbaabSectionView(
          entries: <AsbaabEntry>[
            AsbaabEntry(
              text: 'First asbaab entry',
              source: 'Al-Wahidi',
            ),
            AsbaabEntry(
              text: 'Second asbaab entry',
              source: 'Ibn Kathir',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('First asbaab entry'), findsOneWidget);
    expect(find.text('Second asbaab entry'), findsOneWidget);
    expect(find.text('Source: Al-Wahidi'), findsOneWidget);
    expect(find.text('Source: Ibn Kathir'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('renders Arabic source attribution and keeps RTL layout',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        locale: const Locale('ar'),
        child: const AsbaabSectionView(
          entries: <AsbaabEntry>[
            AsbaabEntry(
              text: 'سبب النزول',
              source: 'الواحدي',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('المصدر: الواحدي'), findsOneWidget);

    final directionality = tester.widget<Directionality>(
      find.descendant(
        of: find.byType(AsbaabSectionView),
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
