import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/task_notifier.dart';
import '../../core/project_notifier.dart';
import '../../data/models/models.dart';
import '../widgets/ui_components.dart';
import '../widgets/task_card.dart';
import '../widgets/task_edit_sheet.dart';
import '../widgets/task_detail_sheet.dart';
import '../widgets/project_edit_sheet.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final taskNotifier = ref.read(taskNotifierProvider.notifier);
    
    // Watch project state to stay reactive to edits
    final projectState = ref.watch(projectNotifierProvider);
    final currentProject = projectState.whenOrNull(
      data: (projects) => projects.firstWhere((p) => p.id == project.id, orElse: () => project),
    ) ?? project;

    return Scaffold(
      extendBody: true,
      body: tasksAsync.when(
        data: (tasks) {
          final projectTasks = tasks.where((t) => t.projectId == project.id).toList();
          
          projectTasks.sort((a, b) {
            // 1. Completed tasks go to bottom
            if (a.completed != b.completed) return a.completed ? 1 : -1;
            // 2. Pinned tasks float to top (within their group)
            if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
            // 3. Sort by urgency (higher value = more urgent = top)
            if (a.urgencyLevel != b.urgencyLevel) {
              return b.urgencyLevel.value.compareTo(a.urgencyLevel.value);
            }
            // 4. Fall back to manual order, then creation date
            if (a.order != null && b.order != null) return a.order!.compareTo(b.order!);
            return b.createdAt.compareTo(a.createdAt);
          });

          final completedCount = projectTasks.where((t) => t.completed).length;
          final progress = projectTasks.isEmpty ? 0.0 : completedCount / projectTasks.length;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, ref, currentProject),
              // Description section (only if exists)
              if (currentProject.description?.isNotEmpty ?? false)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Text(
                      currentProject.description!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white.withValues(alpha: 0.5) : FlowColors.slate500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final elevate = FlowAnimations.defaultCurve.transform(animation.value);
                      return Material(
                        elevation: 8 * elevate,
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(28),
                        child: child!,
                      );
                    },
                    child: child,
                  );
                },
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
                        onDelete: () => taskNotifier.deleteTask(task),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => TaskDetailSheet(task: task),
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

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref, ProjectModel currentProject) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildActionCircle(LucideIcons.chevronLeft, () => Navigator.pop(context)),
      ),
      title: Text(
        currentProject.title,
        style: TextStyle(
          color: isDark ? Colors.white : FlowColors.textLight,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        if (!currentProject.isSystemProject) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildActionCircle(LucideIcons.edit3, () => _showEditProject(context, ref, currentProject)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 16.0),
            child: _buildActionCircle(LucideIcons.trash2, () => _confirmDelete(context, ref, currentProject), color: Colors.red.withValues(alpha: 0.8)),
          ),
        ],
      ],
    );
  }

  void _showEditProject(BuildContext context, WidgetRef ref, ProjectModel currentProject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectEditSheet(
        project: currentProject,
        onSave: (updatedProject) {
          ref.read(projectNotifierProvider.notifier).updateProject(updatedProject);
        },
      ),
    );
  }

  Widget _buildActionCircle(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: FlowColors.surfaceDark.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color ?? FlowColors.slate500),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, double progress, int completed, int total) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final projectColor = FlowColors.parseProjectColor(project.color);
    final tintedBg = FlowColors.getTintedBackground(projectColor, isDark);
    final textColor = FlowColors.getContrastTextColor(tintedBg);
    final secondaryColor = FlowColors.getContrastSecondaryColor(tintedBg);
    
    return FlowCard(
      useGlass: true,
      backgroundColor: tintedBg,
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
                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : FlowColors.slate100,
                  valueColor: AlwaysStoppedAnimation<Color>(projectColor),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
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
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current project progress',
                  style: TextStyle(
                    fontSize: 12, 
                    color: secondaryColor, 
                    fontWeight: FontWeight.w500,
                  ),
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
            color: isDark ? Colors.white.withValues(alpha: 0.08) : FlowColors.slate200,
            width: 1,
          ),
          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : FlowColors.slate50,
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

  void _confirmDelete(BuildContext context, WidgetRef ref, ProjectModel currentProject) {
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
              ref.read(projectNotifierProvider.notifier).deleteProject(currentProject);
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
