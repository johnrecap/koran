import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/notifications/domain/notification_launch_target.dart';
import 'package:quran_kareem/features/notifications/domain/notification_payload_codec.dart';

void main() {
  test('encodes and decodes launch targets round-trip', () {
    const target = NotificationLaunchTarget.reviewQueue();

    final payload = NotificationPayloadCodec.encode(target);
    final decoded = NotificationPayloadCodec.decodeOrFallback(payload);

    expect(decoded, target);
  });

  test('falls back to the safe library target when payload is malformed', () {
    final decoded = NotificationPayloadCodec.decodeOrFallback('not-json');

    expect(decoded, const NotificationLaunchTarget.library());
  });
}
