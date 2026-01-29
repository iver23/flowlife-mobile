import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) return 'Today';
    if (taskDate == tomorrow) return 'Tomorrow';
    
    // Check if it's within the next 6 days
    if (taskDate.isAfter(today) && taskDate.isBefore(today.add(const Duration(days: 7)))) {
      return DateFormat('EEEE').format(date); // e.g., "Monday"
    }

    return DateFormat('MMM d').format(date); // e.g., "Jan 28"
  }

  static bool isOverdue(DateTime date, bool isCompleted) {
    if (isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    return taskDate.isBefore(today);
  }

  static String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return format(date);
  }
}
