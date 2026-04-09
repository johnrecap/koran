import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/memorization/providers/memorization_providers.dart';
import 'package:quran_kareem/features/memorization/providers/spaced_review_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test('loads persisted review items and syncs missing items from active khatma progress',
      () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'khatmas': jsonEncode(
          [
            {
              'id': 'khatma-1',
              'title': 'Monthly Khatma',
              'targetDays': 30,
              'startDate': DateTime(2026, 3, 1).toIso8601String(),
              'startPage': 1,
              'furthestPageRead': 45,
              'totalReadMinutes': 12,
              'readingDayKeys': const <String>[],
            },
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

    await container.read(khatmasProvider.notifier).ready;
    await container.read(spacedReviewItemsProvider.notifier).ready;

    final items = container.read(spacedReviewItemsProvider);
    final prefs = await UserPreferences.prefs;

    expect(items, hasLength(2));
    expect(items.first.startPage, 1);
    expect(items.last.endPage, 42);
    expect(prefs.getString('spacedReviewItems'), isNotNull);
  });

  test('does not duplicate generated review items when sync runs repeatedly',
      () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'khatmas': jsonEncode(
          [
            {
              'id': 'khatma-1',
              'title': 'Monthly Khatma',
              'targetDays': 30,
              'startDate': DateTime(2026, 3, 1).toIso8601String(),
              'startPage': 1,
              'furthestPageRead': 45,
              'totalReadMinutes': 12,
              'readingDayKeys': const <String>[],
            },
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

    await container.read(khatmasProvider.notifier).ready;
    final notifier = container.read(spacedReviewItemsProvider.notifier);
    await notifier.ready;

    final activeKhatma = container.read(activeKhatmaProvider);
    await notifier.syncWithActiveKhatma(activeKhatma);
    await notifier.syncWithActiveKhatma(activeKhatma);

    expect(container.read(spacedReviewItemsProvider), hasLength(2));
  });

  test(
      'does not duplicate generated review items across provider reloads and app restarts',
      () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        'khatmas': jsonEncode(
          [
            {
              'id': 'khatma-1',
              'title': 'Monthly Khatma',
              'targetDays': 30,
              'startDate': DateTime(2026, 3, 1).toIso8601String(),
              'startPage': 1,
              'furthestPageRead': 45,
              'totalReadMinutes': 12,
              'readingDayKeys': const <String>[],
            },
          ],
        ),
      },
    );

    Future<ProviderContainer> buildContainer() async {
      final container = ProviderContainer(
        overrides: [
          spacedReviewNowProvider.overrideWith(
            (ref) => () => DateTime(2026, 3, 28, 10),
          ),
        ],
      );
      await container.read(khatmasProvider.notifier).ready;
      await container.read(spacedReviewItemsProvider.notifier).ready;
      return container;
    }

    final firstContainer = await buildContainer();
    addTearDown(firstContainer.dispose);

    expect(firstContainer.read(spacedReviewItemsProvider), hasLength(2));

    firstContainer.dispose();

    UserPreferences.resetCache();

    final secondContainer = await buildContainer();
    addTearDown(secondContainer.dispose);

    expect(secondContainer.read(spacedReviewItemsProvider), hasLength(2));
  });
}
