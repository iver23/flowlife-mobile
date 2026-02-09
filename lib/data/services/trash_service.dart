import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../models/habit_model.dart';
import '../models/study_models.dart';

class TrashService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  Future<void> trashTask(TaskModel task) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .update({
      'isDeleted': true,
      'deletedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> restoreTask(String taskId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({
      'isDeleted': false,
      'deletedAt': null,
    });
  }

  Future<void> permanentlyDeleteTask(String taskId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  Future<void> trashProject(ProjectModel project) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('projects')
        .doc(project.id)
        .update({
      'isDeleted': true,
      'deletedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> restoreProject(String projectId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('projects')
        .doc(projectId)
        .update({
      'isDeleted': false,
      'deletedAt': null,
    });
  }

  Future<void> permanentlyDeleteProject(String projectId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('projects')
        .doc(projectId)
        .delete();
  }

  Future<void> trashIdea(IdeaModel idea) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('ideas')
        .doc(idea.id)
        .update({
      'isDeleted': true,
      'deletedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> restoreIdea(String ideaId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('ideas')
        .doc(ideaId)
        .update({
      'isDeleted': false,
      'deletedAt': null,
    });
  }

  Future<void> permanentlyDeleteIdea(String ideaId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('ideas')
        .doc(ideaId)
        .delete();
  }

  Future<void> trashHabit(HabitModel habit) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habit.id)
        .update({
      'isDeleted': true,
      'deletedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> restoreHabit(String habitId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habitId)
        .update({
      'isDeleted': false,
      'deletedAt': null,
    });
  }

  Future<void> permanentlyDeleteHabit(String habitId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habitId)
        .delete();
  }

  Future<void> trashSubjectArea(SubjectArea area) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('subject_areas')
        .doc(area.id)
        .update({
      'isDeleted': true,
      'deletedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> restoreSubjectArea(String areaId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('subject_areas')
        .doc(areaId)
        .update({
      'isDeleted': false,
      'deletedAt': null,
    });
  }

  Future<void> permanentlyDeleteSubjectArea(String areaId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('subject_areas')
        .doc(areaId)
        .delete();
  }

  Future<void> trashSubject(Subject subject) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('subjects')
        .doc(subject.id)
        .update({
      'isDeleted': true,
      'deletedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> restoreSubject(String subjectId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('subjects')
        .doc(subjectId)
        .update({
      'isDeleted': false,
      'deletedAt': null,
    });
  }

  Future<void> permanentlyDeleteSubject(String subjectId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('subjects')
        .doc(subjectId)
        .delete();
  }

  Future<void> trashLesson(Lesson lesson) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('lessons')
        .doc(lesson.id)
        .update({
      'isDeleted': true,
      'deletedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> restoreLesson(String lessonId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('lessons')
        .doc(lessonId)
        .update({
      'isDeleted': false,
      'deletedAt': null,
    });
  }

  Future<void> permanentlyDeleteLesson(String lessonId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('lessons')
        .doc(lessonId)
        .delete();
  }

  // Auto-purge logic (manual call for now)
  Future<void> purgeExpiredItems(int daysThreshold) async {
    if (userId == null) return;
    final threshold = DateTime.now()
        .subtract(Duration(days: daysThreshold))
        .millisecondsSinceEpoch;

    final collections = [
      'tasks',
      'projects',
      'ideas',
      'habits',
      'subject_areas',
      'subjects',
      'lessons'
    ];

    for (final col in collections) {
      final expiredItems = await _db
          .collection('users')
          .doc(userId)
          .collection(col)
          .where('isDeleted', isEqualTo: true)
          .where('deletedAt', isLessThan: threshold)
          .get();

      final batch = _db.batch();
      for (final doc in expiredItems.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
