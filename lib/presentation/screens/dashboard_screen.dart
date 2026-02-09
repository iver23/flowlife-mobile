import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers.dart';
import '../../core/task_notifier.dart';
import '../widgets/ui_components.dart';
import '../widgets/momentum_heatmap.dart';
import '../widgets/habit_streak_card.dart';
import '../../data/models/models.dart';
import '../../data/models/achievement_model.dart';
import '../../core/achievement_notifier.dart';
import 'project_detail_screen.dart';
import 'settings_screen.dart';
import '../../core/dashboard_widget_notifier.dart';
import '../widgets/dashboard_widget_settings_sheet.dart';
import '../../data/models/widget_model.dart';
import '../../core/quote_service.dart';
import '../widgets/task_edit_sheet.dart';
import '../widgets/task_detail_sheet.dart';
import '../../core/study_notifier.dart';
import '../widgets/theme_toggle.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isProjectsExpanded = false;
  bool _isHabitsExpanded = true;
  bool _isTasksExpanded = false;
  bool _isStudyExpanded = false;

  @override
  Widget build(BuildContext context) {
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
                _buildHeader(context, ref),
                const SizedBox(height: 32),
                ref.watch(dashboardWidgetProvider).when(
                  data: (widgets) => Column(
                    children: widgets.where((w) => w.isEnabled).map((w) => _buildWidget(context, ref, w, projectsAsync, tasksAsync)).toList(),
                  ),
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

  Widget _buildWidget(BuildContext context, WidgetRef ref, DashboardWidgetModel widget, AsyncValue<List<ProjectModel>> projects, AsyncValue<List<TaskModel>> tasks) {
    switch (widget.type) {
      case WidgetType.stats:
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: _buildQuoteCard(tasks),
        );
      case WidgetType.study:
        return ref.watch(studyNotifierProvider).when(
          data: (studyState) {
            final notifier = ref.read(studyNotifierProvider.notifier);
            final totalLessons = notifier.getTotalLessonsCount();
            final completedLessons = notifier.getCompletedLessonsCount();
            final overallProgress = totalLessons == 0 ? 0.0 : completedLessons / totalLessons;

            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: FlowCard(
                padding: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isStudyExpanded = !_isStudyExpanded),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'STUDY PROGRESS',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: FlowColors.slate400),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _isStudyExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                                size: 14,
                                color: FlowColors.slate400,
                              ),
                            ],
                          ),
                          Text(
                            '$completedLessons/$totalLessons',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlowColors.slate500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: overallProgress,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : FlowColors.slate100,
                        valueColor: AlwaysStoppedAnimation<Color>(FlowColors.primary),
                        minHeight: 6,
                      ),
                    ),
                    AnimatedSize(
                      duration: FlowAnimations.normal,
                      curve: FlowAnimations.defaultCurve,
                      child: _isStudyExpanded
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: studyState.areas.where((a) => !a.isArchived).map((area) {
                                  final areaProgress = notifier.getAreaProgress(area.id);
                                  final areaColor = FlowColors.parseProjectColor(area.color);
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              area.name.toUpperCase(),
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500, letterSpacing: 0.5),
                                            ),
                                            Text(
                                              '${(areaProgress * 100).toInt()}%',
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: areaColor),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                            value: areaProgress,
                                            backgroundColor: areaColor.withOpacity(0.1),
                                            valueColor: AlwaysStoppedAnimation<Color>(areaColor),
                                            minHeight: 4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: FlowCard(
              padding: 24,
              child: SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: FlowCard(
              padding: 24,
              child: Text('Error loading study data: $e'),
            ),
          ),
        );
      case WidgetType.habits:
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: HabitStreakCard(
            isExpanded: _isHabitsExpanded,
            onToggle: () => setState(() => _isHabitsExpanded = !_isHabitsExpanded),
            onSettingsTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        );
      case WidgetType.projects:
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: FlowCard(
            padding: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PROJECTS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: FlowColors.slate400),
                    ),
                    projects.when(
                      data: (data) => Text(
                        '${data.length} active',
                        style: const TextStyle(fontSize: 12, color: FlowColors.slate400),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                projects.when(
                  data: (data) => _buildProjectListCompact(data),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ),
          ),
        );
      case WidgetType.tasks:
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: FlowCard(
            padding: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isTasksExpanded = !_isTasksExpanded),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'UPCOMING TASKS',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: FlowColors.slate400),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _isTasksExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                            size: 14,
                            color: FlowColors.slate400,
                          ),
                        ],
                      ),
                      tasks.when(
                        data: (data) {
                          final filteredTasks = data
                              .where((t) => !t.completed)
                              .where((t) => t.urgencyLevel == UrgencyLevel.critical || t.urgencyLevel == UrgencyLevel.urgent)
                              .toList();
                          final totalFiltered = filteredTasks.length;
                          
                          return Text(
                            '$totalFiltered High Priority',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlowColors.slate500),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                tasks.when(
                  data: (data) {
                    final total = data.isEmpty ? 0 : data.length;
                    final completed = data.where((t) => t.completed).length;
                    final progress = total == 0 ? 0.0 : completed / total;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : FlowColors.slate100,
                        valueColor: AlwaysStoppedAnimation<Color>(FlowColors.primary),
                        minHeight: 6,
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                // Expanded: show tasks with smooth animation
                AnimatedSize(
                  duration: FlowAnimations.normal,
                  curve: FlowAnimations.defaultCurve,
                  child: _isTasksExpanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: tasks.when(
                            data: (data) {
                              final filtered = data
                                  .where((t) => !t.completed)
                                  .where((t) => t.urgencyLevel == UrgencyLevel.critical || t.urgencyLevel == UrgencyLevel.urgent)
                                  .toList()
                                ..sort((a, b) => b.urgencyLevel.value.compareTo(a.urgencyLevel.value));
                              return _buildRecentTasks(filtered, projects.value ?? []);
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, _) => Text('Error: $e'),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      case WidgetType.ideas:
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: FlowCard(
            padding: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RECENT IDEAS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: FlowColors.slate400),
                ),
                const SizedBox(height: 16),
                ref.watch(ideasProvider).when(
                  data: (data) => _buildRecentIdeas(data),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ),
          ),
        );
      case WidgetType.achievements:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LATEST ACHIEVEMENTS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: FlowColors.slate400),
            ),
            const SizedBox(height: 16),
            ref.watch(achievementProvider).when(
              data: (data) => _buildRecentAchievements(data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 32),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRecentIdeas(List<IdeaModel> ideas) {
    if (ideas.isEmpty) return const Text('No ideas yet.', style: TextStyle(color: FlowColors.slate400));
    return Column(
      children: ideas.take(2).map((idea) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: FlowCard(
          padding: 16,
          child: Text(idea.content, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      )).toList(),
    );
  }

  Widget _buildRecentAchievements(List<AchievementModel> achievements) {
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    if (unlocked.isEmpty) return const Text('Keep going to unlock achievements!', style: TextStyle(color: FlowColors.slate400));
    return Row(
      children: unlocked.take(4).map<Widget>((a) => Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: FlowColors.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(LucideIcons.trophy, size: 16, color: FlowColors.primary),
        ),
      )).toList(),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(
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
            _buildActionCircle(LucideIcons.layout, () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => const DashboardWidgetSettingsSheet(),
              );
            }),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildQuoteCard(AsyncValue<List<TaskModel>> tasksAsync) {
    final quote = ref.watch(quoteProvider);

    return tasksAsync.when(
      data: (tasks) {
        return FlowCard(
          useGlass: true,
          padding: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quote Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.amber.shade600,
                      height: 0.8,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(quoteProvider.notifier).refresh();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.refreshCw,
                        size: 16,
                        color: Colors.amber.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  quote.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (quote.author.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    quote.author,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              // Heatmap Section
              MomentumHeatmap(tasks: tasks),
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
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return FlowCard(
              backgroundColor: FlowColors.getSubtleProjectColor(projectColor, isDark),
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

  Widget _buildProjectListCompact(List<ProjectModel> projectsList) {
    if (projectsList.isEmpty) return const SizedBox.shrink();

    return Column(
      children: projectsList.map((project) {
        final projectColor = FlowColors.parseProjectColor(project.color);
        
        // Calculate real progress
        final tasks = ref.watch(tasksProvider).value ?? [];
        final projectTasks = tasks.where((t) => t.projectId == project.id).toList();
        final completedTasks = projectTasks.where((t) => t.completed).length;
        final progress = projectTasks.isEmpty ? 0.0 : completedTasks / projectTasks.length;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProjectDetailScreen(project: project)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: projectColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconData(project.icon),
                      size: 16,
                      color: projectColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Text(
                    project.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: FlowColors.slate100,
                      valueColor: AlwaysStoppedAnimation<Color>(projectColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 35,
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: FlowColors.slate500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconData(String iconName) {
    // Simple mapping for demonstration
    switch (iconName.toLowerCase()) {
      case 'anchor': return LucideIcons.anchor;
      case 'box': return LucideIcons.box;
      case 'heart': return LucideIcons.heart;
      case 'code': return LucideIcons.code;
      case 'shoppingcart': return LucideIcons.shoppingCart;
      default: return LucideIcons.layout;
    }
  }

  Widget _buildRecentTasks(List<TaskModel> tasks, List<ProjectModel> projects) {
    if (tasks.isEmpty) {
      return const Text('All caught up!', style: TextStyle(color: FlowColors.slate400));
    }
    return Column(
      children: tasks.map((task) {
        final project = projects.firstWhere(
          (p) => p.id == task.projectId,
          orElse: () => ProjectModel(
            id: 'temp',
            title: 'Inbox',
            color: 'slate',
            icon: 'inbox',
            weight: Importance.low,
          ),
        );
        final projectColor = FlowColors.parseProjectColor(project.color);
        final urgencyColor = Color(task.urgencyLevel.colorValue);
        final urgencyLabel = task.urgencyLevel.name[0].toUpperCase() + task.urgencyLevel.name.substring(1);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => TaskDetailSheet(task: task),
              );
            },
            child: FlowCard(
              padding: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular checkbox
                  GestureDetector(
                    onTap: () {
                      ref.read(taskNotifierProvider.notifier).toggleTask(task);
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: task.completed ? FlowColors.primary : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.completed ? FlowColors.primary : FlowColors.slate200,
                          width: 2,
                        ),
                      ),
                      child: task.completed
                          ? const Icon(LucideIcons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                            color: task.completed ? FlowColors.slate400 : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildTaskChip(urgencyLabel, _getUrgencyIcon(task.urgencyLevel), urgencyColor),
                            _buildTaskChip(project.title, _parseIcon(project.icon), projectColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaskChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
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
}
