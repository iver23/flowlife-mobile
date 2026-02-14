import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/habit_model.dart';
import '../data/services/firestore_service.dart';
import 'providers.dart';
import 'trash_notifier.dart';

class HabitNotifier extends AsyncNotifier<List<HabitModel>> {
  FirestoreService get _service => ref.watch(firestoreServiceProvider);
  StreamSubscription<List<HabitModel>>? _subscription;

  @override
  FutureOr<List<HabitModel>> build() async {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    final stream = _service.streamHabits();
    
    _subscription = stream.listen((habits) {
      state = AsyncData(habits);
    }, onError: (e, st) {
      state = AsyncError(e, st);
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

  Future<void> deleteHabit(HabitModel habit) async {
    await ref.read(trashNotifierProvider.notifier).trashHabit(habit);
  }

  Future<void> restoreHabit(String habitId) async {
    await ref.read(trashNotifierProvider.notifier).restoreHabit(habitId);
  }
}

final habitNotifierProvider = AsyncNotifierProvider<HabitNotifier, List<HabitModel>>(() {
  return HabitNotifier();
});
