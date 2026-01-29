import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/task_notifier.dart';
import '../../core/project_notifier.dart';
import '../../data/models/models.dart';
import '../widgets/ui_components.dart';
import '../widgets/task_card.dart';
import '../widgets/task_edit_sheet.dart';
import '../widgets/project_analytics.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final taskNotifier = ref.read(taskNotifierProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: tasksAsync.when(
          data: (tasks) {
            final projectTasks = tasks.where((t) => t.projectId == project.id).toList();
            // Sort by order or createdAt
            projectTasks.sort((a, b) {
              if (a.order != null && b.order != null) {
                return a.order!.compareTo(b.order!);
              }
              return b.createdAt.compareTo(a.createdAt);
            });

            final completedCount = projectTasks.where((t) => t.completed).length;
            final progress = projectTasks.isEmpty ? 0.0 : completedCount / projectTasks.length;

            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, ref),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildProgressCard(context, progress, completedCount, projectTasks.length)),
                                  const SizedBox(width: 24),
                                  Expanded(child: ProjectAnalytics(tasks: projectTasks)),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                _buildProgressCard(context, progress, completedCount, projectTasks.length),
                                const SizedBox(height: 16),
                                ProjectAnalytics(tasks: projectTasks),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TASKS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: FlowColors.slate500,
                              ),
                            ),
                            FlowBadge(
                              label: 'ACTIVE',
                              color: FlowColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = projectTasks[index];
                      return Padding(
                        key: ValueKey(task.id),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        child: TaskCard(
                          task: task,
                          projectIcon: project.icon,
                          projectColor: _parseColor(project.color),
                          onToggle: () => taskNotifier.toggleTask(task),
                          onDelete: () => taskNotifier.deleteTask(task.id),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => TaskEditSheet(
                                task: task,
                                onSave: (updatedTask) => taskNotifier.updateTask(updatedTask),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: projectTasks.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildAddTaskButton(context),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.chevronLeft, color: FlowColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        project.title,
        style: const TextStyle(
          color: FlowColors.textLight, // Theme will handle this via outfit
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
          onPressed: () => _confirmDelete(context, ref),
        ),
      ],
      centerTitle: true,
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project?'),
        content: const Text('This will delete the project and all its tasks. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              ref.read(projectNotifierProvider.notifier).deleteProject(project.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to dashboard
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, double progress, int completed, int total) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return FlowCard(
      padding: 32,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? FlowColors.primaryDark : FlowColors.primary
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'COMPLETE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: FlowColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '$completed of $total tasks completed',
            style: const TextStyle(
              fontSize: 14,
              color: FlowColors.slate500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        // TODO: Open Add Task Sheet for this project
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid, // Flutter doesn't have dashed border easily without package
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.plus, size: 20, color: FlowColors.slate500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to add a new task',
              style: TextStyle(
                fontSize: 12,
                color: FlowColors.slate500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorStr) {
    switch (colorStr.toLowerCase()) {
      case 'emerald': return Colors.green;
      case 'blue': return Colors.blue;
      case 'violet': return Colors.purple;
      case 'rose': return Colors.pink;
      case 'amber': return Colors.amber;
      case 'cyan': return Colors.cyan;
      default: return FlowColors.primary;
    }
  }
}
