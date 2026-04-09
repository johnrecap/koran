import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/quizzes/data/quiz_history_repository.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/screens/quiz_history_screen.dart';
import 'package:quran_kareem/features/quizzes/providers/quiz_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

void main() {
  testWidgets(
      'renders quiz type toggles, shows charted history when enough data exists, and falls back to the chart zero state when it does not',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        quizHistoryRepositoryProvider.overrideWithValue(
          _FakeQuizHistoryRepository(
            entriesByType: <QuizType, List<QuizHistoryEntry>>{
              QuizType.verseCompletion: <QuizHistoryEntry>[
                QuizHistoryEntry(
                  quizType: QuizType.verseCompletion,
                  score: 3,
                  totalQuestions: 5,
                  difficulty: QuizDifficulty.easy,
                  surahFilter: 1,
                  completedAt: DateTime(2026, 4, 4),
                ),
                QuizHistoryEntry(
                  quizType: QuizType.verseCompletion,
                  score: 4,
                  totalQuestions: 5,
                  difficulty: QuizDifficulty.medium,
                  surahFilter: 2,
                  completedAt: DateTime(2026, 4, 5),
                ),
                QuizHistoryEntry(
                  quizType: QuizType.verseCompletion,
                  score: 5,
                  totalQuestions: 5,
                  difficulty: QuizDifficulty.hard,
                  surahFilter: null,
                  completedAt: DateTime(2026, 4, 6),
                ),
              ],
              QuizType.wordMeaning: <QuizHistoryEntry>[
                QuizHistoryEntry(
                  quizType: QuizType.wordMeaning,
                  score: 2,
                  totalQuestions: 5,
                  difficulty: QuizDifficulty.easy,
                  surahFilter: 1,
                  completedAt: DateTime(2026, 4, 2),
                ),
                QuizHistoryEntry(
                  quizType: QuizType.wordMeaning,
                  score: 3,
                  totalQuestions: 5,
                  difficulty: QuizDifficulty.medium,
                  surahFilter: 1,
                  completedAt: DateTime(2026, 4, 3),
                ),
              ],
              QuizType.verseTopic: const <QuizHistoryEntry>[],
            },
          ),
        ),
        surahsProvider.overrideWith((ref) async => _surahs),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        child: const QuizHistoryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.byKey(const Key('quiz-history-type-verseCompletion')), findsOneWidget);
    expect(find.byKey(const Key('quiz-history-type-wordMeaning')), findsOneWidget);
    expect(find.byKey(const Key('quiz-history-type-verseTopic')), findsOneWidget);
    expect(find.byKey(const Key('quiz-progress-chart')), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Date'), findsWidgets);
    expect(find.text('Score'), findsWidgets);
    expect(find.text('Difficulty'), findsWidgets);
    expect(find.byKey(const Key('quiz-history-entry-date')), findsWidgets);

    await tester.scrollUntilVisible(
      find.textContaining('Al-Baqarah'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Al-Baqarah'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('All Quran'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('All Quran'), findsOneWidget);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 600));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quiz-history-type-wordMeaning')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('60%'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Complete more quizzes to see your progress'),
      findsOneWidget,
    );
    expect(find.text('60%'), findsOneWidget);
    expect(find.textContaining('Al-Fatihah'), findsWidgets);
    expect(find.textContaining('Al-Baqarah'), findsNothing);
  });

  testWidgets('renders quiz history metadata in Arabic RTL mode', (tester) async {
    final container = ProviderContainer(
      overrides: [
        quizHistoryRepositoryProvider.overrideWithValue(
          _FakeQuizHistoryRepository(
            entriesByType: <QuizType, List<QuizHistoryEntry>>{
              QuizType.verseCompletion: <QuizHistoryEntry>[
                QuizHistoryEntry(
                  quizType: QuizType.verseCompletion,
                  score: 4,
                  totalQuestions: 5,
                  difficulty: QuizDifficulty.medium,
                  surahFilter: 2,
                  completedAt: DateTime(2026, 4, 6),
                ),
              ],
            },
          ),
        ),
        surahsProvider.overrideWith((ref) async => _surahs),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        locale: const Locale('ar'),
        child: const QuizHistoryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final entryFinder = find.byKey(const Key('quiz-history-entry-date')).first;

    expect(find.text('السجل'), findsOneWidget);
    expect(find.text('التاريخ'), findsWidgets);
    expect(find.text('النتيجة'), findsWidgets);
    expect(find.text('الصعوبة'), findsWidgets);
    expect(
      Directionality.of(tester.element(entryFinder)),
      TextDirection.rtl,
    );
  });
}

Widget _buildHarness({
  required ProviderContainer container,
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

class _FakeQuizHistoryRepository extends QuizHistoryRepository {
  _FakeQuizHistoryRepository({
    required this.entriesByType,
  });

  final Map<QuizType, List<QuizHistoryEntry>> entriesByType;

  @override
  Future<List<QuizHistoryEntry>> getHistory(QuizType type) async {
    return List<QuizHistoryEntry>.from(
      entriesByType[type] ?? const <QuizHistoryEntry>[],
    );
  }
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
