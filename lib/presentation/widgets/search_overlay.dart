import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/models.dart';
import '../../core/providers.dart';
import '../screens/project_detail_screen.dart';
import 'ui_components.dart';

class SearchOverlay extends ConsumerStatefulWidget {
  const SearchOverlay({super.key});

  @override
  ConsumerState<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<SearchOverlay> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final ideasAsync = ref.watch(ideasProvider);

    return Material(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          margin: const EdgeInsets.only(top: 100),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search, color: FlowColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Search projects, tasks, or ideas...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: FlowColors.slate500),
                        ),
                        onChanged: (val) => setState(() => _query = val.toLowerCase()),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Results
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildResults(projectsAsync, tasksAsync, ideasAsync),
                ),
              ),
              
              // Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: FlowColors.slate500.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: const Row(
                  children: [
                    Text('Type to search anything...', style: TextStyle(fontSize: 10, color: FlowColors.slate500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(AsyncValue<List<ProjectModel>> projects, AsyncValue<List<TaskModel>> tasks, AsyncValue<List<IdeaModel>> ideas) {
    if (_query.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(LucideIcons.keyboard, size: 40, color: FlowColors.slate500),
              SizedBox(height: 16),
              Text('Start typing to find results', style: TextStyle(color: FlowColors.slate500)),
            ],
          ),
        ),
      );
    }

    final filteredProjects = projects.value?.where((p) => p.title.toLowerCase().contains(_query)).toList() ?? [];
    final filteredTasks = tasks.value?.where((t) => t.title.toLowerCase().contains(_query)).toList() ?? [];
    final filteredIdeas = ideas.value?.where((i) => i.content.toLowerCase().contains(_query)).toList() ?? [];

    if (filteredProjects.isEmpty && filteredTasks.isEmpty && filteredIdeas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text('No results found.', style: TextStyle(color: FlowColors.slate500)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredProjects.isNotEmpty) ...[
          _buildCategoryHeader('PROJECTS'),
          ...filteredProjects.map((p) => _buildResultTile(
            icon: LucideIcons.folder,
            title: p.title,
            subtitle: 'Project',
            color: FlowColors.primary,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectDetailScreen(project: p)),
              );
            },
          )),
        ],
        if (filteredTasks.isNotEmpty) ...[
          _buildCategoryHeader('TASKS'),
          ...filteredTasks.map((t) => _buildResultTile(
            icon: LucideIcons.checkCircle,
            title: t.title,
            subtitle: t.completed ? 'Completed' : 'Task',
            color: t.completed ? Colors.green : FlowColors.primary,
            onTap: () {
              Navigator.pop(context);
              // For tasks, we find the project it belongs to and navigate there
              final project = projects.value?.firstWhere((p) => p.id == t.projectId, orElse: () => ProjectModel(id: '', title: 'Unknown', icon: 'folder', color: 'blue', weight: Importance.low));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectDetailScreen(project: project!)),
              );
            },
          )),
        ],
        if (filteredIdeas.isNotEmpty) ...[
          _buildCategoryHeader('IDEAS'),
          ...filteredIdeas.map((i) => _buildResultTile(
            icon: LucideIcons.lightbulb,
            title: i.content,
            subtitle: 'Idea',
            color: Colors.amber,
            onTap: () {
              Navigator.pop(context);
              // Ideas could navigate to IdeasScreen (handled via state in MainScreen usually)
              // For now, staying simple since they can see it in search.
            },
          )),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildResultTile({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: FlowColors.slate500)),
      onTap: onTap,
    );
  }
}
