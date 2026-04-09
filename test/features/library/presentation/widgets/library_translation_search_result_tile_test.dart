import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/library/presentation/widgets/library_translation_search_result_tile.dart';
import 'package:quran_kareem/features/library/providers/library_providers.dart';

void main() {
  testWidgets('highlights the matching query inside the translation text',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: LibraryTranslationSearchResultTile(
            result: LibraryTranslationSearchResult(
              ayah: Ayah(
                id: 1,
                surahNumber: 2,
                ayahNumber: 255,
                text: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
                page: 42,
                juz: 3,
                hizb: 1,
              ),
              surahName: 'البقرة',
              translationText: 'Mercy belongs to Allah alone.',
            ),
            query: 'Mercy',
            onTap: null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final translationText = tester.widget<Text>(
      find.byKey(
        const ValueKey<String>('library-translation-search-result-text'),
      ),
    );
    final text = translationText.textSpan!;

    expect(_containsHighlightedText(text, 'Mercy'), isTrue);
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
