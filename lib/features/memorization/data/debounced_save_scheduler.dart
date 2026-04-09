import 'dart:async';

class DebouncedSaveScheduler {
  DebouncedSaveScheduler({
    this.debounce = const Duration(milliseconds: 500),
  });

  final Duration debounce;

  Timer? _cooldownTimer;
  Future<void> _activeSave = Future<void>.value();
  Completer<void>? _queuedSaveCompleter;
  Future<void> Function()? _queuedAction;

  Future<void> schedule(Future<void> Function() action) {
    if (_cooldownTimer == null || !_cooldownTimer!.isActive) {
      final saveFuture = _runSerialized(action);
      _cooldownTimer = Timer(debounce, _flushQueuedAction);
      return saveFuture;
    }

    _queuedAction = action;
    _queuedSaveCompleter ??= Completer<void>();
    return _queuedSaveCompleter!.future;
  }

  void dispose() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
  }

  Future<void> _runSerialized(Future<void> Function() action) {
    final nextSave = _activeSave.then<void>(
      (_) => action(),
      onError: (_, __) => action(),
    );
    _activeSave = nextSave.catchError((Object _, StackTrace __) {});
    return nextSave;
  }

  void _flushQueuedAction() {
    final action = _queuedAction;
    final completer = _queuedSaveCompleter;
    _queuedAction = null;
    _queuedSaveCompleter = null;

    if (action == null) {
      _cooldownTimer = null;
      return;
    }

    final saveFuture = _runSerialized(action);
    _cooldownTimer = Timer(debounce, _flushQueuedAction);

    if (completer == null || completer.isCompleted) {
      return;
    }

    saveFuture.then<void>(
      (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );
  }
}
