
class SchemaMigrationService {
  /// Migrates a document map if its schemaVersion is outdated.
  /// Returns the migrated map.
  Map<String, dynamic> migrateDocument(String collectionPath, Map<String, dynamic> data) {
    final int version = data['schemaVersion'] ?? 0;
    
    return switch (collectionPath) {
      'tasks' => _migrateTask(data, version),
      'projects' => _migrateProject(data, version),
      'habits' ||
      'ideas' ||
      'achievements' ||
      'dashboard_widgets' ||
      'subject_areas' ||
      'subjects' ||
      'lessons' =>
        _migrateGeneric(data, version),
      _ => data,
    };
  }

  Map<String, dynamic> _migrateTask(Map<String, dynamic> data, int version) {
    var migratedData = Map<String, dynamic>.from(data);
    
    if (version < 1) {
      // Logic for migration from version 0 to 1
      // e.g., mapping old fields to new ones
      if (data.containsKey('energyLevel') && !data.containsKey('urgencyLevel')) {
        // This is actually handled in the TaskModel.fromMap constructor for now
      }
      migratedData['schemaVersion'] = 1;
    }
    
    return migratedData;
  }

  Map<String, dynamic> _migrateProject(Map<String, dynamic> data, int version) {
    var migratedData = Map<String, dynamic>.from(data);
    
    if (version < 1) {
      migratedData['schemaVersion'] = 1;
    }
    
    return migratedData;
  }

  Map<String, dynamic> _migrateGeneric(Map<String, dynamic> data, int version) {
    var migratedData = Map<String, dynamic>.from(data);
    
    if (version < 1) {
      migratedData['schemaVersion'] = 1;
    }
    
    return migratedData;
  }
}
