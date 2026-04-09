import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/features/more/data/adhkar_local_data_source.dart';
import 'package:quran_kareem/features/more/data/adhkar_preferences_local_data_source.dart';
import 'package:quran_kareem/features/more/domain/adhkar_counter_state.dart';
import 'package:quran_kareem/features/more/domain/adhkar_models.dart';
import 'package:quran_kareem/features/more/domain/adhkar_policies.dart';

export 'package:quran_kareem/features/more/data/adhkar_local_data_source.dart'
    show AdhkarCatalogSource, AssetAdhkarCatalogSource;
export 'package:quran_kareem/features/more/data/adhkar_preferences_local_data_source.dart'
    show
        AdhkarPreferencesLocalDataSource,
        SharedPreferencesAdhkarPreferencesLocalDataSource;
export 'package:quran_kareem/features/more/domain/adhkar_counter_state.dart';
export 'package:quran_kareem/features/more/domain/adhkar_models.dart';
export 'package:quran_kareem/features/more/domain/adhkar_policies.dart';

final adhkarCatalogSourceProvider = Provider<AdhkarCatalogSource>((ref) {
  return AssetAdhkarCatalogSource();
});

final adhkarPreferencesLocalDataSourceProvider =
    Provider<AdhkarPreferencesLocalDataSource>((ref) {
  return SharedPreferencesAdhkarPreferencesLocalDataSource();
});

final adhkarCatalogProvider = FutureProvider<AdhkarCatalog>((ref) async {
  final source = ref.watch(adhkarCatalogSourceProvider);
  return source.loadCatalog();
});

final adhkarCategorySectionsProvider =
    FutureProvider<List<AdhkarCategorySection>>((ref) async {
  final catalog = await ref.watch(adhkarCatalogProvider.future);
  return AdhkarPolicies.buildSections(catalog.categories);
});

final adhkarCategoryProvider =
    FutureProvider.family<AdhkarCategory?, String>((ref, categoryId) async {
  final catalog = await ref.watch(adhkarCatalogProvider.future);
  return catalog.categoryById(categoryId);
});

final adhkarCounterProvider =
    StateNotifierProvider<AdhkarCounterNotifier, AdhkarCounterState>((ref) {
  return AdhkarCounterNotifier(
    localDataSource: ref.watch(adhkarPreferencesLocalDataSourceProvider),
  );
});

class AdhkarCounterNotifier extends StateNotifier<AdhkarCounterState> {
  AdhkarCounterNotifier({
    required AdhkarPreferencesLocalDataSource localDataSource,
  })  : _localDataSource = localDataSource,
        super(const AdhkarCounterState()) {
    _ready = _load();
  }

  final AdhkarPreferencesLocalDataSource _localDataSource;
  late final Future<void> _ready;

  Future<void> get ready => _ready;

  Future<void> _load() async {
    state = await _localDataSource.loadCounterState();
  }

  Future<void> increment() async {
    await _ready;
    state = state.copyWith(count: state.count + 1);
    await _save();
  }

  Future<void> reset() async {
    await _ready;
    state = state.copyWith(count: 0);
    await _save();
  }

  Future<void> setTarget(int? target) async {
    await _ready;
    state = target == null
        ? state.copyWith(clearTarget: true)
        : state.copyWith(target: target);
    await _save();
  }

  Future<void> _save() async {
    await _localDataSource.saveCounterState(state);
  }
}
