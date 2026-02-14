import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart' hide Subject;
import '../data/services/firestore_service.dart';
import '../data/models/study_models.dart';
import 'providers.dart';

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
  StreamSubscription<StudyState>? _subscription;

  @override
  FutureOr<StudyState> build() async {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    final stream = Rx.combineLatest3(
      _firestore.streamSubjectAreas(),
      _firestore.streamSubjects(),
      _firestore.streamLessons(),
      (areas, subjects, lessons) => StudyState(
        areas: areas..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
        subjects: subjects..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
        lessons: lessons..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      ),
    );

    _subscription = stream.listen((newState) {
      state = AsyncData(newState);
    }, onError: (e, st) {
      state = AsyncError(e, st);
    });

    return stream.first;
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
  }

  Future<void> deleteArea(SubjectArea area) async {
    await _firestore.updateSubjectArea(area.copyWith(isDeleted: true, deletedAt: DateTime.now().millisecondsSinceEpoch));
  }

  Future<void> updateArea(SubjectArea area) async {
    await _firestore.updateSubjectArea(area);
  }

  Future<void> restoreArea(String id) async {
    final areas = await _firestore.streamTrashedSubjectAreas().first;
    final area = areas.firstWhere((e) => e.id == id);
    await _firestore.updateSubjectArea(area.copyWith(isDeleted: false, deletedAt: null));
  }

  Future<void> archiveArea(SubjectArea area) async {
    await _firestore.updateSubjectArea(area.copyWith(isArchived: true));
  }

  Future<void> unarchiveArea(SubjectArea area) async {
    await _firestore.updateSubjectArea(area.copyWith(isArchived: false));
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
  }

  Future<void> updateSubject(Subject subject) async {
    await _firestore.updateSubject(subject);
  }

  Future<void> deleteSubject(Subject subject) async {
    await _firestore.updateSubject(subject.copyWith(isDeleted: true, deletedAt: DateTime.now().millisecondsSinceEpoch));
  }

  Future<void> restoreSubject(String id) async {
    final subjects = await _firestore.streamTrashedSubjects().first;
    final subject = subjects.firstWhere((e) => e.id == id);
    await _firestore.updateSubject(subject.copyWith(isDeleted: false, deletedAt: null));
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
  }

  Future<void> toggleLesson(String id) async {
    final stateVal = state.value;
    if (stateVal == null) return;
    final lesson = stateVal.lessons.firstWhere((e) => e.id == id);
    await _firestore.updateLesson(lesson.copyWith(isCompleted: !lesson.isCompleted));
  }

  Future<void> deleteLesson(Lesson lesson) async {
    await _firestore.updateLesson(lesson.copyWith(isDeleted: true, deletedAt: DateTime.now().millisecondsSinceEpoch));
  }

  Future<void> restoreLesson(String id) async {
    final lessons = await _firestore.streamTrashedLessons().first;
    final lesson = lessons.firstWhere((e) => e.id == id);
    await _firestore.updateLesson(lesson.copyWith(isDeleted: false, deletedAt: null));
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

final studyNotifierProvider = AsyncNotifierProvider<StudyNotifier, StudyState>(() {
  return StudyNotifier();
});
