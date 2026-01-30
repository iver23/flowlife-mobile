import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/study_repository.dart';
import '../data/models/study_models.dart';
import 'theme_notifier.dart';

class StudyState {
  final List<SubjectArea> areas;
  final List<Subject> subjects;
  final List<Lesson> lessons;
  final bool isLoading;

  StudyState({
    this.areas = const [],
    this.subjects = const [],
    this.lessons = const [],
    this.isLoading = false,
  });

  StudyState copyWith({
    List<SubjectArea>? areas,
    List<Subject>? subjects,
    List<Lesson>? lessons,
    bool? isLoading,
  }) {
    return StudyState(
      areas: areas ?? this.areas,
      subjects: subjects ?? this.subjects,
      lessons: lessons ?? this.lessons,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StudyNotifier extends StateNotifier<StudyState> {
  final StudyRepository _repo;
  final _uuid = Uuid();

  StudyNotifier(this._repo) : super(StudyState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    final areas = await _repo.getAreas();
    final subjects = await _repo.getSubjects();
    final lessons = await _repo.getLessons();
    state = state.copyWith(
      areas: areas..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      subjects: subjects..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      lessons: lessons..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      isLoading: false,
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
    final newList = [...state.areas, area];
    state = state.copyWith(areas: newList);
    await _repo.saveAreas(newList);
  }

  Future<void> deleteArea(String id) async {
    final newList = state.areas.where((e) => e.id != id).toList();
    state = state.copyWith(areas: newList);
    await _repo.saveAreas(newList);
    // Cleanup children or keep orphaned for now (MVP simple)
  }

  // --- SUBJECTS ---
  Future<void> addSubject(String areaId, String name) async {
    final subject = Subject(
      id: _uuid.v4(),
      areaId: areaId,
      name: name,
      createdAt: DateTime.now(),
    );
    final newList = [...state.subjects, subject];
    state = state.copyWith(subjects: newList);
    await _repo.saveSubjects(newList);
  }

  Future<void> deleteSubject(String id) async {
    final newList = state.subjects.where((e) => e.id != id).toList();
    state = state.copyWith(subjects: newList);
    await _repo.saveSubjects(newList);
  }

  // --- LESSONS ---
  Future<void> addLesson(String subjectId, String title) async {
    final lesson = Lesson(
      id: _uuid.v4(),
      subjectId: subjectId,
      title: title,
      createdAt: DateTime.now(),
    );
    final newList = [...state.lessons, lesson];
    state = state.copyWith(lessons: newList);
    await _repo.saveLessons(newList);
  }

  Future<void> toggleLesson(String id) async {
    final newList = state.lessons.map((e) {
      if (e.id == id) return e.copyWith(isCompleted: !e.isCompleted);
      return e;
    }).toList();
    state = state.copyWith(lessons: newList);
    await _repo.saveLessons(newList);
  }

  Future<void> deleteLesson(String id) async {
    final newList = state.lessons.where((e) => e.id != id).toList();
    state = state.copyWith(lessons: newList);
    await _repo.saveLessons(newList);
  }

  // --- HELPERS ---
  double getSubjectProgress(String subjectId) {
    final subjectLessons = state.lessons.where((e) => e.subjectId == subjectId).toList();
    if (subjectLessons.isEmpty) return 0;
    final completed = subjectLessons.where((e) => e.isCompleted).length;
    return completed / subjectLessons.length;
  }

  int getCompletedLessonsCount() => state.lessons.where((e) => e.isCompleted).length;
  int getTotalLessonsCount() => state.lessons.length;

  double getAreaProgress(String areaId) {
    final areaSubjects = state.subjects.where((s) => s.areaId == areaId).toList();
    if (areaSubjects.isEmpty) return 0;
    
    int totalLessons = 0;
    int completedLessons = 0;
    
    for (var subject in areaSubjects) {
      final subjectLessons = state.lessons.where((l) => l.subjectId == subject.id).toList();
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

final studyNotifierProvider = StateNotifierProvider<StudyNotifier, StudyState>((ref) {
  final repo = ref.watch(studyRepositoryProvider);
  return StudyNotifier(repo);
});
