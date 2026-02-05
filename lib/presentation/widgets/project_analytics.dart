import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/models.dart';
import 'ui_components.dart';

class ProjectAnalytics extends StatelessWidget {
  final List<TaskModel> tasks;

  const ProjectAnalytics({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final urgencyCounts = _calculateUrgencyCounts();
    final total = urgencyCounts.values.fold(0, (sum, val) => sum + val);

    return FlowCard(
      padding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROJECT BREAKDOWN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: FlowColors.slate500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Pie Chart
              SizedBox(
                height: 120,
                width: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: _buildSections(urgencyCounts, total, isDark),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // Legend
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem('Critical', urgencyCounts[UrgencyLevel.critical] ?? 0, Color(UrgencyLevel.critical.colorValue)),
                    const SizedBox(height: 8),
                    _buildLegendItem('Urgent', urgencyCounts[UrgencyLevel.urgent] ?? 0, Color(UrgencyLevel.urgent.colorValue)),
                    const SizedBox(height: 8),
                    _buildLegendItem('Moderate', urgencyCounts[UrgencyLevel.moderate] ?? 0, Color(UrgencyLevel.moderate.colorValue)),
                    const SizedBox(height: 8),
                    _buildLegendItem('Low', urgencyCounts[UrgencyLevel.low] ?? 0, Color(UrgencyLevel.low.colorValue)),
                    const SizedBox(height: 8),
                    _buildLegendItem('Planning', urgencyCounts[UrgencyLevel.planning] ?? 0, Color(UrgencyLevel.planning.colorValue)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<UrgencyLevel, int> _calculateUrgencyCounts() {
    final Map<UrgencyLevel, int> counts = {
      UrgencyLevel.critical: 0,
      UrgencyLevel.urgent: 0,
      UrgencyLevel.moderate: 0,
      UrgencyLevel.low: 0,
      UrgencyLevel.planning: 0,
    };

    for (var task in tasks) {
      counts[task.urgencyLevel] = (counts[task.urgencyLevel] ?? 0) + 1;
    }
    return counts;
  }

  List<PieChartSectionData> _buildSections(Map<UrgencyLevel, int> counts, int total, bool isDark) {
    if (total == 0) {
      return [
        PieChartSectionData(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!,
          value: 1,
          radius: 12,
          showTitle: false,
        )
      ];
    }

    return [
      PieChartSectionData(
        color: Color(UrgencyLevel.critical.colorValue),
        value: (counts[UrgencyLevel.critical] ?? 0).toDouble(),
        radius: 12,
        showTitle: false,
      ),
      PieChartSectionData(
        color: Color(UrgencyLevel.urgent.colorValue),
        value: (counts[UrgencyLevel.urgent] ?? 0).toDouble(),
        radius: 12,
        showTitle: false,
      ),
      PieChartSectionData(
        color: Color(UrgencyLevel.moderate.colorValue),
        value: (counts[UrgencyLevel.moderate] ?? 0).toDouble(),
        radius: 12,
        showTitle: false,
      ),
      PieChartSectionData(
        color: Color(UrgencyLevel.low.colorValue),
        value: (counts[UrgencyLevel.low] ?? 0).toDouble(),
        radius: 12,
        showTitle: false,
      ),
      PieChartSectionData(
        color: Color(UrgencyLevel.planning.colorValue),
        value: (counts[UrgencyLevel.planning] ?? 0).toDouble(),
        radius: 12,
        showTitle: false,
      ),
    ];
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 12, color: FlowColors.slate500),
        ),
      ],
    );
  }
}
