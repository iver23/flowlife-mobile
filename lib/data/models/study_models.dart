import 'dart:convert';

class SubjectArea {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;

  SubjectArea({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SubjectArea.fromMap(Map<String, dynamic> map) {
    return SubjectArea(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      color: map['color'] ?? 'duskblue',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SubjectArea.fromJson(String source) => SubjectArea.fromMap(json.decode(source));
}

class Subject {
  final String id;
  final String areaId;
  final String name;
  final DateTime createdAt;

  Subject({
    required this.id,
    required this.areaId,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'areaId': areaId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] ?? '',
      areaId: map['areaId'] ?? '',
      name: map['name'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Subject.fromJson(String source) => Subject.fromMap(json.decode(source));
}

class Lesson {
  final String id;
  final String subjectId;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  Lesson({
    required this.id,
    required this.subjectId,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  Lesson copyWith({
    String? id,
    String? subjectId,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] ?? '',
      subjectId: map['subjectId'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Lesson.fromJson(String source) => Lesson.fromMap(json.decode(source));
}
