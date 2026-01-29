import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers.dart';
import '../../core/task_notifier.dart';
import '../../core/project_notifier.dart';
import '../../data/models/models.dart';
import '../widgets/ui_components.dart';
import '../widgets/task_card.dart';
import '../widgets/task_edit_sheet.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final projectsAsync = ref.watch(projectNotifierProvider);
    final taskNotifier = ref.read(taskNotifierProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: tasksAsync.when(
                data: (tasks) {
                  final activeTasks = tasks.where((t) => !t.completed).toList();
                  if (activeTasks.isEmpty) {
                    return _buildEmptyState();
                  }

                  return projectsAsync.when(
                    data: (projects) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: activeTasks.length,
                        itemBuilder: (context, index) {
                          final task = activeTasks[index];
                          final project = task.projectId != null 
                              ? projects.firstWhere((p) => p.id == task.projectId, orElse: () => _defaultProject())
                              : _defaultProject();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
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
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(LucideIcons.checkSquare, color: FlowColors.slate500),
          Text(
            'Active Tasks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.checkCircle2, size: 64, color: FlowColors.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text(
            'No active tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enjoy your free time!',
            style: TextStyle(color: FlowColors.slate500),
          ),
        ],
      ),
    );
  }

  ProjectModel _defaultProject() {
    return ProjectModel(
      id: '',
      title: 'Inbox',
      color: 'blue',
      icon: 'inbox',
      weight: Importance.medium,
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
