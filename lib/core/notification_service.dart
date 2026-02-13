import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'app_logger.dart';
import '../data/models/models.dart' hide Importance;
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  /// Try to schedule with exact alarms first, fall back to inexact if not permitted
  static Future<void> _scheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      // Try exact alarm first
      await _notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
      );
      AppLogger.notification('Scheduled notification $id at $scheduledDate (Exact)');
    } catch (e) {
      // If exact alarms not permitted, fall back to inexact
      if (e.toString().contains('exact_alarms_not_permitted')) {
        await _notifications.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: matchDateTimeComponents,
        );
        AppLogger.notification('Scheduled notification $id at $scheduledDate (Inexact fallback)');
      } else {
        // Re-throw other exceptions
        rethrow;
      }
    }
  }

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
    await _scheduleWithFallback(
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
    );
  }

  static Future<void> scheduleDailyRecap(int taskCount) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 8, 0); // 8 AM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _scheduleWithFallback(
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
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleTaskReminder(TaskModel task) async {
    if (!task.reminderEnabled || task.reminderTime == null) return;
    
    final reminderDate = DateTime.fromMillisecondsSinceEpoch(task.reminderTime!);
    if (reminderDate.isBefore(DateTime.now())) return;

    await _scheduleWithFallback(
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
    );
  }

  static Future<void> scheduleProjectNudge(ProjectModel project, int daysSinceVisit) async {
    await _notifications.show(
      id: project.id.hashCode + 1,
      title: 'Project Nudge',
      body: 'You haven\'t visited "${project.title}" in $daysSinceVisit days. Want to check in?',
      notificationDetails: const NotificationDetails(
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
