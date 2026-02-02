import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/firestore_service.dart';
import '../data/models/models.dart';

import 'auth_notifier.dart';

final firestoreServiceProvider = Provider((ref) {
  // We watch authProvider to ensure this provider is recreated when user changes
  ref.watch(authProvider);
  return FirestoreService();
});

final projectsProvider = StreamProvider<List<ProjectModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.streamProjects();
});

final tasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.streamTasks();
});

final ideasProvider = StreamProvider<List<IdeaModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.streamIdeas();
});

// Riverpod 3.x: StateProvider moved to Notifier pattern
class SelectedTagFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  
  void setTag(String? tag) => state = tag;
  void clear() => state = null;
}

class SelectedProjectFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  
  void setProject(String? projectId) => state = projectId;
  void clear() => state = null;
}

final selectedTagFilterProvider = NotifierProvider<SelectedTagFilterNotifier, String?>(() {
  return SelectedTagFilterNotifier();
});

final selectedProjectFilterProvider = NotifierProvider<SelectedProjectFilterNotifier, String?>(() {
  return SelectedProjectFilterNotifier();
});
