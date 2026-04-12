import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/services/data_migration_service.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserPreferences.resetCache();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  tearDown(UserPreferences.resetCache);

  group('DataMigrationService', () {
    test('runs fresh-install migrations and stores the migrated version',
        () async {
      var callCount = 0;
      final service = DataMigrationService(
        prefsLoader: SharedPreferences.getInstance,
        steps: <MigrationStep>[
          MigrationStep(
            version: 1,
            description: 'baseline',
            migrate: (prefs) async {
              callCount += 1;
              await prefs.setString('migration_marker', 'v1');
            },
          ),
        ],
      );

      await service.run();

      final prefs = await SharedPreferences.getInstance();
      expect(callCount, 1);
      expect(
        prefs.getInt(DataMigrationService.schemaVersionKey),
        1,
      );
      expect(prefs.getString('migration_marker'), 'v1');
    });

    test('skips migrations already recorded in schema version state', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        DataMigrationService.schemaVersionKey: 1,
        'migration_marker': 'existing',
      });
      UserPreferences.resetCache();

      var callCount = 0;
      final service = DataMigrationService(
        prefsLoader: SharedPreferences.getInstance,
        steps: <MigrationStep>[
          MigrationStep(
            version: 1,
            description: 'baseline',
            migrate: (prefs) async {
              callCount += 1;
              await prefs.setString('migration_marker', 'unexpected');
            },
          ),
        ],
      );

      await service.run();

      final prefs = await SharedPreferences.getInstance();
      expect(callCount, 0);
      expect(
        prefs.getInt(DataMigrationService.schemaVersionKey),
        1,
      );
      expect(prefs.getString('migration_marker'), 'existing');
    });
  });
}
