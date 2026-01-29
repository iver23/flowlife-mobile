import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers.dart';
import '../widgets/ui_components.dart';
import '../widgets/momentum_heatmap.dart';
import '../../data/models/models.dart';
import 'project_detail_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              tasksAsync.when(
                data: (tasks) => MomentumHeatmap(tasks: tasks),
                loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 32),
              const Text(
                'PROJECTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: FlowColors.slate500,
                ),
              ),
              const SizedBox(height: 16),
              projectsAsync.when(
                data: (projects) => _buildProjectGrid(projects, ref),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 32),
              const Text(
                'UPCOMING TASKS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: FlowColors.slate500,
                ),
              ),
              const SizedBox(height: 16),
              tasksAsync.when(
                data: (tasks) => _buildRecentTasks(tasks.where((t) => !t.completed).toList()),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Afternoon,',
              style: TextStyle(
                fontSize: 14,
                color: FlowColors.slate500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              'Flow State',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: FlowColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.user, color: FlowColors.primary),
          ),
        ),
      ],
    );
  }


  Widget _buildProjectGrid(List<ProjectModel> projects, WidgetRef ref) {
    if (projects.isEmpty) {
      return const Text('No projects yet.');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return FlowCard(
              padding: 16,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDetailScreen(project: project),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _parseColor(project.color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_parseIcon(project.icon), size: 20, color: _parseColor(project.color)),
                  ),
                  const Spacer(),
                  Text(
                    project.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildProjectProgress(project.id, ref),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProjectProgress(String projectId, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    return tasksAsync.when(
      data: (tasks) {
        final projectTasks = tasks.where((t) => t.projectId == projectId).toList();
        if (projectTasks.isEmpty) return const FlowProgressBar(progress: 0);
        final completed = projectTasks.where((t) => t.completed).length;
        return FlowProgressBar(progress: completed / projectTasks.length);
      },
      loading: () => const FlowProgressBar(progress: 0),
      error: (_, __) => const FlowProgressBar(progress: 0),
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

  IconData _parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'work': return LucideIcons.briefcase;
      case 'home': return LucideIcons.home;
      case 'favorite': return LucideIcons.heart;
      case 'bolt': return LucideIcons.zap;
      case 'menu_book': return LucideIcons.book;
      case 'coffee': return LucideIcons.coffee;
      case 'public': return LucideIcons.globe;
      case 'anchor': return LucideIcons.anchor;
      case 'fitness_center': return LucideIcons.dumbbell;
      case 'shopping_cart': return LucideIcons.shoppingCart;
      case 'flight': return LucideIcons.plane;
      case 'music_note': return LucideIcons.music;
      case 'pets': return LucideIcons.dog;
      case 'spa': return LucideIcons.flower;
      case 'code': return LucideIcons.code;
      case 'savings': return LucideIcons.banknote;
      default: return LucideIcons.folder;
    }
  }

  Widget _buildRecentTasks(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return const Text('All caught up!');
    }
    return Column(
      children: tasks.take(3).map((task) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: FlowCard(
          padding: 16,
          child: Row(
            children: [
              Icon(LucideIcons.circle, size: 18, color: FlowColors.slate500),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}
