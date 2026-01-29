import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/firestore_service.dart';
import 'providers.dart';
import 'confetti_notifier.dart';
import 'date_parser.dart';
import 'notification_service.dart';

class TaskNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final FirestoreService _service;
  final Ref _ref;

  TaskNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _service.streamTasks().listen((tasks) {
      state = AsyncValue.data(tasks);
      _updateDailyRecap(tasks);
    }, onError: (e, st) {
      state = AsyncValue.error(e, st);
    });
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
    if (task.dueDate != null && !task.completed) {
      final scheduledDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
        9, // 9 AM
      );
      
      if (scheduledDate.isAfter(DateTime.now())) {
        NotificationService.scheduleNotification(
          task.id.hashCode,
          'Task Reminder',
          '${task.title} is due today!',
          scheduledDate,
        );
      }
    }
  }

  Future<void> toggleTask(TaskModel task) async {
    final newCompleted = !task.completed;
    if (newCompleted) {
      _ref.read(confettiProvider.notifier).trigger();
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
        subtasks: task.subtasks.map((st) => Subtask(id: DateTime.now().millisecondsSinceEpoch.toString(), title: st.title, completed: false)).toList(),
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

  Future<void> addTask(String title, {String? projectId}) async {
    final parsed = DateParser.parse(title);
    final cleanTitle = parsed['cleanText'] as String;
    final dueDate = parsed['date'] as DateTime?;

    final newTask = TaskModel(
      id: '', // Will be assigned by Firestore
      title: cleanTitle,
      completed: false,
      subtasks: [],
      createdAt: DateTime.now().millisecondsSinceEpoch,
      projectId: projectId,
      dueDate: dueDate,
      order: 0, // Simplified order for new tasks
    );
    await _service.addTask(newTask);
  }
}

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskModel>>>((ref) {
  return TaskNotifier(ref.watch(firestoreServiceProvider), ref);
});
