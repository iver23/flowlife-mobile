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
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildMainStats(tasksAsync),
                const SizedBox(height: 32),
                const Text(
                  'PROJECTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: FlowColors.slate400,
                  ),
                ),
                const SizedBox(height: 16),
                projectsAsync.when(
                  data: (projects) => _buildProjectGrid(projects, ref),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
                const SizedBox(height: 32),
                _buildTasksHeader(),
                const SizedBox(height: 16),
                tasksAsync.when(
                  data: (tasks) => _buildRecentTasks(tasks.where((t) => !t.completed).toList()),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
                const SizedBox(height: 100), // Space for nav bar
              ],
            ),
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
            const Text(
              'Good morning',
              style: TextStyle(
                fontSize: 14,
                color: FlowColors.slate400,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : FlowColors.textLight,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildActionCircle(LucideIcons.bell, () {}),
            const SizedBox(width: 12),
            _buildActionCircle(LucideIcons.settings, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCircle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: FlowColors.surfaceDark.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: FlowColors.slate500),
      ),
    );
  }

  Widget _buildMainStats(AsyncValue<List<TaskModel>> tasksAsync) {
    return tasksAsync.when(
      data: (tasks) {
        final completed = tasks.where((t) => t.completed).length;
        final total = tasks.length;
        final progress = total == 0 ? 0.0 : completed / total;

        return FlowCard(
          useGlass: true,
          padding: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Progress',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: FlowColors.slate400),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}% Done',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
              const SizedBox(height: 24),
              MomentumHeatmap(tasks: tasks), // We'll redesign this next
            ],
          ),
        );
      },
      loading: () => const FlowCard(child: SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildTasksHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'UPCOMING TASKS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: FlowColors.slate400,
          ),
        ),
        Text(
          'See all',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: FlowColors.primary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }


  Widget _buildProjectGrid(List<ProjectModel> projects, WidgetRef ref) {
    if (projects.isEmpty) {
      return const Text('No projects yet.', style: TextStyle(color: FlowColors.slate400));
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
            childAspectRatio: 1.0,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            final projectColor = FlowColors.parseProjectColor(project.color);
            return FlowCard(
              padding: 20,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProjectDetailScreen(project: project)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: projectColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_parseIcon(project.icon), size: 18, color: projectColor),
                  ),
                  const Spacer(),
                  Text(
                    project.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -0.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildProjectProgress(project.id, ref, projectColor),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProjectProgress(String projectId, WidgetRef ref, Color color) {
    final tasksAsync = ref.watch(tasksProvider);
    return tasksAsync.when(
      data: (tasks) {
        final projectTasks = tasks.where((t) => t.projectId == projectId).toList();
        if (projectTasks.isEmpty) return FlowProgressBar(progress: 0, color: color);
        final completed = projectTasks.where((t) => t.completed).length;
        return FlowProgressBar(progress: completed / projectTasks.length, color: color);
      },
      loading: () => FlowProgressBar(progress: 0, color: color),
      error: (_, __) => FlowProgressBar(progress: 0, color: color),
    );
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
      return const Text('All caught up!', style: TextStyle(color: FlowColors.slate400));
    }
    return Column(
      children: tasks.take(3).map((task) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: FlowCard(
          padding: 16,
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: FlowColors.slate200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              const Icon(LucideIcons.chevronRight, size: 14, color: FlowColors.slate400),
            ],
          ),
        ),
      )).toList(),
    );
  }
}
