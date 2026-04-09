import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';

import '../data/mushaf_preparation_service.dart';

export '../data/mushaf_preparation_service.dart';

final mushafPreparationServiceProvider = Provider<MushafPreparationService>(
  (ref) => const QuranLibraryMushafPreparationService(),
);

final mushafPreparationControllerProvider = NotifierProvider<
    MushafPreparationController, MushafPreparationState>(
  MushafPreparationController.new,
);

enum MushafPreparationStatus {
  idle,
  preparing,
  completed,
  failed,
}

class MushafPreparationState {
  const MushafPreparationState({
    this.status = MushafPreparationStatus.idle,
    this.progress = 0.0,
    this.error,
  });

  final MushafPreparationStatus status;
  final double progress;
  final Object? error;

  bool get isPreparing => status == MushafPreparationStatus.preparing;
  bool get isCompleted => status == MushafPreparationStatus.completed;
  bool get isFailed => status == MushafPreparationStatus.failed;

  MushafPreparationState copyWith({
    MushafPreparationStatus? status,
    double? progress,
    Object? error = _errorSentinel,
  }) {
    return MushafPreparationState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: identical(error, _errorSentinel) ? this.error : error,
    );
  }
}

class MushafPreparationController extends Notifier<MushafPreparationState> {
  Future<void>? _activeTask;

  @override
  MushafPreparationState build() {
    return const MushafPreparationState();
  }

  Future<void> startIfNeeded() async {
    if (_activeTask != null) {
      await _activeTask;
      return;
    }

    if (state.isCompleted) {
      return;
    }

    final isPrepared = await UserPreferences.isMushafSetupComplete();
    if (isPrepared) {
      state = state.copyWith(
        status: MushafPreparationStatus.completed,
        progress: 1.0,
        error: null,
      );
      return;
    }

    await _runPreparation();
  }

  Future<void> retry() async {
    await _runPreparation();
  }

  Future<void> _runPreparation() async {
    if (_activeTask != null) {
      await _activeTask;
      return;
    }

    final service = ref.read(mushafPreparationServiceProvider);
    final initialProgress = state.progress.clamp(0.0, 1.0);

    final task = () async {
      state = state.copyWith(
        status: MushafPreparationStatus.preparing,
        progress: initialProgress.toDouble(),
        error: null,
      );

      try {
        await service.prepare(
          onProgress: (progress) {
            state = state.copyWith(
              status: MushafPreparationStatus.preparing,
              progress: progress.clamp(0.0, 1.0).toDouble(),
              error: null,
            );
          },
        );

        await UserPreferences.setMushafSetupComplete(true);
        state = state.copyWith(
          status: MushafPreparationStatus.completed,
          progress: 1.0,
          error: null,
        );
      } catch (error) {
        state = state.copyWith(
          status: MushafPreparationStatus.failed,
          error: error,
        );
      } finally {
        _activeTask = null;
      }
    }();

    _activeTask = task;
    await task;
  }
}

const Object _errorSentinel = Object();
