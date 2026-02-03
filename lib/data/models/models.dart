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

enum EnergyLevel { HIGH, MEDIUM, LOW }

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
  final EnergyLevel? energyLevel;
  final List<Subtask> subtasks;
  final List<String> customTags;
  final bool isPinned;
  final int createdAt;
  final int? order;
  final bool reminderEnabled;
  final int? reminderTime; // epoch milliseconds

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.projectId,
    this.dueDate,
    this.recurrence = RecurrenceType.NONE,
    required this.completed,
    this.completedAt,
    this.energyLevel,
    required this.subtasks,
    this.customTags = const [],
    this.isPinned = false,
    required this.createdAt,
    this.order,
    this.reminderEnabled = false,
    this.reminderTime,
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
      'energyLevel': energyLevel?.name.toUpperCase(),
      'subtasks': subtasks.map((x) => x.toMap()).toList(),
      'customTags': customTags,
      'isPinned': isPinned,
      'createdAt': createdAt,
      'order': order,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
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
      energyLevel: map['energyLevel'] != null
          ? EnergyLevel.values.firstWhere(
              (e) => e.name == map['energyLevel'],
              orElse: () => EnergyLevel.MEDIUM,
            )
          : null,
      subtasks: (map['subtasks'] as List? ?? [])
          .map((x) => Subtask.fromMap(x as Map<String, dynamic>))
          .toList(),
      customTags: List<String>.from(map['customTags'] ?? []),
      isPinned: map['isPinned'] ?? false,
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      order: map['order'],
      reminderEnabled: map['reminderEnabled'] ?? false,
      reminderTime: map['reminderTime'],
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
    EnergyLevel? energyLevel,
    List<Subtask>? subtasks,
    List<String>? customTags,
    bool? isPinned,
    int? createdAt,
    int? order,
    bool? reminderEnabled,
    int? reminderTime,
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
      energyLevel: energyLevel ?? this.energyLevel,
      subtasks: subtasks ?? this.subtasks,
      customTags: customTags ?? this.customTags,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
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

  ProjectModel({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
    required this.weight,
    this.description,
    this.isArchived = false,
    this.lastVisitedAt,
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
    );
  }
}

class IdeaModel {
  final String id;
  final String content;
  final List<String> customTags;
  final String? projectId;
  final int createdAt;

  IdeaModel({
    required this.id,
    required this.content,
    this.customTags = const [],
    this.projectId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'customTags': customTags,
      'projectId': projectId,
      'createdAt': createdAt,
    };
  }

  factory IdeaModel.fromMap(Map<String, dynamic> map, String docId) {
    return IdeaModel(
      id: docId,
      content: map['content'] ?? '',
      customTags: List<String>.from(map['customTags'] ?? []),
      projectId: map['projectId'],
      createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  IdeaModel copyWith({
    String? content,
    List<String>? customTags,
    String? projectId,
    int? createdAt,
  }) {
    return IdeaModel(
      id: id,
      content: content ?? this.content,
      customTags: customTags ?? this.customTags,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
