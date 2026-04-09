import 'dart:async';

import 'package:flutter/widgets.dart';

typedef ReaderExitDeferredExecutor = void Function(VoidCallback callback);

abstract final class ReaderExitCleanupPolicy {
  static void schedule({
    required ReaderExitDeferredExecutor defer,
    required Future<void> Function() recordTrackedDuration,
    required VoidCallback applySystemUiReset,
    required VoidCallback resetSessionIntent,
    required VoidCallback resetFullscreen,
    required VoidCallback resetNightSessionOverride,
  }) {
    defer(() {
      unawaited(recordTrackedDuration());
      applySystemUiReset();
      resetSessionIntent();
      resetFullscreen();
      resetNightSessionOverride();
    });
  }
}
