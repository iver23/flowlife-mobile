import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers.dart';
import '../../core/idea_notifier.dart';
import '../widgets/undo_toast.dart';
import '../../core/project_notifier.dart';
import '../../core/date_formatter.dart';
import 'settings_screen.dart';
import '../widgets/ui_components.dart';
import '../../data/models/models.dart';
import '../widgets/idea_edit_sheet.dart';
import '../../core/task_notifier.dart';
import '../widgets/task_edit_sheet.dart';

class IdeasScreen extends ConsumerWidget {
  const IdeasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ideasAsync = ref.watch(ideaNotifierProvider);
    final projectsAsync = ref.watch(projectNotifierProvider);
    final ideaNotifier = ref.read(ideaNotifierProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ideasAsync.when(
                data: (ideas) {
                  final selectedProjectId = ref.watch(selectedProjectFilterProvider);
                  
                  var filteredIdeas = ideas.toList();
                  
                  if (selectedProjectId != null) {
                    filteredIdeas = filteredIdeas.where((i) => i.projectId == selectedProjectId).toList();
                  }
                  
                  if (filteredIdeas.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filteredIdeas.length,
                    itemBuilder: (context, index) {
                      final idea = filteredIdeas[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: projectsAsync.when(
                          data: (projects) => _buildIdeaCard(context, idea, ideaNotifier, projects, ref),
                          loading: () => _buildIdeaCard(context, idea, ideaNotifier, [], ref),
                          error: (_, _) => _buildIdeaCard(context, idea, ideaNotifier, [], ref),
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
          const Row(
            children: [
              Icon(LucideIcons.lightbulb, color: FlowColors.slate500),
              SizedBox(width: 12),
              Text(
                'Ideas & Thoughts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
          _buildActionCircle(LucideIcons.settings, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionCircle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: FlowColors.surfaceDark.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: FlowColors.slate500),
      ),
    );
  }



  Widget _buildIdeaCard(BuildContext context, IdeaModel idea, IdeaNotifier notifier, List<ProjectModel> projects, WidgetRef ref) {
    ProjectModel? project;
    if (idea.projectId != null) {
      project = projects.firstWhere((p) => p.id == idea.projectId, orElse: () => _defaultProject());
    }

    return Dismissible(
      key: Key(idea.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      onDismissed: (_) {
        notifier.deleteIdea(idea);
        UndoToast.show(
          context: context,
          message: 'Idea moved to Trash',
          onUndo: () => notifier.restoreIdea(idea.id),
        );
      },
      child: FlowCard(
        padding: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    idea.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
                const SizedBox(width: 8),
                _buildProjectTag(project),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.formatTimestamp(idea.createdAt),
                  style: const TextStyle(fontSize: 12, color: FlowColors.slate500),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showEditSheet(context, idea, notifier),
                      child: const Icon(
                        LucideIcons.edit,
                        size: 18,
                        color: FlowColors.slate500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _showConvertToTaskSheet(context, idea, notifier, ref),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.arrowRightCircle, size: 18, color: FlowColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'CONVERT TO TASK',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, IdeaModel idea, IdeaNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => IdeaEditSheet(
        idea: idea,
        onSave: (updatedIdea) => notifier.updateIdea(updatedIdea),
      ),
    );
  }

  void _showConvertToTaskSheet(BuildContext context, IdeaModel idea, IdeaNotifier ideaNotifier, WidgetRef ref) {
    // Create pre-filled task
    final prefilledTask = TaskModel(
      id: '',
      title: idea.content,
      projectId: idea.projectId ?? 'other',
      completed: false,
      subtasks: [],
      createdAt: DateTime.now().millisecondsSinceEpoch,
      order: 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskEditSheet(
        task: prefilledTask,
        onSave: (newTask) async {
          // Add task via TaskNotifier
          await ref.read(taskNotifierProvider.notifier).addTask(newTask);
          // Delete the original idea
          await ref.read(firestoreServiceProvider).deleteIdea(idea.id);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.sparkles, size: 64, color: FlowColors.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text(
            'No ideas yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start capturing your thoughts!',
            style: TextStyle(color: FlowColors.slate500),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTag(ProjectModel? project) {
    return FlowBadge(
      label: project?.title ?? 'Other',
      color: FlowColors.parseProjectColor(project?.color ?? 'slate'),
    );
  }

  ProjectModel _defaultProject() {
    return ProjectModel(
      id: 'other',
      title: 'Other',
      color: 'slate',
      icon: 'hash',
      weight: Importance.low,
      isSystemProject: true,
    );
  }
}
