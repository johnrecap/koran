import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/more/providers/adhkar_providers.dart';

void main() {
  test('groups adhkar categories in stable section and category order',
      () async {
    final container = ProviderContainer(
      overrides: [
        adhkarCatalogSourceProvider.overrideWithValue(
          const _FakeAdhkarCatalogSource(
            AdhkarCatalog(
              categories: [
                AdhkarCategory(
                  id: 'quranDuas',
                  groupId: 'sourceLed',
                  sourceLabel: 'القرآن',
                  entries: [],
                ),
                AdhkarCategory(
                  id: 'afterPrayer',
                  groupId: 'dailyCore',
                  sourceLabel: 'السنة',
                  entries: [],
                ),
                AdhkarCategory(
                  id: 'morning',
                  groupId: 'dailyCore',
                  sourceLabel: 'السنة',
                  entries: [],
                ),
                AdhkarCategory(
                  id: 'rizq',
                  groupId: 'lifeNeeds',
                  sourceLabel: 'القرآن والسنة',
                  entries: [],
                ),
              ],
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final sections =
        await container.read(adhkarCategorySectionsProvider.future);

    expect(sections.map((section) => section.id), [
      'dailyCore',
      'lifeNeeds',
      'sourceLed',
    ]);
    expect(sections.first.categories.map((category) => category.id), [
      'morning',
      'afterPrayer',
    ]);
  });

  test('persists counter mutations through the notifier', () async {
    final source = _FakeAdhkarPreferencesLocalDataSource(
      const AdhkarCounterState(
        count: 2,
        target: 33,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        adhkarPreferencesLocalDataSourceProvider.overrideWithValue(source),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(adhkarCounterProvider.notifier);
    await notifier.ready;
    await notifier.increment();
    await notifier.setTarget(100);
    await notifier.reset();

    expect(container.read(adhkarCounterProvider).count, 0);
    expect(container.read(adhkarCounterProvider).target, 100);
    expect(source.savedStates, isNotEmpty);
    expect(source.savedStates.last.target, 100);
  });
}

class _FakeAdhkarCatalogSource implements AdhkarCatalogSource {
  const _FakeAdhkarCatalogSource(this.catalog);

  final AdhkarCatalog catalog;

  @override
  Future<AdhkarCatalog> loadCatalog() async {
    return catalog;
  }
}

class _FakeAdhkarPreferencesLocalDataSource
    implements AdhkarPreferencesLocalDataSource {
  _FakeAdhkarPreferencesLocalDataSource(this.initialState);

  final AdhkarCounterState initialState;
  final List<AdhkarCounterState> savedStates = <AdhkarCounterState>[];

  @override
  Future<AdhkarCounterState> loadCounterState() async {
    return initialState;
  }

  @override
  Future<void> saveCounterState(AdhkarCounterState state) async {
    savedStates.add(state);
  }
}
