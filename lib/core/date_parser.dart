class DateParser {
  static Map<String, dynamic> parse(String text) {
    final lower = text.toLowerCase();
    final today = DateTime.now();
    DateTime? date;
    String cleanText = text;

    // Tomorrow
    if (lower.contains('tomorrow')) {
      date = today.add(const Duration(days: 1));
      cleanText = text.replaceAll(RegExp(r'tomorrow', caseSensitive: false), '').trim();
    }
    // Today / Tonight
    else if (lower.contains('today') || lower.contains('tonight')) {
      date = today;
      cleanText = text.replaceAll(RegExp(r'today|tonight', caseSensitive: false), '').trim();
    }
    // Next week
    else if (lower.contains('next week')) {
      date = today.add(const Duration(days: 7));
      cleanText = text.replaceAll(RegExp(r'next week', caseSensitive: false), '').trim();
    }
    // Monday, Tuesday, etc. (Simple next-occurrence)
    else {
      final days = {
        'monday': DateTime.monday,
        'tuesday': DateTime.tuesday,
        'wednesday': DateTime.wednesday,
        'thursday': DateTime.thursday,
        'friday': DateTime.friday,
        'saturday': DateTime.saturday,
        'sunday': DateTime.sunday,
      };

      for (var entry in days.entries) {
        if (lower.contains(entry.key)) {
          int daysUntil = entry.value - today.weekday;
          if (daysUntil <= 0) daysUntil += 7;
          date = today.add(Duration(days: daysUntil));
          cleanText = text.replaceAll(RegExp(entry.key, caseSensitive: false), '').trim();
          break;
        }
      }
    }

    return {
      'cleanText': cleanText,
      'date': date,
    };
  }
}
