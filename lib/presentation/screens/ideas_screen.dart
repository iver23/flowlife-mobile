import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers.dart';
import '../../core/idea_notifier.dart';
import '../../core/project_notifier.dart';
import '../../core/tag_notifier.dart';
import '../../core/date_formatter.dart';
import '../../data/models/tag_model.dart';
import 'settings_screen.dart';
import '../widgets/ui_components.dart';
import '../../data/models/models.dart';

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
            _buildFilters(context, ref),
            Expanded(
              child: ideasAsync.when(
                data: (ideas) {
                  final selectedTag = ref.watch(selectedTagFilterProvider);
                  final selectedProjectId = ref.watch(selectedProjectFilterProvider);
                  
                  var filteredIdeas = ideas.toList();
                  
                  if (selectedTag != null) {
                    filteredIdeas = filteredIdeas.where((i) => i.customTags.contains(selectedTag)).toList();
                  }
                  
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
                          error: (_, __) => _buildIdeaCard(context, idea, ideaNotifier, [], ref),
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
          color: FlowColors.surfaceDark.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: FlowColors.slate500),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, WidgetRef ref) {
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


  Widget _buildIdeaCard(BuildContext context, IdeaModel idea, IdeaNotifier notifier, List<ProjectModel> projects, WidgetRef ref) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    ProjectModel? project;
    if (idea.projectId != null) {
      project = projects.firstWhere((p) => p.id == idea.projectId, orElse: () => _defaultProject());
    }

    return FlowCard(
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
          if (idea.customTags.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: idea.customTags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: FlowColors.slate400.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  t,
                  style: const TextStyle(fontSize: 10, color: FlowColors.slate500, fontWeight: FontWeight.bold),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.formatTimestamp(idea.createdAt),
                style: const TextStyle(fontSize: 12, color: FlowColors.slate500),
              ),
              GestureDetector(
                onTap: () => notifier.convertToTask(idea),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.sparkles, size: 64, color: FlowColors.primary.withOpacity(0.2)),
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
      label: project?.title ?? '#OTHER',
      color: FlowColors.parseProjectColor(project?.color),
    );
  }

  ProjectModel _defaultProject() {
    return ProjectModel(
      id: '',
      title: 'Other',
      color: 'slate',
      icon: 'hash',
      weight: Importance.low,
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
