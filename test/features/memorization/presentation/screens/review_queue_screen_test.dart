import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/memorization/data/spaced_review_item.dart';
import 'package:quran_kareem/features/memorization/presentation/screens/review_queue_screen.dart';
import 'package:quran_kareem/features/memorization/providers/spaced_review_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
  });

  testWidgets(
    'shows due and upcoming review sections and opens a review session route',
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
                id: 'khatma-1_1_20',
                startPage: 1,
                endPage: 20,
                nextReviewAt: DateTime(2026, 3, 26),
              ).toMap(),
              _seedReviewItem(
                id: 'khatma-1_21_40',
                startPage: 21,
                endPage: 40,
                nextReviewAt: DateTime(2026, 3, 28),
              ).toMap(),
              _seedReviewItem(
                id: 'khatma-1_41_60',
                startPage: 41,
                endPage: 60,
                nextReviewAt: DateTime(2026, 3, 30),
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
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildHarness(
          container: container,
          initialLocation: '/memorization/reviews',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review queue'), findsOneWidget);
      expect(find.text('Due now'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
      final oldestDueFinder = find.textContaining('Pages 1 - 20');
      final newestDueFinder = find.textContaining('Pages 21 - 40');
      final upcomingFinder = find.textContaining('Pages 41 - 60');

      expect(oldestDueFinder, findsOneWidget);
      expect(newestDueFinder, findsOneWidget);
      expect(upcomingFinder, findsOneWidget);

      final oldestDueY = tester.getTopLeft(oldestDueFinder).dy;
      final newestDueY = tester.getTopLeft(newestDueFinder).dy;
      final upcomingY = tester.getTopLeft(upcomingFinder).dy;

      expect(oldestDueY, lessThan(newestDueY));
      expect(newestDueY, lessThan(upcomingY));

      await tester.tap(oldestDueFinder);
      await tester.pumpAndSettle();

      expect(find.text('Session route khatma-1_1_20'), findsOneWidget);
    },
  );

  testWidgets('shows a simple empty state when no review items exist', (
    tester,
  ) async {
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
      },
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _buildHarness(
        container: container,
        initialLocation: '/memorization/reviews',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No reviews yet'), findsOneWidget);
    expect(
      find.text('Finish a khatma range to unlock automatic reviews here.'),
      findsOneWidget,
    );
  });
}

Widget _buildHarness({
  required ProviderContainer container,
  required String initialLocation,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/memorization/reviews',
            builder: (context, state) => const ReviewQueueScreen(),
          ),
          GoRoute(
            path: '/memorization/reviews/:reviewId',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text(
                  'Session route ${state.pathParameters['reviewId']}',
                ),
              ),
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
