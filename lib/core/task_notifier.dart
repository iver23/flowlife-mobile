import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/firestore_service.dart';
import 'providers.dart';
import 'confetti_notifier.dart';
import 'date_parser.dart';
import 'notification_service.dart';
import 'widget_service.dart';
import 'project_notifier.dart';
import 'reminder_settings_notifier.dart';
import 'achievement_notifier.dart';

class TaskNotifier extends AsyncNotifier<List<TaskModel>> {
  FirestoreService get _service => ref.watch(firestoreServiceProvider);

  @override
  FutureOr<List<TaskModel>> build() async {
    // Initial data from stream
    final stream = _service.streamTasks();
    
    // Listen for updates and push into state
    stream.listen((tasks) {
      state = AsyncData(tasks);
      _updateDailyRecap(tasks);
      _triggerWidgetUpdate(tasks);
    }, onError: (e, st) {
      state = AsyncError(e, st);
    });

    // Return first snapshot or empty list if loading
    return stream.first;
  }

  void _triggerWidgetUpdate(List<TaskModel> tasks) {
    ref.read(projectNotifierProvider).when(
      data: (projects) => WidgetService.updateWidget(tasks: tasks, projects: projects),
      loading: () => WidgetService.updateWidget(tasks: tasks, projects: []),
      error: (_, __) => WidgetService.updateWidget(tasks: tasks, projects: []),
    );
  }

  void _updateDailyRecap(List<TaskModel> tasks) {
    final today = DateTime.now();
    final todayTasks = tasks.where((t) {
      if (t.completed || t.dueDate == null) return false;
      return t.dueDate!.year == today.year && 
             t.dueDate!.month == today.month && 
             t.dueDate!.day == today.day;
    }).length;

    NotificationService.scheduleDailyRecap(todayTasks);
  }

  void _scheduleTaskNotification(TaskModel task) {
    if (!task.completed && task.reminderEnabled && task.reminderTime != null) {
      NotificationService.scheduleTaskReminder(task);
    }
  }

  Future<void> toggleTask(TaskModel task) async {
    final newCompleted = !task.completed;
    if (newCompleted) {
      ref.read(confettiProvider.notifier).trigger();
    }

    final updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      projectId: task.projectId,
      dueDate: task.dueDate,
      recurrence: task.recurrence,
      completed: !task.completed,
      completedAt: !task.completed ? DateTime.now().millisecondsSinceEpoch : null,
      energyLevel: task.energyLevel,
      subtasks: task.subtasks,
      createdAt: task.createdAt,
      order: task.order,
    );
    await _service.updateTask(updatedTask);

    // Recurrence Logic
    if (newCompleted && 
        task.recurrence != RecurrenceType.NONE && 
        task.dueDate != null) {
      final nextDueDate = _calculateNextDueDate(task.dueDate!, task.recurrence);
      final nextTask = TaskModel(
        id: '',
        title: task.title,
        description: task.description,
        projectId: task.projectId,
        dueDate: nextDueDate,
        recurrence: task.recurrence,
        completed: false,
        subtasks: task.subtasks.map((st) => Subtask(
          id: DateTime.now().millisecondsSinceEpoch.toString() + st.id, 
          title: st.title, 
          completed: false,
        )).toList(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        energyLevel: task.energyLevel,
        order: task.order,
      );
      await _service.addTask(nextTask);
    }
  }

  DateTime _calculateNextDueDate(DateTime current, RecurrenceType type) {
    if (type == RecurrenceType.DAILY) {
      return current.add(const Duration(days: 1));
    } else if (type == RecurrenceType.WEEKLY) {
      return current.add(const Duration(days: 7));
    } else if (type == RecurrenceType.MONTHLY) {
      return DateTime(current.year, current.month + 1, current.day);
    }
    return current;
  }

  Future<void> updateTask(TaskModel task) async {
    await _service.updateTask(task);
    _scheduleTaskNotification(task);
  }

  Future<void> deleteTask(String taskId) async {
    await _service.deleteTask(taskId);
  }

  Future<void> reorderTasks(List<TaskModel> tasks) async {
    await _service.updateTasksOrder(tasks);
  }

  Future<void> addTask(TaskModel task) async {
    final parsed = DateParser.parse(task.title);
    final cleanTitle = parsed['cleanText'] as String;
    final dueDate = parsed['date'] as DateTime? ?? task.dueDate;

    final newTask = TaskModel(
      id: '', // Will be assigned by Firestore
      title: cleanTitle,
      description: task.description,
      projectId: task.projectId,
      dueDate: dueDate,
      recurrence: task.recurrence,
      completed: false,
      energyLevel: task.energyLevel,
      subtasks: task.subtasks,
      customTags: task.customTags,
      isPinned: task.isPinned,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      order: 0, // Simplified order for new tasks
    );
    await _service.addTask(newTask);
  }

  Future<void> deleteMultipleTasks(List<String> ids) async {
    await _service.deleteMultipleTasks(ids);
  }

  Future<void> completeMultipleTasks(List<String> ids) async {
    final tasks = state.value ?? [];
    final updatedTasks = <TaskModel>[];
    final newTasksToAdd = <TaskModel>[];

    for (final id in ids) {
      final task = tasks.firstWhere((t) => t.id == id);
      if (task.completed) continue;

      updatedTasks.add(TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        projectId: task.projectId,
        dueDate: task.dueDate,
        recurrence: task.recurrence,
        completed: true,
        completedAt: DateTime.now().millisecondsSinceEpoch,
        energyLevel: task.energyLevel,
        subtasks: task.subtasks,
        createdAt: task.createdAt,
        order: task.order,
      ));

      // Recurrence logic
      if (task.recurrence != RecurrenceType.NONE && task.dueDate != null) {
        final nextDueDate = _calculateNextDueDate(task.dueDate!, task.recurrence);
        newTasksToAdd.add(TaskModel(
          id: '',
          title: task.title,
          description: task.description,
          projectId: task.projectId,
          dueDate: nextDueDate,
          recurrence: task.recurrence,
          completed: false,
          subtasks: task.subtasks.map((st) => Subtask(
            id: DateTime.now().millisecondsSinceEpoch.toString() + st.id, 
            title: st.title, 
            completed: false,
          )).toList(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          energyLevel: task.energyLevel,
          order: task.order,
        ));
      }
    }

    if (updatedTasks.isNotEmpty) {
      await _service.updateMultipleTasks(updatedTasks);
      ref.read(confettiProvider.notifier).trigger();
    }

    for (final newTask in newTasksToAdd) {
      await _service.addTask(newTask);
    }
  }

  Future<void> moveTasksToProject(List<String> ids, String? projectId) async {
    final tasks = state.value ?? [];
    final updatedTasks = <TaskModel>[];

    for (final id in ids) {
      final task = tasks.firstWhere((t) => t.id == id);
      updatedTasks.add(task.copyWith(projectId: projectId));
    }

    if (updatedTasks.isNotEmpty) {
      await _service.updateMultipleTasks(updatedTasks);
    }
  }

  Future<void> checkProjectNudges() async {
    final projects = await ref.read(projectNotifierProvider.future);
    final settings = ref.read(reminderSettingsProvider);
    
    if (!settings.projectNudgesEnabled) return;
    if (NotificationService.isQuietHours(settings.quietHoursStart, settings.quietHoursEnd)) return;

    final now = DateTime.now();
    for (final project in projects) {
      if (project.isArchived) continue;
      
      final lastVisited = project.lastVisitedAt != null 
          ? DateTime.fromMillisecondsSinceEpoch(project.lastVisitedAt!) 
          : DateTime.fromMillisecondsSinceEpoch(project.id.hashCode); // Fallback for old projects
      
      final diff = now.difference(lastVisited).inDays;
      if (diff >= 3) { // Nudge every 3 days of silence
        NotificationService.scheduleProjectNudge(project, diff);
      }
    }
  }
}

final taskNotifierProvider = AsyncNotifierProvider<TaskNotifier, List<TaskModel>>(() {
  return TaskNotifier();
});
