import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../data/models/models.dart';
import '../../presentation/widgets/ui_components.dart';

class WidgetService {
  static const String _groupId = 'HomeWidgetPreferences'; // Shared with native
  static const String _widgetName = 'FlowLifeWidget';
  
  static Future<void> updateWidget({
    required List<TaskModel> tasks,
    required List<ProjectModel> projects,
  }) async {
    // 1. Filter incomplete tasks (Today's + Undated)
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final filteredTasks = tasks.where((t) {
      if (t.completed) return false;
      if (t.dueDate == null) return true; // Include undated
      
      return t.dueDate!.isBefore(todayEnd); // Include today and overdue
    }).toList();

    // Sort: Today's tasks first, then by creation date
    filteredTasks.sort((a, b) {
      if (a.dueDate != null && b.dueDate == null) return -1;
      if (a.dueDate == null && b.dueDate != null) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });

    final displayTasks = filteredTasks.take(3).toList();

    // 2. Map to simplified JSON for the native widget
    final tasksData = displayTasks.map((t) {
      final project = projects.firstWhere((p) => p.id == t.projectId, orElse: () => ProjectModel(
        id: 'other', 
        title: 'Other', 
        color: 'blue', 
        icon: 'work', 
        weight: Importance.low
      ));
      
      // Convert project color name to hex
      String hex = '#64748B'; // Default slate
      try {
        final color = FlowColors.parseProjectColor(project.color);
        hex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
      } catch (_) {}

      return {
        'title': t.title,
        'color': hex,
      };
    }).toList();

    // 3. Save to shared preferences
    await HomeWidget.saveWidgetData<String>('today_tasks', jsonEncode(tasksData));
    
    // 4. Trigger widget update
    await HomeWidget.updateWidget(
      name: _widgetName,
      androidName: _widgetName,
    );
  }
}
