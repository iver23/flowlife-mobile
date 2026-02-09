import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers.dart';
import '../../core/task_notifier.dart';
import '../widgets/ui_components.dart';
import '../widgets/task_card.dart';
import '../widgets/task_edit_sheet.dart';
import '../../data/models/models.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final taskNotifier = ref.read(taskNotifierProvider.notifier);
    final textController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSummaryCard(tasksAsync),
            _buildCaptureInput(context, taskNotifier, textController),
            Expanded(
              child: tasksAsync.when(
                data: (tasks) {
                  final inboxTasks = tasks.where((t) => t.projectId == null).toList();
                  if (inboxTasks.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: inboxTasks.length,
                    itemBuilder: (context, index) {
                      final task = inboxTasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskCard(
                          task: task,
                          projectTitle: 'Inbox',
                          projectIcon: 'inbox',
                          projectColor: FlowColors.primary,
                          onToggle: () => taskNotifier.toggleTask(task),
                          onDelete: () => taskNotifier.deleteTask(task),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(LucideIcons.layoutGrid, color: FlowColors.slate500),
          const Text(
            'Inbox',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.search, color: FlowColors.slate500),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AsyncValue<List<TaskModel>> tasksAsync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: FlowCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: FlowColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'UNASSIGNED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: FlowColors.slate500,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                tasksAsync.when(
                  data: (tasks) {
                    final count = tasks.where((t) => t.projectId == null).length;
                    return Text(
                      '$count tasks',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    );
                  },
                  loading: () => const Text('...', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  error: (_, __) => const Text('Error', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: FlowColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(LucideIcons.inbox, size: 32, color: FlowColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureInput(BuildContext context, TaskNotifier notifier, TextEditingController controller) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? FlowColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    notifier.addTask(TaskModel(
                      id: '',
                      title: value,
                      completed: false,
                      subtasks: [],
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                    ));
                    controller.clear();
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Capture a new thought...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: FlowColors.slate500),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  notifier.addTask(TaskModel(
                    id: '',
                    title: controller.text,
                    completed: false,
                    subtasks: [],
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                  ));
                  controller.clear();
                }
              },
              icon: const Icon(LucideIcons.plus, color: FlowColors.primary),
            ),
          ],
        ),
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
            'All caught up!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your inbox is clear.',
            style: TextStyle(color: FlowColors.slate500),
          ),
        ],
      ),
    );
  }
}
