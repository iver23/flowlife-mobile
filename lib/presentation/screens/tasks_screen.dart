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
import 'package:flutter/services.dart';
import '../../core/bulk_selection_provider.dart';
import '../widgets/task_detail_sheet.dart';
import '../widgets/undo_toast.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final projectsAsync = ref.watch(projectNotifierProvider);
    final taskNotifier = ref.read(taskNotifierProvider.notifier);
    final selectionState = ref.watch(bulkSelectionProvider);
    final selectionNotifier = ref.read(bulkSelectionProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref),
            _buildProjectFilterRow(context, ref, projectsAsync),
            _buildUrgencyFilterRow(context, ref),
            Expanded(
              child: Stack(
                children: [
                  tasksAsync.when(
                data: (tasks) {
                  final selectedProjectId = ref.watch(selectedProjectFilterProvider);
                  final selectedUrgency = ref.watch(selectedUrgencyFilterProvider);
                  var activeTasks = tasks.where((t) => !t.completed).toList();
                  
                  if (selectedProjectId != null) {
                    activeTasks = activeTasks.where((t) => t.projectId == selectedProjectId).toList();
                  }
                  if (selectedUrgency != null) {
                    activeTasks = activeTasks.where((t) => t.urgencyLevel == selectedUrgency).toList();
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
                          final item = activeTasks.removeAt(oldIndex);
                          activeTasks.insert(newIndex, item);
                          taskNotifier.reorderTasks(activeTasks);
                        },
                        itemBuilder: (context, index) {
                          final task = activeTasks[index];
                          final project = task.projectId != null 
                              ? projects.firstWhere((p) => p.id == task.projectId, orElse: () => _defaultProject())
                              : _defaultProject();
                          

                          return Padding(
                            key: ValueKey(task.id),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TaskCard(
                              task: task,
                              projectTitle: project.title,
                              projectIcon: project.icon,
                              projectColor: FlowColors.parseProjectColor(project.color),
                              isSelectionMode: selectionState.isSelectionMode,
                              isSelected: selectionState.selectedTaskIds.contains(task.id),
                                onSelectionToggle: () => selectionNotifier.selectTask(task.id),
                                onToggle: () => taskNotifier.toggleTask(task),
                                onDelete: () {
                                  taskNotifier.deleteTask(task);
                                  UndoToast.show(
                                    context: context,
                                    message: 'Task moved to Trash',
                                    onUndo: () => taskNotifier.restoreTask(task.id),
                                  );
                                },
                              onTap: () {
                                if (selectionState.isSelectionMode) {
                                  selectionNotifier.selectTask(task.id);
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => TaskDetailSheet(task: task),
                                  );
                                }
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
              if (selectionState.isSelectionMode && selectionState.selectedTaskIds.isNotEmpty)
                _buildBulkActionBar(context, ref, selectionState.selectedTaskIds.toList()),
            ],
          ),
        ),
      ],
    ),
      ),
    );
  }

  Widget _buildProjectFilterRow(BuildContext context, WidgetRef ref, AsyncValue<List<ProjectModel>> projectsAsync) {
    final selectedProjectId = ref.watch(selectedProjectFilterProvider);
    
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            _buildFilterChip(
              label: 'All Projects',
              icon: LucideIcons.layers,
              color: FlowColors.primary,
              isSelected: selectedProjectId == null,
              onTap: () => ref.read(selectedProjectFilterProvider.notifier).clear(),
            ),
            const SizedBox(width: 8),
            projectsAsync.when(
              data: (projects) => Row(
                children: projects.map((project) {
                  final color = FlowColors.parseProjectColor(project.color);
                  final isSelected = selectedProjectId == project.id;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: project.title,
                      icon: _parseProjectIcon(project.icon),
                      color: color,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(selectedProjectFilterProvider.notifier).setProject(isSelected ? null : project.id);
                      },
                    ),
                  );
                }).toList(),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgencyFilterRow(BuildContext context, WidgetRef ref) {
    final selectedUrgency = ref.watch(selectedUrgencyFilterProvider);
    
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            _buildFilterChip(
              label: 'All Urgency',
              icon: LucideIcons.alertCircle,
              color: FlowColors.primary,
              isSelected: selectedUrgency == null,
              onTap: () => ref.read(selectedUrgencyFilterProvider.notifier).clear(),
            ),
            const SizedBox(width: 8),
            ...UrgencyLevel.values.map((level) {
              final color = Color(level.colorValue);
              final isSelected = selectedUrgency == level;
              final label = level.name[0].toUpperCase() + level.name.substring(1);
              final icon = _getUrgencyIcon(level);
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  label: label,
                  icon: icon,
                  color: color,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(selectedUrgencyFilterProvider.notifier).setUrgency(isSelected ? null : level);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final inactiveBackground = isDark 
            ? Colors.white.withValues(alpha: 0.08) 
            : FlowColors.slate100.withValues(alpha: 0.5);
        final inactiveTextColor = isDark 
            ? Colors.white.withValues(alpha: 0.6) 
            : FlowColors.slate500;
        final inactiveIconColor = isDark 
            ? Colors.white.withValues(alpha: 0.5) 
            : FlowColors.slate400;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.15) : inactiveBackground,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isSelected ? color.withValues(alpha: 0.3) : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon, 
                  size: 14, 
                  color: isSelected ? color : inactiveIconColor
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? color : inactiveTextColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getUrgencyIcon(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.planning: return LucideIcons.calendar;
      case UrgencyLevel.low: return LucideIcons.clock;
      case UrgencyLevel.moderate: return LucideIcons.alertCircle;
      case UrgencyLevel.urgent: return LucideIcons.alertTriangle;
      case UrgencyLevel.critical: return LucideIcons.flame;
    }
  }

  IconData _parseProjectIcon(String iconName) {
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

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(bulkSelectionProvider);
    final selectionNotifier = ref.read(bulkSelectionProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                selectionState.isSelectionMode 
                  ? LucideIcons.checkCircle2 
                  : LucideIcons.checkSquare, 
                color: selectionState.isSelectionMode ? FlowColors.primary : FlowColors.slate500
              ),
              const SizedBox(width: 12),
              Text(
                selectionState.isSelectionMode 
                  ? '${selectionState.selectedTaskIds.length} Selected' 
                  : 'Active Tasks',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  selectionNotifier.toggleSelectionMode();
                },
                child: Text(
                  selectionState.isSelectionMode ? 'CANCEL' : 'SELECT',
                  style: TextStyle(
                    color: selectionState.isSelectionMode ? Colors.red : FlowColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
              ),
              if (!selectionState.isSelectionMode) ...[
                const SizedBox(width: 8),
                _buildActionCircle(LucideIcons.settings, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                }),
              ],
            ],
          ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.checkCircle2, size: 64, color: FlowColors.primary.withValues(alpha: 0.2)),
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
      id: 'other',
      title: 'Other',
      color: 'slate',
      icon: 'hash',
      weight: Importance.medium,
      isSystemProject: true,
    );
  }


  Widget _buildBulkActionBar(BuildContext context, WidgetRef ref, List<String> selectedIds) {
    final taskNotifier = ref.read(taskNotifierProvider.notifier);
    final selectionNotifier = ref.read(bulkSelectionProvider.notifier);

    return Positioned(
      bottom: 40,
      left: 24,
      right: 24,
      child: FlowCard(
        useGlass: true,
        padding: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBulkAction(
              LucideIcons.checkCircle2, 
              'Complete', 
              Colors.green, 
              () {
                taskNotifier.completeMultipleTasks(selectedIds);
                selectionNotifier.toggleSelectionMode();
              }
            ),
            _buildBulkAction(
              LucideIcons.folderInput, 
              'Move', 
              Colors.blue, 
              () => _showBatchMovePicker(context, ref, selectedIds)
            ),
            _buildBulkAction(
              LucideIcons.trash2, 
              'Delete', 
              Colors.red, 
              () => _confirmBatchDelete(context, ref, selectedIds)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBatchDelete(BuildContext context, WidgetRef ref, List<String> selectedIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${selectedIds.length} tasks?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              ref.read(taskNotifierProvider.notifier).deleteMultipleTasks(selectedIds);
              ref.read(bulkSelectionProvider.notifier).toggleSelectionMode();
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBatchMovePicker(BuildContext context, WidgetRef ref, List<String> selectedIds) {
    final projectsAsync = ref.watch(projectNotifierProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FlowCard(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Move to Project',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              projectsAsync.when(
                data: (projects) => Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...projects.map((p) => ListTile(
                          leading: Icon(
                            _parseIcon(p.icon), 
                            color: FlowColors.parseProjectColor(p.color)
                          ),
                          title: Text(p.title),
                          onTap: () {
                            ref.read(taskNotifierProvider.notifier).moveTasksToProject(selectedIds, p.id);
                            ref.read(bulkSelectionProvider.notifier).toggleSelectionMode();
                            Navigator.pop(context);
                          },
                        )),
                      ],
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const Text('Error loading projects'),
              ),
            ],
          ),
        ),
      ),
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
