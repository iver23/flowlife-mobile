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
    
    final energyCounts = _calculateEnergyCounts();
    final total = energyCounts.values.fold(0, (sum, val) => sum + val);

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
                    sections: _buildSections(energyCounts, total, isDark),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // Legend
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem('High', energyCounts[EnergyLevel.HIGH] ?? 0, Colors.amber),
                    const SizedBox(height: 8),
                    _buildLegendItem('Medium', energyCounts[EnergyLevel.MEDIUM] ?? 0, Colors.blue),
                    const SizedBox(height: 8),
                    _buildLegendItem('Low', energyCounts[EnergyLevel.LOW] ?? 0, FlowColors.slate400),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<EnergyLevel, int> _calculateEnergyCounts() {
    final Map<EnergyLevel, int> counts = {
      EnergyLevel.HIGH: 0,
      EnergyLevel.MEDIUM: 0,
      EnergyLevel.LOW: 0,
    };

    for (var task in tasks) {
      if (task.energyLevel != null) {
        counts[task.energyLevel!] = (counts[task.energyLevel!] ?? 0) + 1;
      }
    }
    return counts;
  }

  List<PieChartSectionData> _buildSections(Map<EnergyLevel, int> counts, int total, bool isDark) {
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
        color: Colors.amber,
        value: (counts[EnergyLevel.HIGH] ?? 0).toDouble(),
        radius: 12,
        showTitle: false,
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: (counts[EnergyLevel.MEDIUM] ?? 0).toDouble(),
        radius: 12,
        showTitle: false,
      ),
      PieChartSectionData(
        color: FlowColors.slate400,
        value: (counts[EnergyLevel.LOW] ?? 0).toDouble(),
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
