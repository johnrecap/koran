import 'dart:async';

import 'package:quran_kareem/core/constants/storage_keys.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'migrations/migration_v1.dart';

typedef MigrationCallback = FutureOr<void> Function(SharedPreferences prefs);

class MigrationStep {
  const MigrationStep({
    required this.version,
    required this.description,
    required this.migrate,
  });

  final int version;
  final String description;
  final MigrationCallback migrate;
}

class DataMigrationService {
  DataMigrationService({
    Future<SharedPreferences> Function()? prefsLoader,
    List<MigrationStep>? steps,
  })  : _prefsLoader = prefsLoader ?? (() => UserPreferences.prefs),
        _steps = _normalizeSteps(steps ?? defaultMigrationSteps);

  static const String schemaVersionKey = StorageKeys.dataSchemaVersion;

  static final List<MigrationStep> defaultMigrationSteps = <MigrationStep>[
    const MigrationStep(
      version: 1,
      description: 'Initialize schema version baseline',
      migrate: migrationV1,
    ),
  ];

  final Future<SharedPreferences> Function() _prefsLoader;
  final List<MigrationStep> _steps;

  Future<void> run() async {
    final prefs = await _prefsLoader();
    final currentVersion = prefs.getInt(schemaVersionKey) ?? 0;
    var didRunMigration = false;

    for (final step in _steps) {
      if (step.version <= currentVersion) {
        continue;
      }

      didRunMigration = true;
      AppLogger.info(
        'DataMigrationService.run',
        'Running migration v${step.version}: ${step.description}',
      );
      await step.migrate(prefs);
      await prefs.setInt(schemaVersionKey, step.version);
      AppLogger.info(
        'DataMigrationService.run',
        'Completed migration v${step.version}',
      );
    }

    if (!didRunMigration) {
      AppLogger.info(
        'DataMigrationService.run',
        'No migrations required at schema version $currentVersion',
      );
    }
  }

  static List<MigrationStep> _normalizeSteps(List<MigrationStep> steps) {
    final normalized = List<MigrationStep>.from(steps)
      ..sort((left, right) => left.version.compareTo(right.version));

    for (var index = 0; index < normalized.length; index += 1) {
      final current = normalized[index];
      if (current.version < 1) {
        throw ArgumentError.value(
          current.version,
          'version',
          'Migration versions must start at 1 or higher.',
        );
      }

      if (index == 0) {
        continue;
      }

      final previous = normalized[index - 1];
      if (previous.version == current.version) {
        throw ArgumentError(
          'Duplicate migration version detected: ${current.version}',
        );
      }
    }

    return List<MigrationStep>.unmodifiable(normalized);
  }
}
