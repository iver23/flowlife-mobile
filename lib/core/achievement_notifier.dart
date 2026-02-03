import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/achievement_model.dart';
import '../data/services/firestore_service.dart';
import 'providers.dart';
import 'task_notifier.dart';
import 'habit_notifier.dart';

class AchievementNotifier extends AsyncNotifier<List<AchievementModel>> {
  FirestoreService get _service => ref.watch(firestoreServiceProvider);

  @override
  FutureOr<List<AchievementModel>> build() async {
    final stream = _service.streamAchievements();
    
    // Listen to changes in tasks and habits to trigger checks
    ref.listen(taskNotifierProvider, (previous, next) {
      if (next is AsyncData) checkAchievements();
    });
    ref.listen(habitNotifierProvider, (previous, next) {
      if (next is AsyncData) checkAchievements();
    });

    stream.listen((achievements) {
      if (achievements.isEmpty) {
        _initializeDefaultAchievements();
      } else {
        state = AsyncData(achievements);
      }
    });

    return stream.first;
  }

  Future<void> _initializeDefaultAchievements() async {
    final defaults = [
      AchievementModel(
        id: 'first_task',
        title: 'Getting Started',
        description: 'Completed your first task!',
        icon: 'check',
        requirementType: 'tasks_completed',
        requirementValue: 1,
        category: 'productivity',
      ),
      AchievementModel(
        id: 'task_master_10',
        title: 'Task Master',
        description: 'Completed 10 tasks.',
        icon: 'target',
        requirementType: 'tasks_completed',
        requirementValue: 10,
        category: 'productivity',
      ),
      AchievementModel(
        id: 'habit_streak_3',
        title: 'Consistency King',
        description: 'Reached a 3-day habit streak.',
        icon: 'flame',
        requirementType: 'habit_streak',
        requirementValue: 3,
        category: 'wellness',
      ),
      AchievementModel(
        id: 'total_habits_5',
        title: 'Life Balancer',
        description: 'Managing 5 different habits.',
        icon: 'layout',
        requirementType: 'total_habits',
        requirementValue: 5,
        category: 'wellness',
      ),
    ];
    await _service.initializeAchievements(defaults);
  }

  Future<void> checkAchievements() async {
    final achievements = state.value ?? [];
    final tasks = await ref.read(taskNotifierProvider.future);
    final habits = await ref.read(habitNotifierProvider.future);

    final completedTasksCount = tasks.where((t) => t.completed).length;
    final maxHabitStreak = habits.isEmpty ? 0 : habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
    final totalHabitsCount = habits.length;

    for (final ach in achievements) {
      if (ach.isUnlocked) continue;

      bool shouldUnlock = false;
      if (ach.requirementType == 'tasks_completed' && completedTasksCount >= ach.requirementValue) {
        shouldUnlock = true;
      } else if (ach.requirementType == 'habit_streak' && maxHabitStreak >= ach.requirementValue) {
        shouldUnlock = true;
      } else if (ach.requirementType == 'total_habits' && totalHabitsCount >= ach.requirementValue) {
        shouldUnlock = true;
      }

      if (shouldUnlock) {
        await _service.unlockAchievement(ach.id);
      }
    }
  }
}

final achievementProvider = AsyncNotifierProvider<AchievementNotifier, List<AchievementModel>>(() {
  return AchievementNotifier();
});
