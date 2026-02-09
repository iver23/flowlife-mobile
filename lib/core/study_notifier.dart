import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/services/firestore_service.dart';
import '../data/models/study_models.dart';
import 'providers.dart';
import 'theme_notifier.dart';

class StudyState {
  final List<SubjectArea> areas;
  final List<Subject> subjects;
  final List<Lesson> lessons;

  StudyState({
    this.areas = const [],
    this.subjects = const [],
    this.lessons = const [],
  });

  StudyState copyWith({
    List<SubjectArea>? areas,
    List<Subject>? subjects,
    List<Lesson>? lessons,
  }) {
    return StudyState(
      areas: areas ?? this.areas,
      subjects: subjects ?? this.subjects,
      lessons: lessons ?? this.lessons,
    );
  }
}

class StudyNotifier extends AsyncNotifier<StudyState> {
  FirestoreService get _firestore => ref.watch(firestoreServiceProvider);
  final _uuid = Uuid();

  @override
  Future<StudyState> build() async {
    // Listen to firestore streams and combine them
    // For simplicity in the first pass, we'll fetch once and then rebuild on changes if needed,
    // or use StreamProvider for each.
    // However, the requested architectural goal is to unify.
    
    // We'll use StreamZip or simple combine-latest style if we wanted pure streams,
    // but the current Notifier is AsyncNotifier which builds once.
    // To maintain the "Notifier" feel with real-time Firestore, we should switch to StreamNotifier
    // or manually subscribe.
    
    final areas = await _firestore.streamSubjectAreas().first;
    final subjects = await _firestore.streamSubjects().first;
    final lessons = await _firestore.streamLessons().first;
    
    return StudyState(
      areas: areas..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      subjects: subjects..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      lessons: lessons..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
    );
  }

  // --- AREAS ---
  Future<void> addArea(String name, String color) async {
    final area = SubjectArea(
      id: _uuid.v4(),
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );
    await _firestore.addSubjectArea(area);
    ref.invalidateSelf();
  }

  Future<void> deleteArea(SubjectArea area) async {
    await _firestore.updateSubjectArea(area.copyWith(isDeleted: true, deletedAt: DateTime.now().millisecondsSinceEpoch));
    ref.invalidateSelf();
  }

  Future<void> restoreArea(String id) async {
    final areas = await _firestore.streamTrashedSubjectAreas().first;
    final area = areas.firstWhere((e) => e.id == id);
    await _firestore.updateSubjectArea(area.copyWith(isDeleted: false, deletedAt: null));
    ref.invalidateSelf();
  }

  Future<void> archiveArea(SubjectArea area) async {
    await _firestore.updateSubjectArea(area.copyWith(isArchived: true));
    ref.invalidateSelf();
  }

  Future<void> unarchiveArea(SubjectArea area) async {
    await _firestore.updateSubjectArea(area.copyWith(isArchived: false));
    ref.invalidateSelf();
  }

  // --- SUBJECTS ---
  Future<void> addSubject(String areaId, String name) async {
    final subject = Subject(
      id: _uuid.v4(),
      areaId: areaId,
      name: name,
      createdAt: DateTime.now(),
    );
    await _firestore.addSubject(subject);
    ref.invalidateSelf();
  }

  Future<void> deleteSubject(Subject subject) async {
    await _firestore.updateSubject(subject.copyWith(isDeleted: true, deletedAt: DateTime.now().millisecondsSinceEpoch));
    ref.invalidateSelf();
  }

  Future<void> restoreSubject(String id) async {
    final subjects = await _firestore.streamTrashedSubjects().first;
    final subject = subjects.firstWhere((e) => e.id == id);
    await _firestore.updateSubject(subject.copyWith(isDeleted: false, deletedAt: null));
    ref.invalidateSelf();
  }

  // --- LESSONS ---
  Future<void> addLesson(String subjectId, String title) async {
    final lesson = Lesson(
      id: _uuid.v4(),
      subjectId: subjectId,
      title: title,
      createdAt: DateTime.now(),
    );
    await _firestore.addLesson(lesson);
    ref.invalidateSelf();
  }

  Future<void> toggleLesson(String id) async {
    final state_val = state.value;
    if (state_val == null) return;
    final lesson = state_val.lessons.firstWhere((e) => e.id == id);
    await _firestore.updateLesson(lesson.copyWith(isCompleted: !lesson.isCompleted));
    ref.invalidateSelf();
  }

  Future<void> deleteLesson(Lesson lesson) async {
    await _firestore.updateLesson(lesson.copyWith(isDeleted: true, deletedAt: DateTime.now().millisecondsSinceEpoch));
    ref.invalidateSelf();
  }

  Future<void> restoreLesson(String id) async {
    final lessons = await _firestore.streamTrashedLessons().first;
    final lesson = lessons.firstWhere((e) => e.id == id);
    await _firestore.updateLesson(lesson.copyWith(isDeleted: false, deletedAt: null));
    ref.invalidateSelf();
  }

  // --- HELPERS ---
  double getSubjectProgress(String subjectId) {
    final current = state.value ?? StudyState();
    final subjectLessons = current.lessons.where((e) => e.subjectId == subjectId).toList();
    if (subjectLessons.isEmpty) return 0;
    final completed = subjectLessons.where((e) => e.isCompleted).length;
    return completed / subjectLessons.length;
  }

  int getCompletedLessonsCount() {
    final current = state.value ?? StudyState();
    return current.lessons.where((e) => e.isCompleted).length;
  }
  
  int getTotalLessonsCount() {
    final current = state.value ?? StudyState();
    return current.lessons.length;
  }

  double getAreaProgress(String areaId) {
    final current = state.value ?? StudyState();
    final areaSubjects = current.subjects.where((s) => s.areaId == areaId).toList();
    if (areaSubjects.isEmpty) return 0;
    
    int totalLessons = 0;
    int completedLessons = 0;
    
    for (var subject in areaSubjects) {
      final subjectLessons = current.lessons.where((l) => l.subjectId == subject.id).toList();
      totalLessons += subjectLessons.length;
      completedLessons += subjectLessons.where((l) => l.isCompleted).length;
    }
    
    if (totalLessons == 0) return 0;
    return completedLessons / totalLessons;
  }
}

// Provider already unified in providers.dart if needed, 
// but here we keep the existing structure but update the repo dependency.
final studyNotifierProvider = AsyncNotifierProvider<StudyNotifier, StudyState>(() {
  return StudyNotifier();
});
