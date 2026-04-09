import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/audio/data/audio_bootstrap_wait_policy.dart';

void main() {
  test('returns immediately when package audio is already ready', () async {
    var checks = 0;
    const policy = AudioBootstrapWaitPolicy(
      timeout: Duration(milliseconds: 40),
      pollInterval: Duration(milliseconds: 5),
    );

    await policy.waitUntilReady(() {
      checks += 1;
      return true;
    });

    expect(checks, 1);
  });

  test('completes when package audio becomes ready before timeout', () async {
    var checks = 0;
    const policy = AudioBootstrapWaitPolicy(
      timeout: Duration(milliseconds: 80),
      pollInterval: Duration(milliseconds: 10),
    );

    await policy.waitUntilReady(() {
      checks += 1;
      return checks >= 3;
    });

    expect(checks, 3);
  });

  test('throws TimeoutException when package audio never becomes ready',
      () async {
    const policy = AudioBootstrapWaitPolicy(
      timeout: Duration(milliseconds: 30),
      pollInterval: Duration(milliseconds: 10),
    );

    await expectLater(
      policy.waitUntilReady(() => false),
      throwsA(
        isA<TimeoutException>().having(
          (error) => error.duration,
          'duration',
          const Duration(milliseconds: 30),
        ),
      ),
    );
  });
}
