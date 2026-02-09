import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/trash_notifier.dart';
import '../../../data/services/firestore_service.dart';
import '../../../core/providers.dart';
import '../../../data/models/models.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/models/study_models.dart';
import '../../widgets/ui_components.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trashNotifier = ref.read(trashNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: FlowColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => _confirmEmptyTrash(context, trashNotifier),
            child: const Text('EMPTY', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: FlowColors.primary,
          unselectedLabelColor: FlowColors.slate500,
          indicatorColor: FlowColors.primary,
          tabs: const [
            Tab(text: 'Tasks'),
            Tab(text: 'Projects'),
            Tab(text: 'Ideas'),
            Tab(text: 'Habits'),
            Tab(text: 'Study'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTasksTab(),
          _buildProjectsTab(),
          _buildIdeasTab(),
          _buildHabitsTab(),
          _buildStudyTab(),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    final firestore = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<TaskModel>>(
      stream: firestore.streamTrashedTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        if (items.isEmpty) return _buildEmptyState('No trashed tasks');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildTrashItem(
            title: items[index].title,
            deletedAt: items[index].deletedAt,
            onRestore: () => ref.read(trashNotifierProvider.notifier).restoreTask(items[index].id),
            onDelete: () => ref.read(trashNotifierProvider.notifier).permanentlyDeleteTask(items[index].id),
          ),
        );
      },
    );
  }

  Widget _buildProjectsTab() {
    final firestore = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<ProjectModel>>(
      stream: firestore.streamTrashedProjects(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        if (items.isEmpty) return _buildEmptyState('No trashed projects');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildTrashItem(
            title: items[index].title,
            deletedAt: items[index].deletedAt,
            onRestore: () => ref.read(trashNotifierProvider.notifier).restoreProject(items[index].id),
            onDelete: () => ref.read(trashNotifierProvider.notifier).permanentlyDeleteProject(items[index].id),
          ),
        );
      },
    );
  }

  Widget _buildIdeasTab() {
    final firestore = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<IdeaModel>>(
      stream: firestore.streamTrashedIdeas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        if (items.isEmpty) return _buildEmptyState('No trashed ideas');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildTrashItem(
            title: items[index].content,
            deletedAt: items[index].deletedAt,
            onRestore: () => ref.read(trashNotifierProvider.notifier).restoreIdea(items[index].id),
            onDelete: () => ref.read(trashNotifierProvider.notifier).permanentlyDeleteIdea(items[index].id),
          ),
        );
      },
    );
  }


  Widget _buildHabitsTab() {
    final firestore = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<HabitModel>>(
      stream: firestore.streamTrashedHabits(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        if (items.isEmpty) return _buildEmptyState('No trashed habits');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildTrashItem(
            title: items[index].title,
            deletedAt: items[index].deletedAt,
            onRestore: () => ref.read(trashNotifierProvider.notifier).restoreHabit(items[index].id),
            onDelete: () => ref.read(trashNotifierProvider.notifier).permanentlyDeleteHabit(items[index].id),
          ),
        );
      },
    );
  }

  Widget _buildStudyTab() {
    final firestore = ref.watch(firestoreServiceProvider);
    return MultiStreamBuilder(
      streams: [
        firestore.streamTrashedSubjectAreas(),
        firestore.streamTrashedSubjects(),
        firestore.streamTrashedLessons(),
      ],
      builder: (context, snapshots) {
        final areas = snapshots[0].data as List<SubjectArea>? ?? [];
        final subjects = snapshots[1].data as List<Subject>? ?? [];
        final lessons = snapshots[2].data as List<Lesson>? ?? [];

        final allItems = [
          ...areas.map((e) => _StudyTrashItem(title: 'Area: ${e.name}', deletedAt: e.deletedAt, onRestore: () => ref.read(trashNotifierProvider.notifier).restoreSubjectArea(e.id), onDelete: () => ref.read(trashNotifierProvider.notifier).permanentlyDeleteSubjectArea(e.id))),
          ...subjects.map((e) => _StudyTrashItem(title: 'Subject: ${e.name}', deletedAt: e.deletedAt, onRestore: () => ref.read(trashNotifierProvider.notifier).restoreSubject(e.id), onDelete: () => ref.read(trashNotifierProvider.notifier).permanentlyDeleteSubject(e.id))),
          ...lessons.map((e) => _StudyTrashItem(title: 'Lesson: ${e.title}', deletedAt: e.deletedAt, onRestore: () => ref.read(trashNotifierProvider.notifier).restoreLesson(e.id), onDelete: () => ref.read(trashNotifierProvider.notifier).permanentlyDeleteLesson(e.id))),
        ];

        if (allItems.isEmpty) return _buildEmptyState('No trashed study items');

        allItems.sort((a, b) => (b.deletedAt ?? 0).compareTo(a.deletedAt ?? 0));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allItems.length,
          itemBuilder: (context, index) {
            final item = allItems[index];
            return _buildTrashItem(
              title: item.title,
              deletedAt: item.deletedAt,
              onRestore: item.onRestore,
              onDelete: item.onDelete,
            );
          },
        );
      },
    );
  }

  Widget _buildTrashItem({
    required String title,
    int? deletedAt,
    required VoidCallback onRestore,
    required VoidCallback onDelete,
  }) {
    final daysRemaining = deletedAt == null 
        ? 15 
        : 15 - DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(deletedAt)).inDays;

    return FlowCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('Deletes in $daysRemaining days', style: const TextStyle(fontSize: 12, color: FlowColors.slate500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(LucideIcons.refreshCcw, size: 18, color: Colors.green),
              onPressed: onRestore,
            ),
            IconButton(
              icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.trash2, size: 48, color: FlowColors.slate200),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: FlowColors.slate500)),
        ],
      ),
    );
  }

  void _confirmEmptyTrash(BuildContext context, TrashNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash?'),
        content: const Text('All items will be permanently deleted. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              notifier.emptyTrash();
              Navigator.pop(context);
            },
            child: const Text('EMPTY', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StudyTrashItem {
  final String title;
  final int? deletedAt;
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  _StudyTrashItem({required this.title, this.deletedAt, required this.onRestore, required this.onDelete});
}

class MultiStreamBuilder extends StatelessWidget {
  final List<Stream<dynamic>> streams;
  final Widget Function(BuildContext, List<AsyncSnapshot<dynamic>>) builder;

  const MultiStreamBuilder({super.key, required this.streams, required this.builder});

  @override
  Widget build(BuildContext context) {
    return _buildRecursive(context, 0, []);
  }

  Widget _buildRecursive(BuildContext context, int index, List<AsyncSnapshot<dynamic>> snapshots) {
    if (index == streams.length) {
      return builder(context, snapshots);
    }
    return StreamBuilder<dynamic>(
      stream: streams[index],
      builder: (ctx, snapshot) {
        return _buildRecursive(ctx, index + 1, [...snapshots, snapshot]);
      },
    );
  }
}
