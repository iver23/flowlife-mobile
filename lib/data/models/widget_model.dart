import 'package:flutter/material.dart';

enum WidgetType {
  habits,
  tasks,
  projects,
  ideas,
  achievements,
  stats,
  study
}

class DashboardWidgetModel {
  final String id;
  final WidgetType type;
  final String title;
  final bool isEnabled;
  final int order;
  final int gridColumnSpan; // 1 or 2

  DashboardWidgetModel({
    required this.id,
    required this.type,
    required this.title,
    this.isEnabled = true,
    required this.order,
    this.gridColumnSpan = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'title': title,
      'isEnabled': isEnabled,
      'order': order,
      'gridColumnSpan': gridColumnSpan,
    };
  }

  factory DashboardWidgetModel.fromMap(Map<String, dynamic> map, String id) {
    return DashboardWidgetModel(
      id: id,
      type: WidgetType.values.firstWhere((e) => e.name == map['type'], orElse: () => WidgetType.tasks),
      title: map['title'] ?? '',
      isEnabled: map['isEnabled'] ?? true,
      order: map['order'] ?? 0,
      gridColumnSpan: map['gridColumnSpan'] ?? 1,
    );
  }

  DashboardWidgetModel copyWith({
    bool? isEnabled,
    int? order,
    int? gridColumnSpan,
  }) {
    return DashboardWidgetModel(
      id: id,
      type: type,
      title: title,
      isEnabled: isEnabled ?? this.isEnabled,
      order: order ?? this.order,
      gridColumnSpan: gridColumnSpan ?? this.gridColumnSpan,
    );
  }
}
