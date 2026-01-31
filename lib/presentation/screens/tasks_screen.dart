import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers.dart';
import '../../core/task_notifier.dart';
import '../../core/project_notifier.dart';
import '../../data/models/models.dart';
import '../widgets/ui_components.dart';
import 'settings_screen.dart';
import '../widgets/task_card.dart';
import '../widgets/task_edit_sheet.dart';
import '../../core/tag_notifier.dart';
import '../../data/models/tag_model.dart';

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
            _buildTagFilters(context, ref),
            Expanded(
              child: tasksAsync.when(
                data: (tasks) {
                  final selectedTag = ref.watch(selectedTagFilterProvider);
                  final selectedProjectId = ref.watch(selectedProjectFilterProvider);
                  var activeTasks = tasks.where((t) => !t.completed).toList();

                  if (selectedTag != null) {
                    activeTasks = activeTasks.where((t) => t.customTags.contains(selectedTag)).toList();
                  }
                  
                  if (selectedProjectId != null) {
                    activeTasks = activeTasks.where((t) => t.projectId == selectedProjectId).toList();
                  }
                  
                  // Sort: Pinned first, then by creation date (newest first)
                  activeTasks.sort((a, b) {
                    if (a.isPinned && !b.isPinned) return -1;
                    if (!a.isPinned && b.isPinned) return 1;
                    return b.createdAt.compareTo(a.createdAt);
                  });

                  if (activeTasks.isEmpty) {
                    return _buildEmptyState();
                  }

                  return projectsAsync.when(
                    data: (projects) {
                      return ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: activeTasks.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = activeTasks.removeAt(oldIndex);
                          activeTasks.insert(newIndex, item);
                          taskNotifier.reorderTasks(activeTasks);
                        },
                        itemBuilder: (context, index) {
                          final task = activeTasks[index];
                          final project = task.projectId != null 
                              ? projects.firstWhere((p) => p.id == task.projectId, orElse: () => _defaultProject())
                              : _defaultProject();
                          
                          final tags = ref.watch(tagNotifierProvider).value ?? [];
                          final tagColors = <String, Color>{for (var t in tags) t.name: FlowColors.parseProjectColor(t.color)};

                          return Padding(
                            key: ValueKey(task.id),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TaskCard(
                              task: task,
                              projectTitle: project.title,
                              projectIcon: project.icon,
                              projectColor: FlowColors.parseProjectColor(project.color),
                              tagColors: tagColors,
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.checkSquare, color: FlowColors.slate500),
              SizedBox(width: 12),
              Text(
                'Active Tasks',
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
          color: FlowColors.surfaceDark.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: FlowColors.slate500),
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

  Widget _buildTagFilters(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagNotifierProvider);
    final projectsAsync = ref.watch(projectNotifierProvider);
    final selectedTag = ref.watch(selectedTagFilterProvider);
    final selectedProjectId = ref.watch(selectedProjectFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project Filters
        projectsAsync.when(
          data: (projects) {
            if (projects.isEmpty) return const SizedBox.shrink();
            return Container(
              height: 44,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: projects.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        avatar: const Icon(LucideIcons.layers, size: 14),
                        label: const Text('All Projects'),
                        selected: selectedProjectId == null,
                        onSelected: (selected) {
                          ref.read(selectedProjectFilterProvider.notifier).state = null;
                        },
                        selectedColor: FlowColors.primary.withOpacity(0.1),
                        checkmarkColor: FlowColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: selectedProjectId == null ? FlowColors.primary : FlowColors.slate500,
                          fontWeight: selectedProjectId == null ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.transparent,
                        shape: StadiumBorder(side: BorderSide(
                          color: selectedProjectId == null ? FlowColors.primary : FlowColors.slate400.withOpacity(0.2),
                        )),
                      ),
                    );
                  }

                  final project = projects[index - 1];
                  final isSelected = selectedProjectId == project.id;
                  final projectColor = FlowColors.parseProjectColor(project.color);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(_parseIcon(project.icon), size: 14, color: isSelected ? projectColor : FlowColors.slate500),
                      label: Text(project.title),
                      selected: isSelected,
                      onSelected: (selected) {
                        ref.read(selectedProjectFilterProvider.notifier).state = selected ? project.id : null;
                      },
                      selectedColor: projectColor.withOpacity(0.1),
                      checkmarkColor: projectColor,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? projectColor : FlowColors.slate500,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.transparent,
                      shape: StadiumBorder(side: BorderSide(
                        color: isSelected ? projectColor : FlowColors.slate400.withOpacity(0.2),
                      )),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        // Tag Filters
        tagsAsync.when(
          data: (tags) {
            if (tags.isEmpty) return const SizedBox.shrink();
            return Container(
              height: 44,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: tags.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        avatar: const Icon(LucideIcons.tag, size: 14),
                        label: const Text('All Tags'),
                        selected: selectedTag == null,
                        onSelected: (selected) {
                          ref.read(selectedTagFilterProvider.notifier).state = null;
                        },
                        selectedColor: FlowColors.primary.withOpacity(0.1),
                        checkmarkColor: FlowColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: selectedTag == null ? FlowColors.primary : FlowColors.slate500,
                          fontWeight: selectedTag == null ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.transparent,
                        shape: StadiumBorder(side: BorderSide(
                          color: selectedTag == null ? FlowColors.primary : FlowColors.slate400.withOpacity(0.2),
                        )),
                      ),
                    );
                  }

                  final tag = tags[index - 1];
                  final isSelected = selectedTag == tag.name;
                  final tagColor = FlowColors.parseProjectColor(tag.color);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tag.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        ref.read(selectedTagFilterProvider.notifier).state = selected ? tag.name : null;
                      },
                      selectedColor: tagColor.withOpacity(0.1),
                      checkmarkColor: tagColor,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? tagColor : FlowColors.slate500,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.transparent,
                      shape: StadiumBorder(side: BorderSide(
                        color: isSelected ? tagColor : FlowColors.slate400.withOpacity(0.2),
                      )),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
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
}
