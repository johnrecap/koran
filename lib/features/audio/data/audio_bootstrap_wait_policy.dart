import 'dart:async';

class AudioBootstrapWaitPolicy {
  const AudioBootstrapWaitPolicy({
    this.timeout = const Duration(seconds: 15),
    this.pollInterval = const Duration(milliseconds: 50),
  });

  final Duration timeout;
  final Duration pollInterval;

  Future<void> waitUntilReady(bool Function() isReady) async {
    if (isReady()) {
      return;
    }

    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      final remaining = timeout - stopwatch.elapsed;
      final delay = remaining < pollInterval ? remaining : pollInterval;
      await Future<void>.delayed(delay);

      if (isReady()) {
        return;
      }
    }

    throw TimeoutException(
      'Audio controller did not finish bootstrapping within '
      '${timeout.inMilliseconds}ms.',
      timeout,
    );
  }
}
