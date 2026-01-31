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

final selectedTagFilterProvider = StateProvider<String?>((ref) => null);
final selectedProjectFilterProvider = StateProvider<String?>((ref) => null);
