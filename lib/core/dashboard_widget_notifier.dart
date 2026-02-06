import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/widget_model.dart';
import '../data/services/firestore_service.dart';
import 'providers.dart';

class DashboardWidgetNotifier extends AsyncNotifier<List<DashboardWidgetModel>> {
  FirestoreService get _service => ref.watch(firestoreServiceProvider);

  @override
  FutureOr<List<DashboardWidgetModel>> build() async {
    final stream = _service.streamDashboardWidgets();
    
    stream.listen((widgets) {
      if (widgets.isEmpty) {
        _initializeDefaultWidgets();
      } else {
        // Migration: ensure study widget exists for existing users
        final hasStudy = widgets.any((w) => w.type == WidgetType.study);
        if (!hasStudy) {
          _addMissingStudyWidget(widgets);
        } else {
          state = AsyncData(widgets);
        }
      }
    });

    return stream.first;
  }

  Future<void> _addMissingStudyWidget(List<DashboardWidgetModel> existingWidgets) async {
    // Find the tasks widget to place study after it
    final tasksWidget = existingWidgets.firstWhere(
      (w) => w.type == WidgetType.tasks,
      orElse: () => existingWidgets.last,
    );
    final insertOrder = tasksWidget.order + 1;
    
    // Shift all widgets after tasks down by 1
    for (final w in existingWidgets.where((w) => w.order >= insertOrder)) {
      await _service.updateWidget(w.copyWith(order: w.order + 1));
    }
    
    // Add the study widget
    await _service.initializeWidgets([
      DashboardWidgetModel(id: 'study', type: WidgetType.study, title: 'Study Progress', order: insertOrder, gridColumnSpan: 2),
    ]);
  }

  Future<void> _initializeDefaultWidgets() async {
    final defaults = [
      DashboardWidgetModel(id: 'stats', type: WidgetType.stats, title: 'Growth Highlights', order: 0, gridColumnSpan: 2),
      DashboardWidgetModel(id: 'habits', type: WidgetType.habits, title: 'Habit Streaks', order: 1, gridColumnSpan: 1),
      DashboardWidgetModel(id: 'tasks', type: WidgetType.tasks, title: 'Today\'s Focus', order: 2, gridColumnSpan: 1),
      DashboardWidgetModel(id: 'projects', type: WidgetType.projects, title: 'Active Projects', order: 3, gridColumnSpan: 2),
      DashboardWidgetModel(id: 'study', type: WidgetType.study, title: 'Study Progress', order: 4, gridColumnSpan: 2),
    ];
    await _service.initializeWidgets(defaults);
  }

  Future<void> toggleWidget(String id, bool isEnabled) async {
    final widget = state.value?.firstWhere((w) => w.id == id);
    if (widget != null) {
      await _service.updateWidget(widget.copyWith(isEnabled: isEnabled));
    }
  }

  Future<void> reorderWidgets(int oldIndex, int newIndex) async {
    final widgets = List<DashboardWidgetModel>.from(state.value ?? []);
    if (oldIndex < newIndex) newIndex -= 1;
    final item = widgets.removeAt(oldIndex);
    widgets.insert(newIndex, item);

    for (int i = 0; i < widgets.length; i++) {
      await _service.updateWidget(widgets[i].copyWith(order: i));
    }
  }
}

final dashboardWidgetProvider = AsyncNotifierProvider<DashboardWidgetNotifier, List<DashboardWidgetModel>>(() {
  return DashboardWidgetNotifier();
});
