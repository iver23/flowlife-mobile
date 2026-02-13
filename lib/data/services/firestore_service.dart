import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../models/habit_model.dart';
import '../models/achievement_model.dart';
import '../models/widget_model.dart';
import '../models/study_models.dart';
import '../services/schema_migration_service.dart';
import '../../core/app_logger.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SchemaMigrationService _migration;

  FirestoreService(this._migration);

  String? get userId => _auth.currentUser?.uid;

  void _writebackIfMigrated(DocumentReference ref, Map<String, dynamic> original, Map<String, dynamic> migrated) {
    if (migrated['schemaVersion'] != original['schemaVersion']) {
      AppLogger.migration('Writing back migrated document to ${ref.path}');
      ref.update({'schemaVersion': migrated['schemaVersion']}).catchError(
        (e, st) => AppLogger.error('Migration writeback failed: ${ref.path}', e, st),
      );
    }
  }

  // --- Projects ---
  Stream<List<ProjectModel>> streamProjects() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('projects')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              final migrated = _migration.migrateDocument('projects', data);
              _writebackIfMigrated(doc.reference, data, migrated);
              return ProjectModel.fromMap(migrated, doc.id);
            }).where((item) => item.isDeleted != true).toList());
  }

  Stream<List<ProjectModel>> streamTrashedProjects() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('projects')
        .where('isDeleted', isEqualTo: true)
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

  // --- System Project Initialization & Migration ---
  Future<void> ensureOtherProjectExists() async {
    if (userId == null) return;
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('projects')
        .doc('other');
    
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'title': 'Other',
        'color': 'slate',
        'icon': 'hash',
        'weight': 1,
        'isSystemProject': true,
        'isDeleted': false,
        'isArchived': false,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Future<void> migrateNullProjectItems() async {
    if (userId == null) return;
    final batch = _db.batch();
    bool hasChanges = false;

    // Migrate tasks where projectId is null
    final tasksSnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('projectId', isNull: true)
        .get();
    
    for (final doc in tasksSnapshot.docs) {
      batch.update(doc.reference, {'projectId': 'other'});
      hasChanges = true;
    }

    // Migrate ideas where projectId is null
    final ideasSnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('ideas')
        .where('projectId', isNull: true)
        .get();
    
    for (final doc in ideasSnapshot.docs) {
      batch.update(doc.reference, {'projectId': 'other'});
      hasChanges = true;
    }

    if (hasChanges) {
      await batch.commit();
    }
  }

  // --- Tasks ---
  Stream<List<TaskModel>> streamTasks() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs.map((doc) {
            final data = doc.data();
            final migrated = _migration.migrateDocument('tasks', data);
            _writebackIfMigrated(doc.reference, data, migrated);
            return TaskModel.fromMap(migrated, doc.id);
          }).where((task) => task.isDeleted != true).toList();
          tasks.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
          return tasks;
        });
  }

  Stream<List<TaskModel>> streamTrashedTasks() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList();
          tasks.sort((a, b) => (b.deletedAt ?? 0).compareTo(a.deletedAt ?? 0));
          return tasks;
        });
  }

  // --- Ideas ---
  Stream<List<IdeaModel>> streamIdeas() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('ideas')
        .snapshots()
        .map((snapshot) {
          final ideas = snapshot.docs.map((doc) {
            final data = doc.data();
            final migrated = _migration.migrateDocument('ideas', data);
            _writebackIfMigrated(doc.reference, data, migrated);
            return IdeaModel.fromMap(migrated, doc.id);
          }).where((item) => item.isDeleted != true).toList();
          ideas.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
          return ideas;
        });
  }

  Stream<List<IdeaModel>> streamTrashedIdeas() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('ideas')
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final ideas = snapshot.docs
              .map((doc) => IdeaModel.fromMap(doc.data(), doc.id))
              .toList();
          ideas.sort((a, b) => (b.deletedAt ?? 0).compareTo(a.deletedAt ?? 0));
          return ideas;
        });
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
        .snapshots()
        .map((snapshot) {
          final habits = snapshot.docs
              .map((doc) => HabitModel.fromMap(_migration.migrateDocument('habits', doc.data()), doc.id))
              .where((item) => item.isDeleted != true)
              .toList();
          habits.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
          return habits;
        });
  }

  Stream<List<HabitModel>> streamTrashedHabits() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final habits = snapshot.docs
              .map((doc) => HabitModel.fromMap(doc.data(), doc.id))
              .toList();
          habits.sort((a, b) => (b.deletedAt ?? 0).compareTo(a.deletedAt ?? 0));
          return habits;
        });
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
            .map((doc) => AchievementModel.fromMap(_migration.migrateDocument('achievements', doc.data()), doc.id))
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
            .map((doc) => DashboardWidgetModel.fromMap(_migration.migrateDocument('dashboard_widgets', doc.data()), doc.id))
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

  // --- Study ---
  Stream<List<SubjectArea>> streamSubjectAreas() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('subject_areas')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubjectArea.fromMap(_migration.migrateDocument('subject_areas', doc.data()), doc.id))
            .where((item) => item.isDeleted != true)
            .toList());
  }

  Stream<List<SubjectArea>> streamTrashedSubjectAreas() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('subject_areas')
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubjectArea.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Subject>> streamSubjects() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('subjects')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Subject.fromMap(_migration.migrateDocument('subjects', doc.data()), doc.id))
            .where((item) => item.isDeleted != true)
            .toList());
  }
  Stream<List<Subject>> streamTrashedSubjects() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('subjects')
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Subject.fromMap(_migration.migrateDocument('subjects', doc.data()), doc.id))
            .toList());
  }

  Stream<List<Lesson>> streamLessons() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('lessons')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Lesson.fromMap(_migration.migrateDocument('lessons', doc.data()), doc.id))
            .where((item) => item.isDeleted != true)
            .toList());
  }

  Stream<List<Lesson>> streamTrashedLessons() {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('lessons')
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Lesson.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addSubjectArea(SubjectArea area) => _db.collection('users').doc(userId).collection('subject_areas').doc(area.id).set(area.toMap());
  Future<void> updateSubjectArea(SubjectArea area) => _db.collection('users').doc(userId).collection('subject_areas').doc(area.id).update(area.toMap());

  Future<void> addSubject(Subject subject) => _db.collection('users').doc(userId).collection('subjects').doc(subject.id).set(subject.toMap());
  Future<void> updateSubject(Subject subject) => _db.collection('users').doc(userId).collection('subjects').doc(subject.id).update(subject.toMap());

  Future<void> addLesson(Lesson lesson) => _db.collection('users').doc(userId).collection('lessons').doc(lesson.id).set(lesson.toMap());
  Future<void> updateLesson(Lesson lesson) => _db.collection('users').doc(userId).collection('lessons').doc(lesson.id).update(lesson.toMap());
}
