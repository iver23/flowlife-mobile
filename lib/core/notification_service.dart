import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../data/models/models.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // flutter_local_notifications 20.x: all positional params are now named
    await _notifications.initialize(
      settings: settings,
    );
    tz.initializeTimeZones();
  }

  static Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledDate) async {
    // flutter_local_notifications 20.x: zonedSchedule uses named parameters
    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'flow_channel',
          'FlowLife Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleDailyRecap(int taskCount) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 8, 0); // 8 AM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id: 999,
      title: 'Good Morning!',
      body: 'You have $taskCount tasks to focus on today.',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'recap_channel',
          'Daily Recap',
          importance: Importance.low,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleTaskReminder(TaskModel task) async {
    if (!task.reminderEnabled || task.reminderTime == null) return;
    
    final reminderDate = DateTime.fromMillisecondsSinceEpoch(task.reminderTime!);
    if (reminderDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id: task.id.hashCode,
      title: 'Task Reminder',
      body: task.title,
      scheduledDate: tz.TZDateTime.from(reminderDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleProjectNudge(ProjectModel project, int daysSinceVisit) async {
    await _notifications.show(
      project.id.hashCode + 1,
      'Project Nudge',
      'You haven\'t visited "${project.title}" in $daysSinceVisit days. Want to check in?',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'project_nudges',
          'Project Nudges',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static bool isQuietHours(TimeOfDay start, TimeOfDay end) {
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;

    if (startMin <= endMin) {
      return nowMin >= startMin && nowMin <= endMin;
    } else {
      // Overnight (e.g., 22:00 to 07:00)
      return nowMin >= startMin || nowMin <= endMin;
    }
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
