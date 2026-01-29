import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ThemeMode mode;
  final bool isScheduled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  ThemeState({
    required this.mode,
    this.isScheduled = false,
    this.startHour = 22,
    this.startMinute = 0,
    this.endHour = 7,
    this.endMinute = 0,
  });

  ThemeState copyWith({
    ThemeMode? mode,
    bool? isScheduled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      isScheduled: isScheduled ?? this.isScheduled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const _keyMode = 'theme_mode';
  static const _keyScheduled = 'theme_scheduled';
  static const _keyStartHour = 'theme_start_hour';
  static const _keyStartMinute = 'theme_start_minute';
  static const _keyEndHour = 'theme_end_hour';
  static const _keyEndMinute = 'theme_end_minute';

  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(ThemeState(mode: ThemeMode.system)) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedMode = _prefs.getString(_keyMode);
    final isScheduled = _prefs.getBool(_keyScheduled) ?? false;
    final startHour = _prefs.getInt(_keyStartHour) ?? 22;
    final startMinute = _prefs.getInt(_keyStartMinute) ?? 0;
    final endHour = _prefs.getInt(_keyEndHour) ?? 7;
    final endMinute = _prefs.getInt(_keyEndMinute) ?? 0;

    ThemeMode mode = ThemeMode.system;
    if (savedMode != null) {
      mode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedMode,
        orElse: () => ThemeMode.system,
      );
    }

    state = ThemeState(
      mode: mode,
      isScheduled: isScheduled,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
    );

    if (isScheduled) {
      _checkSchedule();
    }
  }

  void _checkSchedule() {
    if (!state.isScheduled) return;

    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;
    final startTime = state.startHour * 60 + state.startMinute;
    final endTime = state.endHour * 60 + state.endMinute;

    bool shouldBeDark;
    if (startTime < endTime) {
      shouldBeDark = currentTime >= startTime && currentTime < endTime;
    } else {
      // Over midnight
      shouldBeDark = currentTime >= startTime || currentTime < endTime;
    }

    final targetMode = shouldBeDark ? ThemeMode.dark : ThemeMode.light;
    if (state.mode != targetMode) {
      state = state.copyWith(mode: targetMode);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode, isScheduled: false);
    await _prefs.setString(_keyMode, mode.toString());
    await _prefs.setBool(_keyScheduled, false);
  }

  Future<void> setScheduled(bool enabled, {int? startH, int? startM, int? endH, int? endM}) async {
    state = state.copyWith(
      isScheduled: enabled,
      startHour: startH,
      startMinute: startM,
      endHour: endH,
      endMinute: endM,
    );
    await _prefs.setBool(_keyScheduled, enabled);
    if (startH != null) await _prefs.setInt(_keyStartHour, startH);
    if (startM != null) await _prefs.setInt(_keyStartMinute, startM);
    if (endH != null) await _prefs.setInt(_keyEndHour, endH);
    if (endM != null) await _prefs.setInt(_keyEndMinute, endM);
    
    if (enabled) {
      _checkSchedule();
    }
  }

  bool get isDarkMode => state.mode == ThemeMode.dark;

  Future<void> toggleTheme(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});
