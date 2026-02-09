enum Importance {
  low(1),
  medium(2),
  high(3),
  veryHigh(4),
  critical(5);

  final int value;
  const Importance(this.value);

  static Importance fromValue(int value) {
    return Importance.values.firstWhere((e) => e.value == value, orElse: () => Importance.low);
  }
}

enum RecurrenceType { NONE, DAILY, WEEKLY, MONTHLY }

enum UrgencyLevel {
  planning(1),
  low(2),
  moderate(3),
  urgent(4),
  critical(5);

  final int value;
  const UrgencyLevel(this.value);

  String get label => {
    UrgencyLevel.planning: 'Planning',
    UrgencyLevel.low: 'Low',
    UrgencyLevel.moderate: 'Moderate',
    UrgencyLevel.urgent: 'Urgent',
    UrgencyLevel.critical: 'Critical',
  }[this]!;

  int get colorValue => {
    UrgencyLevel.planning: 0xFF64748B, // Slate
    UrgencyLevel.low: 0xFF14B8A6,      // Teal
    UrgencyLevel.moderate: 0xFFF59E0B, // Amber
    UrgencyLevel.urgent: 0xFFF97316,   // Orange
    UrgencyLevel.critical: 0xFFE11D48, // Rose
  }[this]!;

  static UrgencyLevel fromValue(int value) {
    return UrgencyLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UrgencyLevel.planning,
    );
  }
}

class Subtask {
  final String id;
  final String title;
  final bool completed;

  Subtask({
    required this.id,
    required this.title,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
    };
  }

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      completed: map['completed'] ?? false,
    );
  }
}

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String? projectId;
  final DateTime? dueDate;
  final RecurrenceType recurrence;
  final bool completed;
  final int? completedAt;
  final UrgencyLevel urgencyLevel;
  final List<Subtask> subtasks;
  final bool isPinned;
  final int createdAt;
  final int? order;
  final bool reminderEnabled;
  final int? reminderTime; // epoch milliseconds
  final bool isDeleted;
  final int? deletedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.projectId,
    this.dueDate,
    this.recurrence = RecurrenceType.NONE,
    required this.completed,
    this.completedAt,
    this.urgencyLevel = UrgencyLevel.planning,
    required this.subtasks,
    this.isPinned = false,
    required this.createdAt,
    this.order,
    this.reminderEnabled = false,
    this.reminderTime,
    this.isDeleted = false,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectId': projectId,
      'dueDate': dueDate?.toIso8601String(),
      'recurrence': recurrence.name.toUpperCase(),
      'completed': completed,
      'completedAt': completedAt,
      'urgencyLevel': urgencyLevel.value,
      'subtasks': subtasks.map((x) => x.toMap()).toList(),
      'isPinned': isPinned,
      'createdAt': createdAt,
      'order': order,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    return TaskModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'],
      projectId: map['projectId'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      recurrence: RecurrenceType.values.firstWhere(
        (e) => e.name == (map['recurrence'] ?? 'NONE'),
        orElse: () => RecurrenceType.NONE,
      ),
      completed: map['completed'] ?? false,
      completedAt: map['completedAt'],
      urgencyLevel: map['urgencyLevel'] != null
          ? UrgencyLevel.fromValue(map['urgencyLevel'])
          : _migrateFromEnergy(map['energyLevel']),
      subtasks: (map['subtasks'] as List? ?? [])
          .map((x) => Subtask.fromMap(x as Map<String, dynamic>))
          .toList(),
      isPinned: map['isPinned'] ?? false,
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      order: map['order'],
      reminderEnabled: map['reminderEnabled'] ?? false,
      reminderTime: map['reminderTime'],
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'],
    );
  }

  TaskModel copyWith({
    String? title,
    String? description,
    String? projectId,
    DateTime? dueDate,
    RecurrenceType? recurrence,
    bool? completed,
    int? completedAt,
    UrgencyLevel? urgencyLevel,
    List<Subtask>? subtasks,
    bool? isPinned,
    int? createdAt,
    int? order,
    bool? reminderEnabled,
    int? reminderTime,
    bool? isDeleted,
    int? deletedAt,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      dueDate: dueDate ?? this.dueDate,
      recurrence: recurrence ?? this.recurrence,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      subtasks: subtasks ?? this.subtasks,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  static UrgencyLevel _migrateFromEnergy(String? energy) {
    if (energy == null) return UrgencyLevel.planning;
    switch (energy.toUpperCase()) {
      case 'HIGH':
        return UrgencyLevel.urgent;
      case 'MEDIUM':
        return UrgencyLevel.moderate;
      case 'LOW':
        return UrgencyLevel.low;
      default:
        return UrgencyLevel.planning;
    }
  }
}

class ProjectModel {
  final String id;
  final String title;
  final String color;
  final String icon;
  final Importance weight;
  final String? description;
  final bool isArchived;
  final int? lastVisitedAt;
  final bool isDeleted;
  final int? deletedAt;
  final bool isSystemProject;

  ProjectModel({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
    required this.weight,
    this.description,
    this.isArchived = false,
    this.lastVisitedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.isSystemProject = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'color': color,
      'icon': icon,
      'weight': weight.value,
      'description': description,
      'isArchived': isArchived,
      'lastVisitedAt': lastVisitedAt,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
      'isSystemProject': isSystemProject,
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProjectModel(
      id: docId,
      title: map['title'] ?? '',
      color: map['color'] ?? 'blue',
      icon: map['icon'] ?? 'work',
      weight: Importance.fromValue(map['weight'] ?? 1),
      description: map['description'],
      isArchived: map['isArchived'] ?? false,
      lastVisitedAt: map['lastVisitedAt'],
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'],
      isSystemProject: map['isSystemProject'] ?? false,
    );
  }

  ProjectModel copyWith({
    String? title,
    String? color,
    String? icon,
    Importance? weight,
    String? description,
    bool? isArchived,
    int? lastVisitedAt,
    bool? isDeleted,
    int? deletedAt,
    bool? isSystemProject,
  }) {
    return ProjectModel(
      id: id,
      title: title ?? this.title,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      weight: weight ?? this.weight,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      isSystemProject: isSystemProject ?? this.isSystemProject,
    );
  }
}

class IdeaModel {
  final String id;
  final String content;
  final String? projectId;
  final int createdAt;
  final bool isDeleted;
  final int? deletedAt;

  IdeaModel({
    required this.id,
    required this.content,
    this.projectId,
    required this.createdAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'projectId': projectId,
      'createdAt': createdAt,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
    };
  }

  factory IdeaModel.fromMap(Map<String, dynamic> map, String docId) {
    return IdeaModel(
      id: docId,
      content: map['content'] ?? '',
      projectId: map['projectId'],
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'],
    );
  }

  IdeaModel copyWith({
    String? content,
    String? projectId,
    int? createdAt,
    bool? isDeleted,
    int? deletedAt,
  }) {
    return IdeaModel(
      id: id,
      content: content ?? this.content,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
