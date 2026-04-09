import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/more/presentation/screens/adhkar_categories_screen.dart';
import 'package:quran_kareem/features/more/presentation/screens/adhkar_category_detail_screen.dart';
import 'package:quran_kareem/features/more/providers/adhkar_providers.dart';

void main() {
  testWidgets('renders broad adhkar groups and the local counter',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          adhkarCatalogSourceProvider.overrideWithValue(
            const _FakeAdhkarCatalogSource(_sampleCatalog),
          ),
          adhkarPreferencesLocalDataSourceProvider.overrideWithValue(
            const _FakeAdhkarPreferencesLocalDataSource(
              AdhkarCounterState(
                count: 5,
                target: 33,
              ),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Azkar'), findsOneWidget);
    expect(find.text('Digital tasbeeh'), findsOneWidget);
    expect(find.text('Daily core'), findsOneWidget);
    expect(find.text('Morning adhkar'), findsOneWidget);
    expect(find.text('Quran duas'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('shows a localized error state when the catalog fails to load',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        overrides: [
          adhkarCatalogSourceProvider.overrideWithValue(
            _ThrowingAdhkarCatalogSource(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load adhkar right now.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}

Widget _buildHarness({
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: '/more/adhkar',
        routes: [
          GoRoute(
            path: '/more/adhkar',
            builder: (context, state) => const AdhkarCategoriesScreen(),
          ),
          GoRoute(
            path: '/more/adhkar/:categoryId',
            builder: (context, state) => AdhkarCategoryDetailScreen(
              categoryId: state.pathParameters['categoryId']!,
            ),
          ),
        ],
      ),
    ),
  );
}

const AdhkarCatalog _sampleCatalog = AdhkarCatalog(
  categories: [
    AdhkarCategory(
      id: 'morning',
      groupId: 'dailyCore',
      sourceLabel: 'السنة الصحيحة',
      sourceNote: 'أذكار البداية',
      entries: [
        AdhkarEntry(
          id: 'm1',
          arabicText: 'رضيت بالله ربا',
          repetitionCount: 3,
        ),
      ],
    ),
    AdhkarCategory(
      id: 'quranDuas',
      groupId: 'sourceLed',
      sourceLabel: 'القرآن الكريم',
      sourceNote: 'أدعية قرآنية',
      entries: [
        AdhkarEntry(
          id: 'q1',
          arabicText: 'ربنا آتنا في الدنيا حسنة',
        ),
      ],
    ),
  ],
);

class _FakeAdhkarCatalogSource implements AdhkarCatalogSource {
  const _FakeAdhkarCatalogSource(this.catalog);

  final AdhkarCatalog catalog;

  @override
  Future<AdhkarCatalog> loadCatalog() async {
    return catalog;
  }
}

class _ThrowingAdhkarCatalogSource implements AdhkarCatalogSource {
  @override
  Future<AdhkarCatalog> loadCatalog() async {
    throw const FormatException('bad catalog');
  }
}

class _FakeAdhkarPreferencesLocalDataSource
    implements AdhkarPreferencesLocalDataSource {
  const _FakeAdhkarPreferencesLocalDataSource(this.state);

  final AdhkarCounterState state;

  @override
  Future<AdhkarCounterState> loadCounterState() async {
    return state;
  }

  @override
  Future<void> saveCounterState(AdhkarCounterState state) async {}
}
