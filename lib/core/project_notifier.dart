import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/firestore_service.dart';
import 'providers.dart';

class ProjectNotifier extends StateNotifier<AsyncValue<List<ProjectModel>>> {
  final FirestoreService _service;

  ProjectNotifier(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _service.streamProjects().listen((projects) {
      state = AsyncValue.data(projects);
    }, onError: (e, st) {
      state = AsyncValue.error(e, st);
    });
  }

  Future<void> deleteProject(String projectId) async {
    // Note: In a real app, you might want to delete associated tasks too
    // or keep them as unassigned. Firestore doesn't delete sub-collections automatically.
    // For now, mirroring the likely web behavior of just deleting the project doc.
    await _service.deleteProject(projectId);
  }
}

final projectNotifierProvider = StateNotifierProvider<ProjectNotifier, AsyncValue<List<ProjectModel>>>((ref) {
  return ProjectNotifier(ref.watch(firestoreServiceProvider));
});
