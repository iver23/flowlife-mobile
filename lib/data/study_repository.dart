import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/study_models.dart';

class StudyRepository {
  static const _keyAreas = 'study_areas';
  static const _keySubjects = 'study_subjects';
  static const _keyLessons = 'study_lessons';

  final SharedPreferences _prefs;

  StudyRepository(this._prefs);

  // AREAS
  Future<List<SubjectArea>> getAreas() async {
    final jsonStr = _prefs.getString(_keyAreas);
    if (jsonStr == null) return [];
    final List<dynamic> list = json.decode(jsonStr);
    return list.map((e) => SubjectArea.fromMap(e)).toList();
  }

  Future<void> saveAreas(List<SubjectArea> areas) async {
    final jsonStr = json.encode(areas.map((e) => e.toMap()).toList());
    await _prefs.setString(_keyAreas, jsonStr);
  }

  // SUBJECTS
  Future<List<Subject>> getSubjects() async {
    final jsonStr = _prefs.getString(_keySubjects);
    if (jsonStr == null) return [];
    final List<dynamic> list = json.decode(jsonStr);
    return list.map((e) => Subject.fromMap(e)).toList();
  }

  Future<void> saveSubjects(List<Subject> subjects) async {
    final jsonStr = json.encode(subjects.map((e) => e.toMap()).toList());
    await _prefs.setString(_keySubjects, jsonStr);
  }

  // LESSONS
  Future<List<Lesson>> getLessons() async {
    final jsonStr = _prefs.getString(_keyLessons);
    if (jsonStr == null) return [];
    final List<dynamic> list = json.decode(jsonStr);
    return list.map((e) => Lesson.fromMap(e)).toList();
  }

  Future<void> saveLessons(List<Lesson> lessons) async {
    final jsonStr = json.encode(lessons.map((e) => e.toMap()).toList());
    await _prefs.setString(_keyLessons, jsonStr);
  }
}
