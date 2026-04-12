import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class PersistentStateNotifier<T> extends StateNotifier<T> {
  PersistentStateNotifier(super.initialState) {
    _ready = _initialize();
  }

  late final Future<void> _ready;

  Future<void> get ready => _ready;

  Future<T> loadPersistedState();

  Future<void> persistState(T previousState, T currentState);

  T normalizeState(T state) => state;

  Future<void> _initialize() async {
    state = normalizeState(await loadPersistedState());
  }

  Future<void> replaceState(
    T nextState, {
    bool persist = true,
  }) async {
    await _ready;
    final previousState = state;
    final normalizedState = normalizeState(nextState);
    state = normalizedState;
    if (persist) {
      await persistState(previousState, normalizedState);
    }
  }

  Future<void> updateState(
    T Function(T current) transform, {
    bool persist = true,
  }) async {
    await _ready;
    final previousState = state;
    final normalizedState = normalizeState(transform(state));
    state = normalizedState;
    if (persist) {
      await persistState(previousState, normalizedState);
    }
  }

  Future<void> persistCurrentState() async {
    await _ready;
    final previousState = state;
    final normalizedState = normalizeState(state);
    state = normalizedState;
    await persistState(previousState, normalizedState);
  }
}
