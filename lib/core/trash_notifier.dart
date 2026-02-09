import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/models/habit_model.dart';
import '../data/models/study_models.dart';
import '../data/services/trash_service.dart';
import 'providers.dart';

class TrashNotifier extends AsyncNotifier<void> {
  TrashService get _service => ref.watch(trashServiceProvider);

  @override
  FutureOr<void> build() async {
    // Purge expired items on startup
    await _service.purgeExpiredItems(15);
  }

  Future<void> trashTask(TaskModel task) async {
    await _service.trashTask(task);
  }

  Future<void> restoreTask(String taskId) async {
    await _service.restoreTask(taskId);
  }

  Future<void> permanentlyDeleteTask(String taskId) async {
    await _service.permanentlyDeleteTask(taskId);
  }

  Future<void> trashProject(ProjectModel project) async {
    await _service.trashProject(project);
  }

  Future<void> restoreProject(String projectId) async {
    await _service.restoreProject(projectId);
  }

  Future<void> permanentlyDeleteProject(String projectId) async {
    await _service.permanentlyDeleteProject(projectId);
  }

  Future<void> trashIdea(IdeaModel idea) async {
    await _service.trashIdea(idea);
  }

  Future<void> restoreIdea(String ideaId) async {
    await _service.restoreIdea(ideaId);
  }

  Future<void> trashHabit(HabitModel habit) async {
    await _service.trashHabit(habit);
  }

  Future<void> restoreHabit(String habitId) async {
    await _service.restoreHabit(habitId);
  }

  Future<void> permanentlyDeleteHabit(String habitId) async {
    await _service.permanentlyDeleteHabit(habitId);
  }

  Future<void> permanentlyDeleteIdea(String ideaId) async {
    await _service.permanentlyDeleteIdea(ideaId);
  }

  Future<void> trashSubjectArea(SubjectArea area) async {
    await _service.trashSubjectArea(area);
  }

  Future<void> restoreSubjectArea(String areaId) async {
    await _service.restoreSubjectArea(areaId);
  }

  Future<void> permanentlyDeleteSubjectArea(String areaId) async {
    await _service.permanentlyDeleteSubjectArea(areaId);
  }

  Future<void> trashSubject(Subject subject) async {
    await _service.trashSubject(subject);
  }

  Future<void> restoreSubject(String subjectId) async {
    await _service.restoreSubject(subjectId);
  }

  Future<void> permanentlyDeleteSubject(String subjectId) async {
    await _service.permanentlyDeleteSubject(subjectId);
  }

  Future<void> trashLesson(Lesson lesson) async {
    await _service.trashLesson(lesson);
  }

  Future<void> restoreLesson(String lessonId) async {
    await _service.restoreLesson(lessonId);
  }

  Future<void> permanentlyDeleteLesson(String lessonId) async {
    await _service.permanentlyDeleteLesson(lessonId);
  }

  Future<void> emptyTrash() async {
    await _service.purgeExpiredItems(0); // 0 days means purge all deleted items
  }
}

final trashNotifierProvider = AsyncNotifierProvider<TrashNotifier, void>(() {
  return TrashNotifier();
});

final trashServiceProvider = Provider((ref) => TrashService());
