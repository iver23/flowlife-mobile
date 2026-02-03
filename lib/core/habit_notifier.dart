import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/habit_model.dart';
import '../data/services/firestore_service.dart';
import 'providers.dart';
import 'achievement_notifier.dart';

class HabitNotifier extends AsyncNotifier<List<HabitModel>> {
  FirestoreService get _service => ref.watch(firestoreServiceProvider);

  @override
  FutureOr<List<HabitModel>> build() async {
    final stream = _service.streamHabits();
    
    stream.listen((habits) {
      state = AsyncData(habits);
    });

    return stream.first;
  }

  Future<void> addHabit(HabitModel habit) async {
    await _service.addHabit(habit);
  }

  Future<void> completeHabitToday(HabitModel habit) async {
    await _service.completeHabitToday(habit.id, habit.completedDates);
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _service.updateHabit(habit);
  }

  Future<void> deleteHabit(String habitId) async {
    await _service.deleteHabit(habitId);
  }
}

final habitNotifierProvider = AsyncNotifierProvider<HabitNotifier, List<HabitModel>>(() {
  return HabitNotifier();
});
