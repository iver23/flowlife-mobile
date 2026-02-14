import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/idea_notifier.dart';
import '../../core/task_notifier.dart';
import '../../core/project_notifier.dart';
import '../../data/models/models.dart';
import '../widgets/ui_components.dart';
import '../widgets/task_card.dart';
import '../widgets/task_detail_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final ideasAsync = ref.watch(ideaNotifierProvider);
    final projectsAsync = ref.watch(projectNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(context),
            Expanded(
              child: _query.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildSection<TaskModel>(
                            title: 'TASKS',
                            data: tasksAsync,
                            query: _query,
                            filter: (task) => task.title.toLowerCase().contains(_query.toLowerCase()) || 
                                           (task.description ?? '').toLowerCase().contains(_query.toLowerCase()),
                            builder: (task, projects) => _buildTaskResult(task, projects),
                          ),
                          _buildSection<IdeaModel>(
                            title: 'IDEAS',
                            data: ideasAsync,
                            query: _query,
                            filter: (idea) => idea.content.toLowerCase().contains(_query.toLowerCase()),
                            builder: (idea, _) => _buildIdeaResult(idea),
                          ),
                          _buildSection<ProjectModel>(
                            title: 'PROJECTS',
                            data: projectsAsync,
                            query: _query,
                            filter: (project) => project.title.toLowerCase().contains(_query.toLowerCase()),
                            builder: (project, _) => _buildProjectResult(context, project),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.arrowLeft, color: FlowColors.slate500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? FlowColors.surfaceDark 
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: FlowColors.slate400.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) => setState(() => _query = val),
                decoration: const InputDecoration(
                  hintText: 'Search tasks, ideas, projects...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: FlowColors.slate500, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.search, size: 64, color: FlowColors.slate400.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('Search for anything', style: TextStyle(color: FlowColors.slate500)),
        ],
      ),
    );
  }

  Widget _buildSection<T>({
    required String title,
    required AsyncValue<List<T>> data,
    required String query,
    required bool Function(T) filter,
    required Widget Function(T, List<ProjectModel>) builder,
  }) {
    return data.when(
      data: (items) {
        final results = items.where(filter).toList();
        if (results.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            ...results.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: builder(item, []), // Placeholder for projects
            )),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  // Wrappers for results
  Widget _buildTaskResult(TaskModel task, List<ProjectModel> projects) {
    // We need to fetch the project for the TaskCard
    final projectsAsync = ref.read(projectNotifierProvider);
    return projectsAsync.when(
      data: (allProjects) {
        final project = task.projectId != null 
            ? allProjects.firstWhere((p) => p.id == task.projectId, orElse: () => _defaultProject())
            : _defaultProject();
        
        return TaskCard(
          task: task,
          projectTitle: project.title,
          projectIcon: project.icon,
          projectColor: FlowColors.parseProjectColor(project.color),
          onToggle: () => ref.read(taskNotifierProvider.notifier).toggleTask(task),
          onDelete: () => ref.read(taskNotifierProvider.notifier).deleteTask(task),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
                builder: (context) => TaskDetailSheet(task: task),
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildIdeaResult(IdeaModel idea) {
    return FlowCard(
      padding: 16,
      onTap: () {
        // Just show but maybe allow converting?
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(idea.content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProjectResult(BuildContext context, ProjectModel project) {
    return FlowCard(
      padding: 16,
      onTap: () {
        // Navigate or something?
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FlowColors.parseProjectColor(project.color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_parseIcon(project.icon), size: 18, color: FlowColors.parseProjectColor(project.color)),
          ),
          const SizedBox(width: 16),
          Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  ProjectModel _defaultProject() {
    return ProjectModel(
      id: 'other',
      title: 'Other',
      color: 'slate',
      icon: 'hash',
      weight: Importance.medium,
      isSystemProject: true,
    );
  }

  IconData _parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'briefcase': return LucideIcons.briefcase;
      case 'home': return LucideIcons.home;
      case 'user': return LucideIcons.user;
      case 'heart': return LucideIcons.heart;
      case 'book': return LucideIcons.book;
      case 'code': return LucideIcons.code;
      default: return LucideIcons.folder;
    }
  }
}
