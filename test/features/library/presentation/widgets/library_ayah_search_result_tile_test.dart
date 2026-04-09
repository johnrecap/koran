import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/library/presentation/widgets/library_ayah_search_result_tile.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';

void main() {
  testWidgets('highlights the matching query inside the ayah text',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: LibraryAyahSearchResultTile(
            result: LibraryAyahSearchResult(
              ayah: Ayah(
                id: 1,
                surahNumber: 2,
                ayahNumber: 255,
                text: 'الله لا إله إلا هو',
                page: 42,
                juz: 3,
                hizb: 1,
              ),
              surahName: 'البقرة',
            ),
            query: 'الله',
            onTap: null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final richText = tester.widget<RichText>(
      find.byKey(const ValueKey<String>('library-search-result-text')),
    );
    final text = richText.text as TextSpan;

    expect(_containsHighlightedText(text, 'الله'), isTrue);
  });
}

bool _containsHighlightedText(InlineSpan span, String value) {
  if (span is TextSpan) {
    if (span.text == value && span.style?.color != null) {
      return true;
    }
    for (final child in span.children ?? const <InlineSpan>[]) {
      if (_containsHighlightedText(child, value)) {
        return true;
      }
    }
  }
  return false;
}
