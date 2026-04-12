import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/providers/persistent_state_notifier.dart';

void main() {
  group('PersistentStateNotifier', () {
    test('loads persisted state once during bootstrap', () async {
      final loadCompleter = Completer<List<String>>();
      var loadCalls = 0;

      final notifier = _TestPersistentNotifier(
        loadState: () {
          loadCalls += 1;
          return loadCompleter.future;
        },
        persist: (_, __) async {},
      );

      expect(notifier.state, isEmpty);
      expect(loadCalls, 1);

      loadCompleter.complete(<String>['existing']);
      await notifier.ready;
      await notifier.ready;

      expect(notifier.state, <String>['existing']);
      expect(loadCalls, 1);
    });

    test('waits for ready before mutating and persists normalized state',
        () async {
      final loadCompleter = Completer<List<String>>();
      final persistedStates = <List<String>>[];

      final notifier = _TestPersistentNotifier(
        loadState: () => loadCompleter.future,
        persist: (_, currentState) async {
          persistedStates.add(List<String>.from(currentState));
        },
      );

      final pendingMutation = notifier.prepend(' fresh ');

      expect(notifier.state, isEmpty);

      loadCompleter.complete(<String>['existing']);
      await pendingMutation;

      expect(notifier.state, <String>['fresh', 'existing']);
      expect(
        persistedStates,
        <List<String>>[
          <String>['fresh', 'existing'],
        ],
      );
    });

    test('normalizes loaded state before exposing it', () async {
      final notifier = _TestPersistentNotifier(
        loadState: () async => <String>['  first  ', '', 'second  '],
        persist: (_, __) async {},
      );

      await notifier.ready;

      expect(notifier.state, <String>['first', 'second']);
    });
  });
}

class _TestPersistentNotifier extends PersistentStateNotifier<List<String>> {
  _TestPersistentNotifier({
    required Future<List<String>> Function() loadState,
    required Future<void> Function(
      List<String> previousState,
      List<String> currentState,
    ) persist,
  })  : _loadState = loadState,
        _persist = persist,
        super(const <String>[]);

  final Future<List<String>> Function() _loadState;
  final Future<void> Function(
    List<String> previousState,
    List<String> currentState,
  ) _persist;

  @override
  Future<List<String>> loadPersistedState() => _loadState();

  @override
  List<String> normalizeState(List<String> state) {
    return state
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<void> persistState(
    List<String> previousState,
    List<String> currentState,
  ) {
    return _persist(previousState, currentState);
  }

  Future<void> prepend(String value) {
    return updateState((current) => <String>[value, ...current]);
  }
}
