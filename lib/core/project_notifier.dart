import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/firestore_service.dart';
import 'providers.dart';
import 'widget_service.dart';
import 'task_notifier.dart';

class ProjectNotifier extends StateNotifier<AsyncValue<List<ProjectModel>>> {
  final FirestoreService _service;
  final Ref _ref;

  ProjectNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _service.streamProjects().listen((projects) {
      state = AsyncValue.data(projects);
      _triggerWidgetUpdate(projects);
    }, onError: (e, st) {
      state = AsyncValue.error(e, st);
    });
  }

  void _triggerWidgetUpdate(List<ProjectModel> projects) {
    _ref.read(taskNotifierProvider).when(
      data: (tasks) => WidgetService.updateWidget(tasks: tasks, projects: projects),
      loading: () => WidgetService.updateWidget(tasks: [], projects: projects),
      error: (_, __) => WidgetService.updateWidget(tasks: [], projects: projects),
    );
  }

  Future<void> addProject(ProjectModel project) async {
    await _service.addProject(project);
  }

  Future<void> updateProject(ProjectModel project) async {
    await _service.updateProject(project);
  }

  Future<void> deleteProject(String projectId) async {
    // Note: In a real app, you might want to delete associated tasks too
    // or keep them as unassigned. Firestore doesn't delete sub-collections automatically.
    // For now, mirroring the likely web behavior of just deleting the project doc.
    await _service.deleteProject(projectId);
  }

  Future<void> archiveProject(ProjectModel project) async {
    await updateProject(project.copyWith(isArchived: true));
  }

  Future<void> unarchiveProject(ProjectModel project) async {
    await updateProject(project.copyWith(isArchived: false));
  }
}

final projectNotifierProvider = StateNotifierProvider<ProjectNotifier, AsyncValue<List<ProjectModel>>>((ref) {
  return ProjectNotifier(ref.watch(firestoreServiceProvider), ref);
});
