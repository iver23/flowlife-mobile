import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeSelection { light, dark, system, scheduled }

class ThemeState {
  final ThemeSelection selection;
  final ThemeMode mode; // Actual mode applied to the app
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  ThemeState({
    required this.selection,
    required this.mode,
    this.startHour = 22,
    this.startMinute = 0,
    this.endHour = 7,
    this.endMinute = 0,
  });

  ThemeState copyWith({
    ThemeSelection? selection,
    ThemeMode? mode,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return ThemeState(
      selection: selection ?? this.selection,
      mode: mode ?? this.mode,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  static const _keySelection = 'theme_selection_str';
  static const _keyStartHour = 'theme_start_hour';
  static const _keyStartMinute = 'theme_start_minute';
  static const _keyEndHour = 'theme_end_hour';
  static const _keyEndMinute = 'theme_end_minute';

  SharedPreferences get _prefs => ref.watch(sharedPreferencesProvider);
  Timer? _scheduleTimer;

  @override
  ThemeState build() {
    // Start timer and ensure disposal
    _startTimer();
    ref.onDispose(() {
      _scheduleTimer?.cancel();
    });

    // Load initial state
    final selectionStr = _prefs.getString(_keySelection);
    final startHour = _prefs.getInt(_keyStartHour) ?? 22;
    final startMinute = _prefs.getInt(_keyStartMinute) ?? 0;
    final endHour = _prefs.getInt(_keyEndHour) ?? 7;
    final endMinute = _prefs.getInt(_keyEndMinute) ?? 0;

    ThemeSelection selection = ThemeSelection.system;
    if (selectionStr != null) {
      selection = ThemeSelection.values.firstWhere(
        (e) => e.name == selectionStr,
        orElse: () => ThemeSelection.system,
      );
    }

    ThemeMode mode = _calculateMode(selection, startHour, startMinute, endHour, endMinute);

    return ThemeState(
      selection: selection,
      mode: mode,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
    );
  }

  void _startTimer() {
    _scheduleTimer?.cancel();
    _scheduleTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      checkSchedule();
    });
  }

  ThemeMode _calculateMode(ThemeSelection selection, int sh, int sm, int eh, int em) {
    switch (selection) {
      case ThemeSelection.light:
        return ThemeMode.light;
      case ThemeSelection.dark:
        return ThemeMode.dark;
      case ThemeSelection.system:
        return ThemeMode.system;
      case ThemeSelection.scheduled:
        final now = DateTime.now();
        final currentTime = now.hour * 60 + now.minute;
        final startTime = sh * 60 + sm;
        final endTime = eh * 60 + em;

        bool shouldBeDark;
        if (startTime < endTime) {
          shouldBeDark = currentTime >= startTime && currentTime < endTime;
        } else {
          shouldBeDark = currentTime >= startTime || currentTime < endTime;
        }
        return shouldBeDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> setThemeSelection(ThemeSelection selection) async {
    final newMode =
        _calculateMode(selection, state.startHour, state.startMinute, state.endHour, state.endMinute);
    state = state.copyWith(selection: selection, mode: newMode);
    await _prefs.setString(_keySelection, selection.name);
  }

  Future<void> setScheduleTimes({int? startH, int? startM, int? endH, int? endM}) async {
    final sh = startH ?? state.startHour;
    final sm = startM ?? state.startMinute;
    final eh = endH ?? state.endHour;
    final em = endM ?? state.endMinute;

    ThemeMode newMode = state.mode;
    if (state.selection == ThemeSelection.scheduled) {
      newMode = _calculateMode(ThemeSelection.scheduled, sh, sm, eh, em);
    }

    state = state.copyWith(
      mode: newMode,
      startHour: sh,
      startMinute: sm,
      endHour: eh,
      endMinute: em,
    );

    if (startH != null) await _prefs.setInt(_keyStartHour, startH);
    if (startM != null) await _prefs.setInt(_keyStartMinute, startM);
    if (endH != null) await _prefs.setInt(_keyEndHour, endH);
    if (endM != null) await _prefs.setInt(_keyEndMinute, endM);
  }

  void checkSchedule() {
    if (state.selection == ThemeSelection.scheduled) {
      final newMode = _calculateMode(
          state.selection, state.startHour, state.startMinute, state.endHour, state.endMinute);
      if (state.mode != newMode) {
        state = state.copyWith(mode: newMode);
      }
    }
  }

  bool get isDarkMode => state.mode == ThemeMode.dark;

  // Compatibility methods
  Future<void> toggleTheme(bool isDark) async {
    await setThemeSelection(isDark ? ThemeSelection.dark : ThemeSelection.light);
  }

  Future<void> setScheduled(bool enabled) async {
    await setThemeSelection(enabled ? ThemeSelection.scheduled : ThemeSelection.system);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeState>(() {
  return ThemeNotifier();
});
