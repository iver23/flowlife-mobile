import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers.dart';
import '../../core/project_notifier.dart';
import '../../data/models/models.dart';
import '../widgets/ui_components.dart';
import 'settings_screen.dart';
import 'project_detail_screen.dart';
import '../widgets/undo_toast.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildViewToggle(),
            Expanded(
              child: projectsAsync.when(
                data: (projects) {
                  final filteredProjects = projects.where((p) => p.isArchived == _showArchived).toList();
                  
                  if (filteredProjects.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  // Sort projects by weight (importance) descending
                  filteredProjects.sort((a, b) => b.weight.value.compareTo(a.weight.value));

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
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

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          _buildToggleItem("Active", !_showArchived),
          const SizedBox(width: 8),
          _buildToggleItem("Archived", _showArchived),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isActive) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _showArchived = label == "Archived"),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? FlowColors.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? FlowColors.primary : FlowColors.slate200.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? FlowColors.primary : FlowColors.slate500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.folder, color: FlowColors.slate500),
              SizedBox(width: 12),
              Text(
                'Your Projects',
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

  Widget _buildProjectCard(BuildContext context, ProjectModel project, WidgetRef ref) {
    Widget card = FlowCard(
      backgroundColor: FlowColors.getSubtleProjectColor(_parseColor(project.color), Theme.of(context).brightness == Brightness.dark),
      onTap: () {
        ref.read(projectNotifierProvider.notifier).updateProject(
          project.copyWith(lastVisitedAt: DateTime.now().millisecondsSinceEpoch),
        );
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
              color: _parseColor(project.color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(project.isSystemProject ? LucideIcons.hash : _parseIcon(project.icon), color: _parseColor(project.color), size: 24),
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

    if (project.isSystemProject) return card;

    return Dismissible(
      key: Key(project.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: project.isArchived ? Colors.green : Colors.amber,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          project.isArchived ? LucideIcons.refreshCcw : LucideIcons.archive,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          ref.read(projectNotifierProvider.notifier).deleteProject(project);
          UndoToast.show(
            context: context,
            message: 'Project moved to Trash',
            onUndo: () => ref.read(projectNotifierProvider.notifier).restoreProject(project.id),
          );
        } else {
          if (project.isArchived) {
            ref.read(projectNotifierProvider.notifier).unarchiveProject(project);
          } else {
            ref.read(projectNotifierProvider.notifier).archiveProject(project);
          }
        }
      },
      child: card,
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
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.folder, size: 64, color: FlowColors.slate500.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            _showArchived ? 'No archived projects' : 'No active projects',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _showArchived 
                ? 'Your archived projects will appear here.' 
                : 'Create your first project to get started!',
            style: const TextStyle(color: FlowColors.slate500),
          ),
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
