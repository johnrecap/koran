import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_option.dart';
import 'package:quran_kareem/features/audio/domain/audio_hub_reciter_policy.dart';

void main() {
  test('resolves the persisted reciter when its id matches an available option',
      () {
    const options = <AudioHubReciterOption>[
      AudioHubReciterOption(index: 0, id: 'reader-a', name: 'Reader A'),
      AudioHubReciterOption(index: 1, id: 'reader-b', name: 'Reader B'),
    ];

    final resolvedIndex = AudioHubReciterPolicy.resolveReaderIndex(
      options: options,
      persistedReciterId: 'reader-b',
      fallbackIndex: 0,
    );

    expect(resolvedIndex, 1);
  });

  test('falls back to the package index when the persisted reciter is missing',
      () {
    const options = <AudioHubReciterOption>[
      AudioHubReciterOption(index: 0, id: 'reader-a', name: 'Reader A'),
      AudioHubReciterOption(index: 1, id: 'reader-b', name: 'Reader B'),
    ];

    final resolvedIndex = AudioHubReciterPolicy.resolveReaderIndex(
      options: options,
      persistedReciterId: 'reader-z',
      fallbackIndex: 1,
    );

    expect(resolvedIndex, 1);
  });
}
