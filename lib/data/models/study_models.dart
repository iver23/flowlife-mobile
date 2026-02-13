import 'dart:convert';

class SubjectArea {
  static const int currentSchemaVersion = 1;
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;
  final bool isArchived;
  final bool isDeleted;
  final int? deletedAt;
  final int schemaVersion;

  SubjectArea({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    this.isArchived = false,
    this.isDeleted = false,
    this.deletedAt,
    this.schemaVersion = currentSchemaVersion,
  });

  SubjectArea copyWith({
    String? name,
    String? color,
    bool? isArchived,
    bool? isDeleted,
    int? deletedAt,
    int? schemaVersion,
  }) {
    return SubjectArea(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
      'schemaVersion': schemaVersion,
    };
  }

  factory SubjectArea.fromMap(Map<String, dynamic> map, String docId) {
    return SubjectArea(
      id: docId,
      name: map['name'] ?? '',
      color: map['color'] ?? 'duskblue',
      createdAt: DateTime.parse(map['createdAt']),
      isArchived: map['isArchived'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'],
      schemaVersion: map['schemaVersion'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory SubjectArea.fromJson(String source) {
    final map = json.decode(source) as Map<String, dynamic>;
    return SubjectArea.fromMap(map, map['id'] ?? '');
  }
}

class Subject {
  static const int currentSchemaVersion = 1;
  final String id;
  final String areaId;
  final String name;
  final DateTime createdAt;
  final bool isDeleted;
  final int? deletedAt;
  final int schemaVersion;

  Subject({
    required this.id,
    required this.areaId,
    required this.name,
    required this.createdAt,
    this.isDeleted = false,
    this.deletedAt,
    this.schemaVersion = currentSchemaVersion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'areaId': areaId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
      'schemaVersion': schemaVersion,
    };
  }

  Subject copyWith({
    String? areaId,
    String? name,
    bool? isDeleted,
    int? deletedAt,
    int? schemaVersion,
  }) {
    return Subject(
      id: id,
      areaId: areaId ?? this.areaId,
      name: name ?? this.name,
      createdAt: createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  factory Subject.fromMap(Map<String, dynamic> map, String docId) {
    return Subject(
      id: docId,
      areaId: map['areaId'] ?? '',
      name: map['name'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'],
      schemaVersion: map['schemaVersion'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Subject.fromJson(String source) {
    final map = json.decode(source) as Map<String, dynamic>;
    return Subject.fromMap(map, map['id'] ?? '');
  }
}

class Lesson {
  static const int currentSchemaVersion = 1;
  final String id;
  final String subjectId;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final bool isDeleted;
  final int? deletedAt;
  final int schemaVersion;

  Lesson({
    required this.id,
    required this.subjectId,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.isDeleted = false,
    this.deletedAt,
    this.schemaVersion = currentSchemaVersion,
  });

  Lesson copyWith({
    String? id,
    String? subjectId,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    bool? isDeleted,
    int? deletedAt,
    int? schemaVersion,
  }) {
    return Lesson(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
      'schemaVersion': schemaVersion,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map, String docId) {
    return Lesson(
      id: docId,
      subjectId: map['subjectId'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'],
      schemaVersion: map['schemaVersion'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Lesson.fromJson(String source) {
    final map = json.decode(source) as Map<String, dynamic>;
    return Lesson.fromMap(map, map['id'] ?? '');
  }
}
