import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/verse_action_menu.dart';

void main() {
  testWidgets('keeps sciences as a direct action and forwards listen callbacks',
      (
    tester,
  ) async {
    var listenTapped = false;
    var insightsTapped = false;
    var translationsTapped = false;
    var copyTapped = false;
    var noteTapped = false;
    var tadabburTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: VerseActionMenu(
            ayah: const Ayah(
              id: 281,
              surahNumber: 2,
              ayahNumber: 255,
              text: 'Allah! There is no god but He.',
              page: 42,
              juz: 3,
              hizb: 1,
            ),
            onDismiss: () {},
            onListen: () => listenTapped = true,
            onBookmark: () {},
            onShare: () {},
            onTranslations: () => translationsTapped = true,
            onCopy: () => copyTapped = true,
            onNote: () => noteTapped = true,
            onTadabbur: () => tadabburTapped = true,
            onInsights: () => insightsTapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('verse-action-listen')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('verse-action-insights')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('verse-action-sciences-back')),
      findsNothing,
    );

    await tester.tap(find.byIcon(Icons.headphones_rounded));
    await tester.pump();
    expect(listenTapped, isTrue);

    await tester.tap(find.byIcon(Icons.auto_stories_rounded));
    await tester.pump();
    expect(insightsTapped, isTrue);

    await tester.tap(find.byIcon(Icons.translate_rounded));
    await tester.pump();
    expect(translationsTapped, isTrue);

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();
    expect(copyTapped, isTrue);

    await tester.tap(find.byIcon(Icons.note_alt_rounded));
    await tester.pump();
    expect(noteTapped, isTrue);

    expect(
      find.byKey(const ValueKey<String>('verse-action-tadabbur')),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.self_improvement_rounded));
    await tester.pump();
    expect(tadabburTapped, isTrue);
  });
}
