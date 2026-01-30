import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/task_notifier.dart';
import '../../core/project_notifier.dart';
import '../../core/study_notifier.dart';
import '../../data/models/models.dart';
import '../../data/models/study_models.dart';
import '../widgets/ui_components.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final projectsAsync = ref.watch(projectNotifierProvider);
    final studyState = ref.watch(studyNotifierProvider);

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
          data: (projects) => _buildBody(context, ref, tasks, projects, studyState),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Error loading projects')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading tasks')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, List<TaskModel> tasks, List<ProjectModel> projects, StudyState studyState) {
    final completedTasks = tasks.where((t) => t.completed && t.completedAt != null).toList();
    
    // 1. Calculations
    final avgCompletionTime = _calculateAvgCompletionTime(completedTasks);
    final bestDay = _calculateBestDay(completedTasks);
    final bestHour = _calculateBestHour(completedTasks);
    
    // 2. Data for Charts
    final weeklyTrendData = _getWeeklyTrendData(completedTasks);
    final dayOfWeekData = _getDayOfWeekData(completedTasks);
    final hourlyData = _getHourlyData(completedTasks);
    final projectCounts = _getProjectBreakdown(completedTasks);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Section
          Row(
            children: [
              _buildMetricCard('Avg Time', avgCompletionTime, LucideIcons.timer, Colors.blue),
              const SizedBox(width: 16),
              _buildMetricCard('Best Day', bestDay, LucideIcons.calendarDays, Colors.purple),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard('Peak Hour', bestHour, LucideIcons.clock, Colors.orange),
              const SizedBox(width: 16),
              _buildMetricCard('Completion', '${completedTasks.length}', LucideIcons.checkCircle2, Colors.green),
            ],
          ),

          const SizedBox(height: 48),
          _buildSectionHeader('MONTHLY TREND', 'Tasks completed per week'),
          const SizedBox(height: 24),
          SizedBox(height: 180, child: _buildLineChart(weeklyTrendData)),

          const SizedBox(height: 48),
          _buildSectionHeader('PRODUCTIVITY BY DAY', 'Total completions'),
          const SizedBox(height: 24),
          SizedBox(height: 180, child: _buildDayBarChart(dayOfWeekData)),

          const SizedBox(height: 48),
          _buildSectionHeader('PEAK ACTIVITY HOURS', 'Time of day distribution'),
          const SizedBox(height: 24),
          SizedBox(height: 180, child: _buildHourlyBarChart(hourlyData)),

          const SizedBox(height: 48),
          _buildSectionHeader('PROJECT BREAKDOWN', 'Tasks by category'),
          const SizedBox(height: 24),
          _buildProjectCircles(projects, projectCounts),

          if (studyState.lessons.isNotEmpty) ...[
            const SizedBox(height: 48),
            _buildSectionHeader('STUDY PROGRESS', 'Lessons & Learning'),
            const SizedBox(height: 24),
            _buildStudySummary(studyState),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: FlowColors.slate400)),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: FlowCard(
        padding: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 11, color: FlowColors.slate500, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<double> data) {
    if (data.isEmpty) return const Center(child: Text('No data'));
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                if (val % 1 != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('W${val.toInt() + 1}', style: const TextStyle(color: FlowColors.slate400, fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true,
            color: FlowColors.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: FlowColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayBarChart(List<double> data) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.isEmpty ? 10 : (data.reduce((a, b) => a > b ? a : b) + 2),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) => Text(days[val.toInt() % 7], style: const TextStyle(color: FlowColors.slate500, fontSize: 10)),
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) => BarChartGroupData(
          x: e.key,
          barRods: [BarChartRodData(toY: e.value, color: FlowColors.primary, width: 12, borderRadius: BorderRadius.circular(4))],
        )).toList(),
      ),
    );
  }

  Widget _buildHourlyBarChart(List<double> data) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.isEmpty ? 10 : (data.reduce((a, b) => a > b ? a : b) + 2),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                if (val % 4 != 0) return const SizedBox.shrink();
                return Text('${val.toInt()}h', style: const TextStyle(color: FlowColors.slate500, fontSize: 10));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) => BarChartGroupData(
          x: e.key,
          barRods: [BarChartRodData(toY: e.value, color: Colors.orange.withOpacity(0.8), width: 6, borderRadius: BorderRadius.circular(2))],
        )).toList(),
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
              Container(width: 12, height: 12, decoration: BoxDecoration(color: FlowColors.parseProjectColor(p.color), shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(child: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text('$count tasks', style: const TextStyle(color: FlowColors.slate500, fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStudySummary(StudyState studyState) {
    final completed = studyState.lessons.where((l) => l.isCompleted).length;
    final total = studyState.lessons.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return FlowCard(
      padding: 20,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Lessons Completed', style: TextStyle(fontSize: 13, color: FlowColors.slate500)),
              Text('$completed / $total', style: const TextStyle(fontWeight: FontWeight.bold, color: FlowColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: FlowColors.slate100,
              valueColor: const AlwaysStoppedAnimation<Color>(FlowColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic Helpers ---

  String _calculateAvgCompletionTime(List<TaskModel> tasks) {
    if (tasks.isEmpty) return '--';
    double totalHours = 0;
    int count = 0;
    for (var t in tasks) {
      if (t.completedAt != null) {
        final diff = t.completedAt! - t.createdAt;
        if (diff > 0) {
          totalHours += diff / (1000 * 60 * 60);
          count++;
        }
      }
    }
    if (count == 0) return '--';
    final avg = totalHours / count;
    if (avg < 1) return '${(avg * 60).toInt()}m';
    if (avg < 24) return '${avg.toStringAsFixed(1)}h';
    return '${(avg / 24).toStringAsFixed(1)}d';
  }

  String _calculateBestDay(List<TaskModel> tasks) {
    if (tasks.isEmpty) return '--';
    final counts = List.filled(7, 0);
    for (var t in tasks) {
      final date = DateTime.fromMillisecondsSinceEpoch(t.completedAt!);
      counts[date.weekday - 1]++;
    }
    int maxIdx = 0;
    for (int i = 1; i < 7; i++) {
      if (counts[i] > counts[maxIdx]) maxIdx = i;
    }
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[maxIdx];
  }

  String _calculateBestHour(List<TaskModel> tasks) {
    if (tasks.isEmpty) return '--';
    final counts = List.filled(24, 0);
    for (var t in tasks) {
      final date = DateTime.fromMillisecondsSinceEpoch(t.completedAt!);
      counts[date.hour]++;
    }
    int maxIdx = 0;
    for (int i = 1; i < 24; i++) {
      if (counts[i] > counts[maxIdx]) maxIdx = i;
    }
    return '${maxIdx}:00';
  }

  List<double> _getWeeklyTrendData(List<TaskModel> tasks) {
    final now = DateTime.now();
    final weeklyCounts = List.filled(4, 0.0);
    for (var t in tasks) {
      final date = DateTime.fromMillisecondsSinceEpoch(t.completedAt!);
      final diff = now.difference(date).inDays;
      if (diff < 28) {
        final weekIdx = 3 - (diff ~/ 7);
        if (weekIdx >= 0) weeklyCounts[weekIdx]++;
      }
    }
    return weeklyCounts;
  }

  List<double> _getDayOfWeekData(List<TaskModel> tasks) {
    final counts = List.filled(7, 0.0);
    for (var t in tasks) {
      final date = DateTime.fromMillisecondsSinceEpoch(t.completedAt!);
      counts[date.weekday - 1]++;
    }
    return counts;
  }

  List<double> _getHourlyData(List<TaskModel> tasks) {
    final counts = List.filled(24, 0.0);
    for (var t in tasks) {
      final date = DateTime.fromMillisecondsSinceEpoch(t.completedAt!);
      counts[date.hour]++;
    }
    return counts;
  }

  Map<String, int> _getProjectBreakdown(List<TaskModel> tasks) {
    final counts = <String, int>{};
    for (var t in tasks) {
      final pId = t.projectId ?? 'other';
      counts[pId] = (counts[pId] ?? 0) + 1;
    }
    return counts;
  }
}
