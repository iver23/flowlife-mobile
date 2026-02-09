import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/firestore_service.dart';
import 'providers.dart';
import 'trash_notifier.dart';

class IdeaNotifier extends AsyncNotifier<List<IdeaModel>> {
  FirestoreService get _service => ref.watch(firestoreServiceProvider);

  @override
  FutureOr<List<IdeaModel>> build() async {
    final stream = _service.streamIdeas();
    
    stream.listen((ideas) {
      state = AsyncData(ideas);
    }, onError: (e, st) {
      state = AsyncError(e, st);
    });

    return stream.first;
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

  Future<void> deleteIdea(IdeaModel idea) async {
    await ref.read(trashNotifierProvider.notifier).trashIdea(idea);
  }

  Future<void> restoreIdea(String ideaId) async {
    await ref.read(trashNotifierProvider.notifier).restoreIdea(ideaId);
  }

  Future<void> convertToTask(IdeaModel idea) async {
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

final ideaNotifierProvider = AsyncNotifierProvider<IdeaNotifier, List<IdeaModel>>(() {
  return IdeaNotifier();
});
