import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../models/habit_model.dart';
import '../models/achievement_model.dart';
import '../models/widget_model.dart';

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

  Future<void> addProject(ProjectModel project) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('projects')
        .add(project.toMap());
  }

  Future<void> updateProject(ProjectModel project) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('projects')
        .doc(project.id)
        .update(project.toMap());
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

  Future<void> deleteMultipleTasks(List<String> taskIds) async {
    final batch = _db.batch();
    for (final id in taskIds) {
      final ref = _db
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(id);
      batch.delete(ref);
    }
    await batch.commit();
  }

  Future<void> updateMultipleTasks(List<TaskModel> tasks) async {
    final batch = _db.batch();
    for (final task in tasks) {
      final ref = _db
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id);
      batch.update(ref, task.toMap());
    }
    await batch.commit();
  }

  // --- Habits ---
  Stream<List<HabitModel>> streamHabits() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HabitModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addHabit(HabitModel habit) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .add(habit.toMap());
  }

  Future<void> updateHabit(HabitModel habit) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habit.id)
        .update(habit.toMap());
  }

  Future<void> completeHabitToday(String habitId, List<int> currentDates) async {
    final todayEpochDay = DateTime.now().difference(DateTime(1970, 1, 1)).inDays;
    if (currentDates.contains(todayEpochDay)) return; // Already completed
    
    return _db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habitId)
        .update({'completedDates': [...currentDates, todayEpochDay]});
  }

  Future<void> deleteHabit(String habitId) async {
    return _db.collection('users').doc(userId).collection('habits').doc(habitId).delete();
  }

  Stream<List<AchievementModel>> streamAchievements() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AchievementModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> unlockAchievement(String achievementId) async {
    return _db
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId)
        .update({
          'isUnlocked': true,
          'unlockedAt': DateTime.now().millisecondsSinceEpoch,
        });
  }

  Future<void> initializeAchievements(List<AchievementModel> initialAchievements) async {
    final batch = _db.batch();
    for (final achievement in initialAchievements) {
      final docRef = _db.collection('users').doc(userId).collection('achievements').doc(achievement.id);
      batch.set(docRef, achievement.toMap(), SetOptions(merge: true));
    }
    return batch.commit();
  }

  // --- Dashboard Widgets ---
  Stream<List<DashboardWidgetModel>> streamDashboardWidgets() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('dashboard_widgets')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DashboardWidgetModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateWidget(DashboardWidgetModel widget) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('dashboard_widgets')
        .doc(widget.id)
        .update(widget.toMap());
  }

  Future<void> initializeWidgets(List<DashboardWidgetModel> initialWidgets) async {
    final batch = _db.batch();
    for (final widget in initialWidgets) {
      final docRef = _db.collection('users').doc(userId).collection('dashboard_widgets').doc(widget.id);
      batch.set(docRef, widget.toMap(), SetOptions(merge: true));
    }
    return batch.commit();
  }
}
