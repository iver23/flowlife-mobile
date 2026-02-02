import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

    // flutter_local_notifications 20.x: zonedSchedule uses named parameters
    await _notifications.zonedSchedule(
      id: 999, // Constant ID for daily recap
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

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
