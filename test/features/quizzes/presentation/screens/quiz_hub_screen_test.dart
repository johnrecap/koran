import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/screens/quiz_hub_screen.dart';
import 'package:quran_kareem/features/quizzes/providers/quiz_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

void main() {
  testWidgets(
      'renders all quiz type cards, shows mistake badges, disables unavailable types, and exposes the history action',
      (tester) async {
    var historyTapCount = 0;

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          quizTypeAvailabilityProvider.overrideWith((ref) async {
            return <QuizType, bool>{
              QuizType.verseCompletion: true,
              QuizType.wordMeaning: false,
              QuizType.verseTopic: true,
            };
          }),
          quizMistakeCountsProvider.overrideWith((ref) async {
            return <QuizType, int>{
              QuizType.verseCompletion: 5,
              QuizType.wordMeaning: 0,
              QuizType.verseTopic: 2,
            };
          }),
          surahsProvider.overrideWith((ref) async => _surahs),
        ],
        child: QuizHubScreen(
          onHistoryPressed: () {
            historyTapCount += 1;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Choose a quiz type and tune the session before you begin.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('quiz-type-card-verseCompletion')),
        findsOneWidget);
    expect(find.byKey(const Key('quiz-type-card-wordMeaning')), findsOneWidget);
    expect(find.text('5 to review'), findsOneWidget);
    expect(find.byKey(const Key('quiz-hub-history-action')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('quiz-type-card-verseTopic')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quiz-type-card-verseTopic')), findsOneWidget);
    expect(find.text('2 to review'), findsOneWidget);

    final unavailableButton = tester.widget<FilledButton>(
      find.byKey(const Key('quiz-type-card-button-wordMeaning')),
    );
    expect(unavailableButton.onPressed, isNull);

    await tester.tap(find.byKey(const Key('quiz-hub-history-action')));
    await tester.pump();

    expect(historyTapCount, 1);
  });

  testWidgets('opens the session configuration sheet for an available type',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          quizTypeAvailabilityProvider.overrideWith((ref) async {
            return <QuizType, bool>{
              QuizType.verseCompletion: true,
              QuizType.wordMeaning: true,
              QuizType.verseTopic: true,
            };
          }),
          quizMistakeCountsProvider.overrideWith((ref) async {
            return <QuizType, int>{
              QuizType.verseCompletion: 0,
              QuizType.wordMeaning: 0,
              QuizType.verseTopic: 0,
            };
          }),
          surahsProvider.overrideWith((ref) async => _surahs),
        ],
        child: const QuizHubScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('quiz-type-card-button-verseCompletion')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quiz setup'), findsOneWidget);
    expect(find.byKey(const Key('quiz-config-begin')), findsOneWidget);
  });

  testWidgets('renders localized quiz hub copy in Arabic RTL mode',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        locale: const Locale('ar'),
        overrides: [
          quizTypeAvailabilityProvider.overrideWith((ref) async {
            return <QuizType, bool>{
              QuizType.verseCompletion: true,
              QuizType.wordMeaning: true,
              QuizType.verseTopic: true,
            };
          }),
          quizMistakeCountsProvider.overrideWith((ref) async {
            return <QuizType, int>{
              QuizType.verseCompletion: 0,
              QuizType.wordMeaning: 0,
              QuizType.verseTopic: 0,
            };
          }),
          surahsProvider.overrideWith((ref) async => _surahs),
        ],
        child: const QuizHubScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final descriptionFinder = find.byKey(const Key('quiz-hub-description'));

    expect(descriptionFinder, findsOneWidget);
    expect(find.text('المسابقات'), findsOneWidget);
    expect(
      find.text('اختر نوع المسابقة واضبط الجلسة قبل أن تبدأ.'),
      findsOneWidget,
    );
    expect(
      Directionality.of(tester.element(descriptionFinder)),
      TextDirection.rtl,
    );
  });
}

Widget _buildHarness({
  required Widget child,
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

const List<Surah> _surahs = <Surah>[
  Surah(
    number: 1,
    nameArabic: 'الفاتحة',
    nameEnglish: 'Al-Fatihah',
    nameTransliteration: 'Al-Fatihah',
    ayahCount: 7,
    revelationType: 'Meccan',
    page: 1,
  ),
  Surah(
    number: 2,
    nameArabic: 'البقرة',
    nameEnglish: 'Al-Baqarah',
    nameTransliteration: 'Al-Baqarah',
    ayahCount: 286,
    revelationType: 'Medinan',
    page: 2,
  ),
];
