import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/domain/reader_exit_cleanup_policy.dart';

void main() {
  test('defers reader exit cleanup until the deferred callback runs', () async {
    final executed = <String>[];
    VoidCallback? deferred;

    ReaderExitCleanupPolicy.schedule(
      defer: (callback) {
        deferred = callback;
      },
      recordTrackedDuration: () async {
        executed.add('record-duration');
      },
      applySystemUiReset: () {
        executed.add('system-ui');
      },
      resetSessionIntent: () {
        executed.add('session-intent');
      },
      resetFullscreen: () {
        executed.add('fullscreen');
      },
      resetNightSessionOverride: () {
        executed.add('night-override');
      },
    );

    expect(executed, isEmpty);
    expect(deferred, isNotNull);

    deferred!.call();
    await Future<void>.delayed(Duration.zero);

    expect(
      executed,
      containsAllInOrder(
        [
          'record-duration',
          'system-ui',
          'session-intent',
          'fullscreen',
          'night-override',
        ],
      ),
    );
  });
}
