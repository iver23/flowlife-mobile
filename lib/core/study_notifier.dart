import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/study_repository.dart';
import '../data/models/study_models.dart';
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
  StudyRepository get _repo => ref.watch(studyRepositoryProvider);
  final _uuid = Uuid();

  @override
  Future<StudyState> build() async {
    final areas = await _repo.getAreas();
    final subjects = await _repo.getSubjects();
    final lessons = await _repo.getLessons();
    
    return StudyState(
      areas: areas..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      subjects: subjects..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      lessons: lessons..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
    );
  }

  // --- AREAS ---
  Future<void> addArea(String name, String color) async {
    final current = state.value ?? StudyState();
    final area = SubjectArea(
      id: _uuid.v4(),
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );
    final newList = [...current.areas, area];
    state = AsyncData(current.copyWith(areas: newList));
    await _repo.saveAreas(newList);
  }

  Future<void> deleteArea(String id) async {
    final current = state.value ?? StudyState();
    final newList = current.areas.where((e) => e.id != id).toList();
    state = AsyncData(current.copyWith(areas: newList));
    await _repo.saveAreas(newList);
  }

  Future<void> archiveArea(SubjectArea area) async {
    final current = state.value ?? StudyState();
    final newList = current.areas.map((e) {
      if (e.id == area.id) return e.copyWith(isArchived: true);
      return e;
    }).toList();
    state = AsyncData(current.copyWith(areas: newList));
    await _repo.saveAreas(newList);
  }

  Future<void> unarchiveArea(SubjectArea area) async {
    final current = state.value ?? StudyState();
    final newList = current.areas.map((e) {
      if (e.id == area.id) return e.copyWith(isArchived: false);
      return e;
    }).toList();
    state = AsyncData(current.copyWith(areas: newList));
    await _repo.saveAreas(newList);
  }

  // --- SUBJECTS ---
  Future<void> addSubject(String areaId, String name) async {
    final current = state.value ?? StudyState();
    final subject = Subject(
      id: _uuid.v4(),
      areaId: areaId,
      name: name,
      createdAt: DateTime.now(),
    );
    final newList = [...current.subjects, subject];
    state = AsyncData(current.copyWith(subjects: newList));
    await _repo.saveSubjects(newList);
  }

  Future<void> deleteSubject(String id) async {
    final current = state.value ?? StudyState();
    final newList = current.subjects.where((e) => e.id != id).toList();
    state = AsyncData(current.copyWith(subjects: newList));
    await _repo.saveSubjects(newList);
  }

  // --- LESSONS ---
  Future<void> addLesson(String subjectId, String title) async {
    final current = state.value ?? StudyState();
    final lesson = Lesson(
      id: _uuid.v4(),
      subjectId: subjectId,
      title: title,
      createdAt: DateTime.now(),
    );
    final newList = [...current.lessons, lesson];
    state = AsyncData(current.copyWith(lessons: newList));
    await _repo.saveLessons(newList);
  }

  Future<void> toggleLesson(String id) async {
    final current = state.value ?? StudyState();
    final newList = current.lessons.map((e) {
      if (e.id == id) return e.copyWith(isCompleted: !e.isCompleted);
      return e;
    }).toList();
    state = AsyncData(current.copyWith(lessons: newList));
    await _repo.saveLessons(newList);
  }

  Future<void> deleteLesson(String id) async {
    final current = state.value ?? StudyState();
    final newList = current.lessons.where((e) => e.id != id).toList();
    state = AsyncData(current.copyWith(lessons: newList));
    await _repo.saveLessons(newList);
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

final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StudyRepository(prefs);
});

final studyNotifierProvider = AsyncNotifierProvider<StudyNotifier, StudyState>(() {
  return StudyNotifier();
});
