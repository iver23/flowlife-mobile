import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderSettings {
  final bool smartRemindersEnabled;
  final bool morningBriefingEnabled;
  final bool projectNudgesEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;

  ReminderSettings({
    this.smartRemindersEnabled = true,
    this.morningBriefingEnabled = true,
    this.projectNudgesEnabled = true,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 7, minute: 0),
  });

  ReminderSettings copyWith({
    bool? smartRemindersEnabled,
    bool? morningBriefingEnabled,
    bool? projectNudgesEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) {
    return ReminderSettings(
      smartRemindersEnabled: smartRemindersEnabled ?? this.smartRemindersEnabled,
      morningBriefingEnabled: morningBriefingEnabled ?? this.morningBriefingEnabled,
      projectNudgesEnabled: projectNudgesEnabled ?? this.projectNudgesEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

class ReminderSettingsNotifier extends Notifier<ReminderSettings> {
  late SharedPreferences _prefs;

  @override
  ReminderSettings build() {
    _init();
    return ReminderSettings();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    state = ReminderSettings(
      smartRemindersEnabled: _prefs.getBool('smartRemindersEnabled') ?? true,
      morningBriefingEnabled: _prefs.getBool('morningBriefingEnabled') ?? true,
      projectNudgesEnabled: _prefs.getBool('projectNudgesEnabled') ?? true,
      quietHoursStart: TimeOfDay(
        hour: _prefs.getInt('quietHoursStartHour') ?? 22,
        minute: _prefs.getInt('quietHoursStartMin') ?? 0,
      ),
      quietHoursEnd: TimeOfDay(
        hour: _prefs.getInt('quietHoursEndHour') ?? 7,
        minute: _prefs.getInt('quietHoursEndMin') ?? 0,
      ),
    );
  }

  Future<void> toggleSmartReminders(bool value) async {
    await _prefs.setBool('smartRemindersEnabled', value);
    state = state.copyWith(smartRemindersEnabled: value);
  }

  Future<void> toggleMorningBriefing(bool value) async {
    await _prefs.setBool('morningBriefingEnabled', value);
    state = state.copyWith(morningBriefingEnabled: value);
  }

  Future<void> toggleProjectNudges(bool value) async {
    await _prefs.setBool('projectNudgesEnabled', value);
    state = state.copyWith(projectNudgesEnabled: value);
  }

  Future<void> setQuietHours(TimeOfDay start, TimeOfDay end) async {
    await _prefs.setInt('quietHoursStartHour', start.hour);
    await _prefs.setInt('quietHoursStartMin', start.minute);
    await _prefs.setInt('quietHoursEndHour', end.hour);
    await _prefs.setInt('quietHoursEndMin', end.minute);
    state = state.copyWith(quietHoursStart: start, quietHoursEnd: end);
  }
}

final reminderSettingsProvider = NotifierProvider<ReminderSettingsNotifier, ReminderSettings>(() {
  return ReminderSettingsNotifier();
});
