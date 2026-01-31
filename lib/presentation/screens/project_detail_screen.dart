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
      extendBody: true,
      body: tasksAsync.when(
        data: (tasks) {
          final projectTasks = tasks.where((t) => t.projectId == project.id).toList();
          
          projectTasks.sort((a, b) {
            if (a.isPinned && !b.isPinned) return -1;
            if (!a.isPinned && b.isPinned) return 1;
            if (a.order != null && b.order != null) return a.order!.compareTo(b.order!);
            return b.createdAt.compareTo(a.createdAt);
          });

          final completedCount = projectTasks.where((t) => t.completed).length;
          final progress = projectTasks.isEmpty ? 0.0 : completedCount / projectTasks.length;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, ref),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    children: [
                      _buildProgressCard(context, progress, completedCount, projectTasks.length),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TASKS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              color: FlowColors.slate400,
                            ),
                          ),
                          FlowBadge(
                            label: 'IN PROGRESS',
                            color: FlowColors.parseProjectColor(project.color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverReorderableList(
                itemCount: projectTasks.length,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = projectTasks.removeAt(oldIndex);
                  projectTasks.insert(newIndex, item);
                  taskNotifier.reorderTasks(projectTasks);
                },
                itemBuilder: (context, index) {
                  final task = projectTasks[index];
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(task.id),
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: TaskCard(
                        task: task,
                        projectTitle: project.title,
                        projectIcon: project.icon,
                        projectColor: FlowColors.parseProjectColor(project.color),
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
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildAddTaskButton(context, ref),
                      const SizedBox(height: 120),
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
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildActionCircle(LucideIcons.chevronLeft, () => Navigator.pop(context)),
      ),
      title: Text(
        project.title,
        style: TextStyle(
          color: isDark ? Colors.white : FlowColors.textLight,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildActionCircle(LucideIcons.trash2, () => _confirmDelete(context, ref), color: Colors.red.withOpacity(0.8)),
        ),
      ],
      centerTitle: true,
    );
  }

  Widget _buildActionCircle(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: FlowColors.surfaceDark.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color ?? FlowColors.slate500),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, double progress, int completed, int total) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final projectColor = FlowColors.parseProjectColor(project.color);
    
    return FlowCard(
      useGlass: true,
      padding: 24,
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: isDark ? Colors.white.withOpacity(0.05) : FlowColors.slate100,
                  valueColor: AlwaysStoppedAnimation<Color>(projectColor),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completed / $total Tasks',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Current project progress',
                  style: TextStyle(fontSize: 12, color: FlowColors.slate400, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context, WidgetRef ref) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => TaskEditSheet(
            task: TaskModel(
              id: '',
              title: '',
              completed: false,
              subtasks: [],
              createdAt: DateTime.now().millisecondsSinceEpoch,
              projectId: project.id,
            ),
            onSave: (task) => ref.read(taskNotifierProvider.notifier).addTask(task),
          ),
        );
      },
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : FlowColors.slate200,
            width: 1,
          ),
          color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : FlowColors.slate50,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.plus, size: 20, color: FlowColors.slate400),
            ),
            const SizedBox(width: 16),
            const Text(
              'Add a new task',
              style: TextStyle(
                fontSize: 15,
                color: FlowColors.slate400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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
}
