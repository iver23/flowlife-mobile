import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/task_notifier.dart';
import '../../core/project_notifier.dart';
import '../../data/models/models.dart';
import '../widgets/ui_components.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final projectsAsync = ref.watch(projectNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: FlowColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: tasksAsync.when(
        data: (tasks) => projectsAsync.when(
          data: (projects) => _buildBody(context, tasks, projects),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Error loading projects')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading tasks')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<TaskModel> tasks, List<ProjectModel> projects) {
    final completedTasks = tasks.where((t) => t.completed).toList();
    final totalCompleted = completedTasks.length;
    
    // Stats for the last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final dailyCounts = last7Days.map((date) {
      return completedTasks.where((t) {
        if (t.completedAt == null) return false;
        final d = DateTime.fromMillisecondsSinceEpoch(t.completedAt!);
        return d.day == date.day && d.month == date.month && d.year == date.year;
      }).length.toDouble();
    }).toList();

    // Project breakdown
    final projectCounts = <String, int>{};
    for (final t in completedTasks) {
      final pId = t.projectId ?? 'other';
      projectCounts[pId] = (projectCounts[pId] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(totalCompleted, completedTasks),
          const SizedBox(height: 32),
          const Text('LAST 7 DAYS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500, letterSpacing: 1.2)),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: _buildBarChart(dailyCounts)),
          const SizedBox(height: 48),
          const Text('PROJECT BREAKDOWN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500, letterSpacing: 1.2)),
          const SizedBox(height: 24),
          _buildProjectCircles(projects, projectCounts),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(int total, List<TaskModel> completedTasks) {
    return Row(
      children: [
        Expanded(
          child: FlowCard(
            padding: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Completed', style: TextStyle(fontSize: 12, color: FlowColors.slate500)),
                const SizedBox(height: 8),
                Text('$total', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: FlowColors.primary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FlowCard(
            padding: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Focus Score', style: TextStyle(fontSize: 12, color: FlowColors.slate500)),
                const SizedBox(height: 8),
                const Text('84%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<double> counts) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: counts.reduce((a, b) => a > b ? a : b) + 2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Text(days[value.toInt() % 7], style: const TextStyle(color: FlowColors.slate500, fontSize: 10));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(counts.length, (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: counts[i],
              color: FlowColors.primary,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildProjectCircles(List<ProjectModel> projects, Map<String, int> counts) {
    return Column(
      children: projects.map((p) {
        final count = counts[p.id] ?? 0;
        if (count == 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: FlowColors.parseProjectColor(p.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text('$count tasks', style: const TextStyle(color: FlowColors.slate500)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
