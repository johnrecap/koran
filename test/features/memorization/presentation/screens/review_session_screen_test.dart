import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/presentation/screens/review_session_screen.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/memorization/providers/spaced_review_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
  });

  testWidgets(
    'opens the reader from the review range and records the chosen outcome',
    (tester) async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          'khatmas': jsonEncode(
            [
              {
                'id': 'khatma-1',
                'title': 'Weekly Khatma',
                'targetDays': 7,
                'startDate': DateTime(2026, 3, 20).toIso8601String(),
                'startPage': 1,
                'furthestPageRead': 0,
                'totalReadMinutes': 0,
                'readingDayKeys': const <String>[],
              },
            ],
          ),
          'spacedReviewItems': jsonEncode(
            [
              _seedReviewItem(
                id: 'khatma-1_10_20',
                startPage: 10,
                endPage: 20,
                nextReviewAt: DateTime(2026, 3, 28),
              ).toMap(),
            ],
          ),
        },
      );

      final container = ProviderContainer(
        overrides: [
          spacedReviewNowProvider.overrideWith(
            (ref) => () => DateTime(2026, 3, 28, 10),
          ),
          memorizationPageAyahResolverProvider.overrideWith((ref) {
            return (int pageNumber) async => Ayah(
                  id: 1,
                  surahNumber: 2,
                  ayahNumber: 255,
                  text: '',
                  page: pageNumber,
                  juz: 3,
                  hizb: 5,
                );
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildHarness(container));
      await tester.pumpAndSettle();

      expect(find.text('Review session'), findsOneWidget);
      expect(find.text('Open in reader'), findsOneWidget);
      expect(find.text('How was this review?'), findsNothing);

      await tester.tap(find.text('Open in reader'));
      await tester.pumpAndSettle();

      expect(find.text('Reader route 2:10 general'), findsOneWidget);
      expect(container.read(readerSessionIntentProvider).isKhatmaOwned, isFalse);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('How was this review?'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);

      await tester.tap(find.text('Hard'));
      await tester.pumpAndSettle();

      final updatedItem = container.read(spacedReviewItemsProvider).single;
      expect(updatedItem.lastOutcome, ReviewOutcome.hard);
      expect(updatedItem.lastReviewedAt, DateTime(2026, 3, 28));
      expect(updatedItem.nextReviewAt, DateTime(2026, 3, 29));
      expect(find.text('Review queue'), findsOneWidget);
    },
  );
}

Widget _buildHarness(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: '/memorization/reviews/khatma-1_10_20',
        routes: [
          GoRoute(
            path: '/memorization/reviews',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Review queue'),
              ),
            ),
          ),
          GoRoute(
            path: '/memorization/reviews/:reviewId',
            builder: (context, state) => ReviewSessionScreen(
              reviewId: state.pathParameters['reviewId']!,
            ),
          ),
          GoRoute(
            path: '/reader',
            builder: (context, state) => Consumer(
              builder: (context, ref, child) {
                final surahNumber = ref.watch(currentSurahProvider);
                final pageNumber = ref.watch(quranPageIndexProvider);
                final intent = ref.watch(readerSessionIntentProvider);

                return Scaffold(
                  appBar: AppBar(),
                  body: Center(
                    child: Text(
                      'Reader route $surahNumber:$pageNumber ${intent.owner.name}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

SpacedReviewItem _seedReviewItem({
  required String id,
  required int startPage,
  required int endPage,
  required DateTime nextReviewAt,
}) {
  return SpacedReviewItem(
    id: id,
    khatmaId: 'khatma-1',
    khatmaTitle: 'Weekly Khatma',
    startPage: startPage,
    endPage: endPage,
    createdAt: DateTime(2026, 3, 20),
    nextReviewAt: nextReviewAt,
    repetitionCount: 0,
    intervalDays: 1,
    easeFactor: 2.3,
  );
}
