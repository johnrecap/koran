import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/adhkar/presentation/screens/adhkar_category_detail_screen.dart';
import 'package:quran_kareem/features/adhkar/providers/adhkar_providers.dart';

void main() {
  testWidgets('renders the Arabic entry text, repetition, and source details',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        categoryId: 'morning',
        overrides: [
          adhkarCatalogSourceProvider.overrideWithValue(
            const _FakeAdhkarCatalogSource(
              AdhkarCatalog(
                categories: [
                  AdhkarCategory(
                    id: 'morning',
                    groupId: 'dailyCore',
                    sourceLabel: 'السنة الصحيحة',
                    sourceNote: 'أذكار مأثورة',
                    entries: [
                      AdhkarEntry(
                        id: 'entry-1',
                        arabicText: 'رضيت بالله ربا',
                        repetitionCount: 3,
                        reference: 'من أذكار الصباح',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Morning adhkar'), findsOneWidget);
    expect(find.text('رضيت بالله ربا'), findsOneWidget);
    expect(find.text('Repeat: 3'), findsOneWidget);
    expect(find.text('Source'), findsOneWidget);
    expect(find.text('من أذكار الصباح'), findsOneWidget);
  });

  testWidgets(
      'renders structured virtue, authenticity, timing, and source detail',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        categoryId: 'sleep',
        overrides: [
          adhkarCatalogSourceProvider.overrideWithValue(
            _FakeAdhkarCatalogSource(
              AdhkarCatalog.fromMap(
                {
                  'categories': [
                    {
                      'id': 'sleep',
                      'groupId': 'dailyCore',
                      'sourceLabel': 'السنة الصحيحة',
                      'entries': [
                        {
                          'id': 'entry-virtue',
                          'arabicText': 'باسمك اللهم أموت وأحيا',
                          'reference': 'البخاري',
                          'virtue': 'يختم يومه بذكر الله قبل النوم.',
                          'sourceDetail': 'رواه البخاري في كتاب الدعوات.',
                          'authenticityNote': 'حديث صحيح.',
                          'timingNote': 'يقال عند وضع الجنب على الفراش.',
                        },
                      ],
                    },
                  ],
                },
              ),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('يختم يومه بذكر الله قبل النوم.'), findsOneWidget);
    expect(find.text('رواه البخاري في كتاب الدعوات.'), findsOneWidget);
    expect(find.text('حديث صحيح.'), findsOneWidget);
    expect(find.text('يقال عند وضع الجنب على الفراش.'), findsOneWidget);
  });

  testWidgets('shows a missing-category message when the id is unknown',
      (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        categoryId: 'missing',
        overrides: [
          adhkarCatalogSourceProvider.overrideWithValue(
            const _FakeAdhkarCatalogSource(
              AdhkarCatalog(categories: []),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('This adhkar category is unavailable.'),
      findsOneWidget,
    );
  });
}

Widget _buildHarness({
  required String categoryId,
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: GoRouter(
        initialLocation: '/more/adhkar/$categoryId',
        routes: [
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

class _FakeAdhkarCatalogSource implements AdhkarCatalogSource {
  const _FakeAdhkarCatalogSource(this.catalog);

  final AdhkarCatalog catalog;

  @override
  Future<AdhkarCatalog> loadCatalog() async {
    return catalog;
  }
}
