import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_playback_mode.dart';

void main() {
  test('parses playback modes from names with a safe fallback', () {
    expect(
      AdhanPlaybackMode.fromName('notificationOnly'),
      AdhanPlaybackMode.notificationOnly,
    );
    expect(
      AdhanPlaybackMode.fromName('fullAdhan'),
      AdhanPlaybackMode.fullAdhan,
    );
    expect(
      AdhanPlaybackMode.fromName('takbeerOnly'),
      AdhanPlaybackMode.takbeerOnly,
    );
    expect(
      AdhanPlaybackMode.fromName('missing'),
      AdhanPlaybackMode.notificationOnly,
    );
    expect(
      AdhanPlaybackMode.fromName(null),
      AdhanPlaybackMode.notificationOnly,
    );
  });
}
