/// Model for tracking habits with streak functionality.
class HabitModel {
  final String id;
  final String title;
  final String category; // 'health', 'productivity', 'learning', 'wellness'
  final List<int> completedDates; // epoch days (days since epoch, not milliseconds)
  final int createdAt;
  final String? icon;

  HabitModel({
    required this.id,
    required this.title,
    this.category = 'productivity',
    this.completedDates = const [],
    required this.createdAt,
    this.icon,
  });

  /// Calculate the current streak (consecutive days ending today or yesterday)
  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    
    final sortedDates = List<int>.from(completedDates)..sort((a, b) => b.compareTo(a));
    final today = DateTime.now();
    final todayEpochDay = today.difference(DateTime(1970, 1, 1)).inDays;
    
    // Streak must end today or yesterday to be "current"
    if (sortedDates.first < todayEpochDay - 1) return 0;
    
    int streak = 1;
    for (int i = 0; i < sortedDates.length - 1; i++) {
      if (sortedDates[i] - sortedDates[i + 1] == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Check if habit was completed today
  bool get isCompletedToday {
    final todayEpochDay = DateTime.now().difference(DateTime(1970, 1, 1)).inDays;
    return completedDates.contains(todayEpochDay);
  }

  /// Calculate weekly completion rate (last 7 days)
  double get weeklyCompletionRate {
    final today = DateTime.now();
    final todayEpochDay = today.difference(DateTime(1970, 1, 1)).inDays;
    int count = 0;
    for (int i = 0; i < 7; i++) {
      if (completedDates.contains(todayEpochDay - i)) count++;
    }
    return count / 7.0;
  }

  /// Calculate monthly completion rate (last 30 days)
  double get monthlyCompletionRate {
    final today = DateTime.now();
    final todayEpochDay = today.difference(DateTime(1970, 1, 1)).inDays;
    int count = 0;
    for (int i = 0; i < 30; i++) {
      if (completedDates.contains(todayEpochDay - i)) count++;
    }
    return count / 30.0;
  }

  HabitModel copyWith({
    String? id,
    String? title,
    String? category,
    List<int>? completedDates,
    int? createdAt,
    String? icon,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'completedDates': completedDates,
      'createdAt': createdAt,
      'icon': icon,
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map, String id) {
    return HabitModel(
      id: id,
      title: map['title'] ?? '',
      category: map['category'] ?? 'productivity',
      completedDates: List<int>.from(map['completedDates'] ?? []),
      createdAt: map['createdAt'] ?? 0,
      icon: map['icon'],
    );
  }
}
