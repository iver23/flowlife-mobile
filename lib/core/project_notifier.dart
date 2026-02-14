import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/firestore_service.dart';
import 'providers.dart';
import 'trash_notifier.dart';
import 'widget_service.dart';
import 'task_notifier.dart';

class ProjectNotifier extends AsyncNotifier<List<ProjectModel>> {
  FirestoreService get _service => ref.watch(firestoreServiceProvider);
  StreamSubscription<List<ProjectModel>>? _subscription;

  @override
  FutureOr<List<ProjectModel>> build() async {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    final stream = _service.streamProjects();
    
    _subscription = stream.listen((projects) {
      state = AsyncData(projects);
      _triggerWidgetUpdate(projects);
    }, onError: (e, st) {
      state = AsyncError(e, st);
    });

    return stream.first;
  }

  void _triggerWidgetUpdate(List<ProjectModel> projects) {
    ref.read(taskNotifierProvider).when(
      data: (tasks) => WidgetService.updateWidget(tasks: tasks, projects: projects),
      loading: () => WidgetService.updateWidget(tasks: [], projects: projects),
      error: (_, _) => WidgetService.updateWidget(tasks: [], projects: projects),
    );
  }

  Future<void> addProject(ProjectModel project) async {
    await _service.addProject(project);
  }

  Future<void> updateProject(ProjectModel project) async {
    await _service.updateProject(project);
  }

  Future<void> deleteProject(ProjectModel project) async {
    await ref.read(trashNotifierProvider.notifier).trashProject(project);
  }

  Future<void> restoreProject(String projectId) async {
    await ref.read(trashNotifierProvider.notifier).restoreProject(projectId);
  }

  Future<void> archiveProject(ProjectModel project) async {
    await updateProject(project.copyWith(isArchived: true));
  }

  Future<void> unarchiveProject(ProjectModel project) async {
    await updateProject(project.copyWith(isArchived: false));
  }
}

final projectNotifierProvider = AsyncNotifierProvider<ProjectNotifier, List<ProjectModel>>(() {
  return ProjectNotifier();
});
