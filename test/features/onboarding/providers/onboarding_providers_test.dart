import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/onboarding/providers/onboarding_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    UserPreferences.resetCache();
  });

  test('marks mushaf setup complete after successful background preparation',
      () async {
    final service = _FakeMushafPreparationService(
      outcomes: Queue<_PreparationOutcome>.of([
        _PreparationOutcome.success([0.2, 0.6, 1.0]),
      ]),
    );
    final container = ProviderContainer(
      overrides: [
        mushafPreparationServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(mushafPreparationControllerProvider).status,
      MushafPreparationStatus.idle,
    );

    await container
        .read(mushafPreparationControllerProvider.notifier)
        .startIfNeeded();

    final state = container.read(mushafPreparationControllerProvider);
    expect(state.status, MushafPreparationStatus.completed);
    expect(state.progress, 1.0);
    expect(await UserPreferences.isMushafSetupComplete(), isTrue);
    expect(service.prepareCalls, 1);
  });

  test('does not rerun the preparation service when setup already completed',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'mushafSetupComplete': true,
    });

    final service = _FakeMushafPreparationService(
      outcomes: Queue<_PreparationOutcome>.of([
        _PreparationOutcome.success([1.0]),
      ]),
    );
    final container = ProviderContainer(
      overrides: [
        mushafPreparationServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(mushafPreparationControllerProvider.notifier)
        .startIfNeeded();

    final state = container.read(mushafPreparationControllerProvider);
    expect(state.status, MushafPreparationStatus.completed);
    expect(state.progress, 1.0);
    expect(service.prepareCalls, 0);
  });

  test('supports retry after a failed preparation attempt', () async {
    final service = _FakeMushafPreparationService(
      outcomes: Queue<_PreparationOutcome>.of([
        _PreparationOutcome.failure([0.3], StateError('network failure')),
        _PreparationOutcome.success([0.4, 1.0]),
      ]),
    );
    final container = ProviderContainer(
      overrides: [
        mushafPreparationServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(mushafPreparationControllerProvider.notifier)
        .startIfNeeded();

    var state = container.read(mushafPreparationControllerProvider);
    expect(state.status, MushafPreparationStatus.failed);
    expect(state.progress, 0.3);
    expect(await UserPreferences.isMushafSetupComplete(), isFalse);

    await container.read(mushafPreparationControllerProvider.notifier).retry();

    state = container.read(mushafPreparationControllerProvider);
    expect(state.status, MushafPreparationStatus.completed);
    expect(state.progress, 1.0);
    expect(service.prepareCalls, 2);
    expect(await UserPreferences.isMushafSetupComplete(), isTrue);
  });
}

class _FakeMushafPreparationService implements MushafPreparationService {
  _FakeMushafPreparationService({
    required this.outcomes,
  });

  final Queue<_PreparationOutcome> outcomes;
  int prepareCalls = 0;

  @override
  Future<void> prepare({
    required void Function(double progress) onProgress,
  }) async {
    prepareCalls += 1;
    final outcome = outcomes.removeFirst();
    for (final progress in outcome.progressMarks) {
      onProgress(progress);
      await Future<void>.delayed(Duration.zero);
    }

    if (outcome.error != null) {
      throw outcome.error!;
    }
  }
}

class _PreparationOutcome {
  const _PreparationOutcome._({
    required this.progressMarks,
    this.error,
  });

  final List<double> progressMarks;
  final Object? error;

  factory _PreparationOutcome.success(List<double> progressMarks) {
    return _PreparationOutcome._(progressMarks: progressMarks);
  }

  factory _PreparationOutcome.failure(List<double> progressMarks, Object error) {
    return _PreparationOutcome._(
      progressMarks: progressMarks,
      error: error,
    );
  }
}
