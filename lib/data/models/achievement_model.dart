class AchievementModel {
  static const int currentSchemaVersion = 1;
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final int? unlockedAt;
  final String requirementType; // 'tasks_completed', 'habit_streak', 'total_habits'
  final int requirementValue;
  final String category; // 'productivity', 'wellness', 'growth'
  final int schemaVersion;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.requirementType,
    required this.requirementValue,
    this.category = 'productivity',
    this.schemaVersion = currentSchemaVersion,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt,
      'requirementType': requirementType,
      'requirementValue': requirementValue,
      'category': category,
      'schemaVersion': schemaVersion,
    };
  }

  factory AchievementModel.fromMap(Map<String, dynamic> map, String id) {
    return AchievementModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? 'trophy',
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt: map['unlockedAt'],
      requirementType: map['requirementType'] ?? '',
      requirementValue: map['requirementValue'] ?? 0,
      category: map['category'] ?? 'productivity',
      schemaVersion: map['schemaVersion'] ?? 0,
    );
  }

  AchievementModel copyWith({
    bool? isUnlocked,
    int? unlockedAt,
    int? schemaVersion,
  }) {
    return AchievementModel(
      id: id,
      title: title,
      description: description,
      icon: icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      requirementType: requirementType,
      requirementValue: requirementValue,
      category: category,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }
}
