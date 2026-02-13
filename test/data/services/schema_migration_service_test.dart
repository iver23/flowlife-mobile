import 'package:flutter_test/flutter_test.dart';
import 'package:flowlife_mobile/data/services/schema_migration_service.dart';

void main() {
  late SchemaMigrationService migrationService;

  setUp(() {
    migrationService = SchemaMigrationService();
  });

  group('SchemaMigrationService - Tasks', () {
    test('should migrate legacy task (v0) to v1', () {
      final legacyData = {
        'title': 'Legacy Task',
        'energyLevel': 'high', // Old field
      };

      final migratedData = migrationService.migrateDocument('tasks', legacyData);

      expect(migratedData['schemaVersion'], 1);
      expect(migratedData['title'], 'Legacy Task');
    });

    test('should pass through v1 task unchanged', () {
      final currentData = {
        'title': 'New Task',
        'schemaVersion': 1,
      };

      final migratedData = migrationService.migrateDocument('tasks', currentData);

      expect(migratedData['schemaVersion'], 1);
      expect(migratedData['title'], 'New Task');
    });
  });

  group('SchemaMigrationService - Projects', () {
    test('should migrate legacy project to v1', () {
      final legacyData = {
        'title': 'Legacy Project',
      };

      final migratedData = migrationService.migrateDocument('projects', legacyData);

      expect(migratedData['schemaVersion'], 1);
    });
  });

  group('SchemaMigrationService - Generic Handler', () {
    test('should migrate habits to v1', () {
      final legacyData = {'title': 'Legacy Habit'};
      final migratedData = migrationService.migrateDocument('habits', legacyData);
      expect(migratedData['schemaVersion'], 1);
    });

    test('should migrate achievements to v1', () {
      final legacyData = {'title': 'Legacy Achievement'};
      final migratedData = migrationService.migrateDocument('achievements', legacyData);
      expect(migratedData['schemaVersion'], 1);
    });

    test('should migrate dashboard_widgets to v1', () {
      final legacyData = {'type': 'habits'};
      final migratedData = migrationService.migrateDocument('dashboard_widgets', legacyData);
      expect(migratedData['schemaVersion'], 1);
    });

    test('should migrate subject_areas to v1', () {
      final legacyData = {'title': 'Math'};
      final migratedData = migrationService.migrateDocument('subject_areas', legacyData);
      expect(migratedData['schemaVersion'], 1);
    });
  });

  group('SchemaMigrationService - Edge Cases', () {
    test('should handle unknown collections by passing data through', () {
      final data = {'foo': 'bar'};
      final migratedData = migrationService.migrateDocument('unknown', data);
      expect(migratedData, equals(data));
      expect(migratedData['schemaVersion'], isNull);
    });

    test('should handle already migrated data (idempotency)', () {
      final data = {'title': 'Task', 'schemaVersion': 1};
      final migratedData = migrationService.migrateDocument('tasks', data);
      expect(migratedData['schemaVersion'], 1);
      expect(migratedData, equals(data));
    });

    test('should handle empty maps', () {
      final data = <String, dynamic>{};
      final migratedData = migrationService.migrateDocument('tasks', data);
      expect(migratedData['schemaVersion'], 1);
    });
  });
}
