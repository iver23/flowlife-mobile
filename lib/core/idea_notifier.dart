import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/firestore_service.dart';
import 'providers.dart';

class IdeaNotifier extends StateNotifier<AsyncValue<List<IdeaModel>>> {
  final FirestoreService _service;

  IdeaNotifier(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _service.streamIdeas().listen((ideas) {
      state = AsyncValue.data(ideas);
    }, onError: (e, st) {
      state = AsyncValue.error(e, st);
    });
  }

  Future<void> addIdea(String content, {String? projectId}) async {
    final newIdea = IdeaModel(
      id: '',
      content: content,
      projectId: projectId,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _service.addIdea(newIdea);
  }

  Future<void> deleteIdea(String id) async {
    await _service.deleteIdea(id);
  }

  Future<void> convertToTask(IdeaModel idea, WidgetRef ref) async {
    // Create the task
    final newTask = TaskModel(
      id: '',
      title: idea.content,
      projectId: idea.projectId, // Carry over the project
      completed: false,
      subtasks: [],
      createdAt: DateTime.now().millisecondsSinceEpoch,
      order: 0,
    );
    
    // Add task and delete idea
    await ref.read(firestoreServiceProvider).addTask(newTask);
    await _service.deleteIdea(idea.id);
  }
}

final ideaNotifierProvider = StateNotifierProvider<IdeaNotifier, AsyncValue<List<IdeaModel>>>((ref) {
  return IdeaNotifier(ref.watch(firestoreServiceProvider));
});
