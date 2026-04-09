import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/quizzes/domain/question_generator.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_difficulty.dart';
import 'package:quran_kareem/features/quizzes/domain/quiz_models.dart';
import 'package:quran_kareem/features/quizzes/presentation/widgets/quiz_session_config_sheet.dart';
import 'package:quran_kareem/features/quizzes/providers/quiz_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

void main() {
  testWidgets(
      'renders the selectors and emits the chosen quiz session config on begin',
      (tester) async {
    final submittedConfigs = <QuizSessionConfig>[];

    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          surahsProvider.overrideWith((ref) async => _surahs),
          wordMeaningGeneratorProvider.overrideWithValue(
            const _FakeQuestionGenerator(
              availabilityBySurah: <int?, bool>{
                null: true,
                1: true,
                2: true,
                112: false,
              },
            ),
          ),
        ],
        child: QuizSessionConfigSheet(
          quizType: QuizType.wordMeaning,
          onBegin: (config) async {
            submittedConfigs.add(config);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Question count'), findsOneWidget);
    expect(find.text('All Quran'), findsOneWidget);
    expect(find.text('Difficulty'), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quiz-config-count-20')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quiz-config-difficulty-hard')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quiz-config-surah-field')));
    await tester.pumpAndSettle();

    expect(find.text('Surah Al-Baqarah'), findsWidgets);
    expect(find.textContaining('Unavailable'), findsOneWidget);

    await tester.tap(find.text('Surah Al-Baqarah').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quiz-config-begin')));
    await tester.pumpAndSettle();

    expect(submittedConfigs, hasLength(1));
    expect(submittedConfigs.single.quizType, QuizType.wordMeaning);
    expect(submittedConfigs.single.questionCount, 20);
    expect(submittedConfigs.single.surahFilter, 2);
    expect(submittedConfigs.single.difficulty, QuizDifficulty.hard);
    expect(submittedConfigs.single.adaptiveDifficulty, isTrue);
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
      home: Scaffold(
        body: child,
      ),
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
  Surah(
    number: 112,
    nameArabic: 'الإخلاص',
    nameEnglish: 'Al-Ikhlas',
    nameTransliteration: 'Al-Ikhlas',
    ayahCount: 4,
    revelationType: 'Meccan',
    page: 604,
  ),
];

class _FakeQuestionGenerator implements QuestionGenerator {
  const _FakeQuestionGenerator({
    required this.availabilityBySurah,
  });

  final Map<int?, bool> availabilityBySurah;

  @override
  Future<List<QuizQuestion>> generate({
    required int count,
    required QuizDifficulty difficulty,
    int? surahFilter,
  }) async {
    return const <QuizQuestion>[];
  }

  @override
  Future<bool> isAvailable({
    int? surahFilter,
  }) async {
    return availabilityBySurah[surahFilter] ?? false;
  }
}
