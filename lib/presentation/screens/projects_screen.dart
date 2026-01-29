import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers.dart';
import '../../core/project_notifier.dart';
import '../../data/models/models.dart';
import '../widgets/ui_components.dart';
import 'project_detail_screen.dart';
import '../widgets/project_edit_sheet.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: projectsAsync.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  // Sort projects by weight (importance) descending
                  final sortedProjects = [...projects];
                  sortedProjects.sort((a, b) => b.weight.value.compareTo(a.weight.value));

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: sortedProjects.length,
                    itemBuilder: (context, index) {
                      final project = sortedProjects[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildProjectCard(context, project, ref),
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
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(LucideIcons.folder, color: FlowColors.slate500),
          Text(
            'Your Projects',
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

  Widget _buildProjectCard(BuildContext context, ProjectModel project, WidgetRef ref) {
    return FlowCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailScreen(project: project),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _parseColor(project.color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_parseIcon(project.icon), color: _parseColor(project.color), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (project.description != null && project.description!.isNotEmpty)
                  Text(
                    project.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: FlowColors.slate500),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FlowBadge(
                label: project.weight.name,
                color: _getWeightColor(project.weight),
              ),
              const SizedBox(height: 8),
              _buildProgressMini(project.id, ref),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMini(String projectId, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    return tasksAsync.when(
      data: (tasks) {
        final projectTasks = tasks.where((t) => t.projectId == projectId).toList();
        if (projectTasks.isEmpty) return const Text('0%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
        final completed = projectTasks.where((t) => t.completed).length;
        final progress = (completed / projectTasks.length * 100).toInt();
        return Text('$progress%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.primary));
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.folder, size: 64, color: FlowColors.slate500),
          const SizedBox(height: 16),
          const Text('No projects yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Create your first project to get started!', style: TextStyle(color: FlowColors.slate500)),
        ],
      ),
    );
  }

  Color _getWeightColor(Importance importance) {
    switch (importance) {
      case Importance.low: return Colors.blue;
      case Importance.medium: return Colors.green;
      case Importance.high: return Colors.orange;
      case Importance.veryHigh: return Colors.deepOrange;
      case Importance.critical: return Colors.red;
    }
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
}
