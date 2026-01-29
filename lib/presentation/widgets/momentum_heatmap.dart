import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/models.dart';
import 'ui_components.dart';

class MomentumHeatmap extends StatelessWidget {
  final List<TaskModel> tasks;

  const MomentumHeatmap({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final heatmapData = _generateHeatmapData();

    return FlowCard(
      padding: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.trendingUp, size: 16, color: FlowColors.primary),
              const SizedBox(width: 8),
              Text(
                '30-DAY MOMENTUM',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : FlowColors.textLight,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: heatmapData.map((day) => _buildHeatBox(context, day)).toList(),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('30 Days Ago', style: TextStyle(fontSize: 10, color: FlowColors.slate500)),
              Text('Today', style: TextStyle(fontSize: 10, color: FlowColors.slate500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatBox(BuildContext context, _HeatmapDay day) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color color;

    if (day.count == 0) {
      color = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!;
    } else if (day.count < 3) {
      color = isDark ? FlowColors.primaryDark.withOpacity(0.3) : FlowColors.primary.withOpacity(0.2);
    } else if (day.count < 5) {
      color = isDark ? FlowColors.primaryDark.withOpacity(0.6) : FlowColors.primary.withOpacity(0.5);
    } else {
      color = isDark ? FlowColors.primaryDark : FlowColors.primary;
    }

    return Tooltip(
      message: '${day.date.day}/${day.date.month}: ${day.count} tasks',
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  List<_HeatmapDay> _generateHeatmapData() {
    final List<_HeatmapDay> data = [];
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    for (int i = 29; i >= 0; i--) {
      final date = normalizedToday.subtract(Duration(days: i));
      final count = tasks.where((t) {
        if (!t.completed || t.completedAt == null) return false;
        final cDate = DateTime.fromMillisecondsSinceEpoch(t.completedAt!);
        return cDate.year == date.year && cDate.month == date.month && cDate.day == date.day;
      }).length;
      data.add(_HeatmapDay(date: date, count: count));
    }
    return data;
  }
}

class _HeatmapDay {
  final DateTime date;
  final int count;
  _HeatmapDay({required this.date, required this.count});
}
