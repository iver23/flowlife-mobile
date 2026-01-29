import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers.dart';
import '../../core/idea_notifier.dart';
import '../../core/date_formatter.dart';
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
            Expanded(
              child: ideasAsync.when(
                data: (ideas) {
                  if (ideas.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: ideas.length,
                    itemBuilder: (context, index) {
                      final idea = ideas[index];
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
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(LucideIcons.lightbulb, color: FlowColors.slate500),
          Text(
            'Ideas & Thoughts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          SizedBox(width: 24), // Spacer for centering
        ],
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.formatTimestamp(idea.createdAt),
                style: const TextStyle(fontSize: 12, color: FlowColors.slate500),
              ),
              GestureDetector(
                onTap: () => notifier.convertToTask(idea, ref),
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
      color: project != null ? _parseColor(project.color) : FlowColors.slate500,
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
}
