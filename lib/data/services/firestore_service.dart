import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  // --- Projects ---
  Stream<List<ProjectModel>> streamProjects() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('projects')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteProject(String projectId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('projects')
        .doc(projectId)
        .delete();
  }

  // --- Tasks ---
  Stream<List<TaskModel>> streamTasks() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // --- Ideas ---
  Stream<List<IdeaModel>> streamIdeas() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('ideas')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IdeaModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // --- Ideas Actions ---
  Future<void> addIdea(IdeaModel idea) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('ideas')
        .add(idea.toMap());
  }

  Future<void> updateIdea(IdeaModel idea) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('ideas')
        .doc(idea.id)
        .update(idea.toMap());
  }

  Future<void> deleteIdea(String ideaId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('ideas')
        .doc(ideaId)
        .delete();
  }

  // --- Actions ---
  Future<void> addTask(TaskModel task) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .add(task.toMap());
  }

  Future<void> updateTask(TaskModel task) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  Future<void> deleteTask(String taskId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // Reordering (simplified batch)
  Future<void> updateTasksOrder(List<TaskModel> tasks) async {
    final batch = _db.batch();
    for (int i = 0; i < tasks.length; i++) {
      final ref = _db
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(tasks[i].id);
      batch.update(ref, {'order': i});
    }
    await batch.commit();
  }
}
