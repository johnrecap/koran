import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';
import 'package:quran_kareem/features/tafsir/presentation/widgets/related_ayahs_section_view.dart';

void main() {
  testWidgets('renders cards and fires onTap for a related ayah entry',
      (tester) async {
    RelatedAyahEntry? tappedEntry;

    await tester.pumpWidget(
      _buildHarness(
        child: RelatedAyahsSectionView(
          entries: const <RelatedAyahEntry>[
            RelatedAyahEntry(
              surahNumber: 3,
              ayahNumber: 18,
              tag: 'thematic',
              snippet: 'Allah bears witness.',
            ),
            RelatedAyahEntry(
              surahNumber: 2,
              ayahNumber: 256,
              tag: 'linguistic',
            ),
          ],
          onTap: (entry) => tappedEntry = entry,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNWidgets(2));
    expect(find.text('Thematic'), findsOneWidget);
    expect(find.text('Linguistic'), findsOneWidget);
    expect(find.text('Surah 3 : Ayah 18'), findsOneWidget);
    expect(find.text('Allah bears witness.'), findsOneWidget);
    expect(find.text('Open Verse'), findsNWidgets(2));

    await tester.tap(find.text('Surah 3 : Ayah 18'));
    await tester.pump();

    expect(tappedEntry, isNotNull);
    expect(tappedEntry!.surahNumber, 3);
    expect(tappedEntry!.ayahNumber, 18);
  });

  testWidgets('renders Arabic labels and keeps RTL layout', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        locale: const Locale('ar'),
        child: const RelatedAyahsSectionView(
          entries: <RelatedAyahEntry>[
            RelatedAyahEntry(
              surahNumber: 3,
              ayahNumber: 18,
              tag: 'thematic',
              snippet: 'الله يشهد',
            ),
          ],
          onTap: _noopOnTap,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('موضوعي'), findsOneWidget);
    expect(find.text('فتح الآية'), findsOneWidget);
    expect(find.text('سورة 3 : الآية 18'), findsOneWidget);

    final directionality = tester.widget<Directionality>(
      find.descendant(
        of: find.byType(RelatedAyahsSectionView),
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

void _noopOnTap(RelatedAyahEntry _) {}
