import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/ui_components.dart';
import '../../core/study_notifier.dart';
import '../../data/models/study_models.dart';
import 'settings_screen.dart';
import 'subject_area_detail_screen.dart';
import '../widgets/undo_toast.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(studyNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildScreenHeader(context),
            Expanded(
              child: asyncState.when(
                data: (state) => _buildContent(context, ref, state),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.alertCircle, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Error: $error', style: const TextStyle(color: FlowColors.slate500)),
                      TextButton(
                        onPressed: () => ref.invalidate(studyNotifierProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, StudyState state) {
    final filteredAreas = state.areas.where((a) => a.isArchived == _showArchived).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(ref, state),
          const SizedBox(height: 16),
          _buildViewToggle(),
          const SizedBox(height: 8),
          if (filteredAreas.isEmpty)
            _buildEmptyState(context)
          else
            ...filteredAreas.map((area) => _buildAreaCard(context, ref, area, state)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildScreenHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.bookOpen, color: FlowColors.slate500),
              SizedBox(width: 12),
              Text(
                'Study',
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

  Widget _buildViewToggle() {
    return Row(
      children: [
        _buildToggleItem("Active", !_showArchived),
        const SizedBox(width: 8),
        _buildToggleItem("Archived", _showArchived),
      ],
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

  Widget _buildHeader(WidgetRef ref, StudyState state) {
    int total = 0;
    int completed = 0;
    
    for (var lesson in state.lessons) {
      total++;
      if (lesson.isCompleted) completed++;
    }
    
    final progress = total == 0 ? 0.0 : completed / total;

    return FlowCard(
      padding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Study Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: FlowColors.slate200,
                    valueColor: const AlwaysStoppedAnimation<Color>(FlowColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold, color: FlowColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$completed of $total lessons completed',
            style: const TextStyle(color: FlowColors.slate500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaCard(BuildContext context, WidgetRef ref, SubjectArea area, StudyState state) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final notifier = ref.read(studyNotifierProvider.notifier);
    final areaSubjects = state.subjects.where((s) => s.areaId == area.id).toList();
    final progress = notifier.getAreaProgress(area.id);
    final areaColor = FlowColors.parseProjectColor(area.color);

    return Dismissible(
      key: Key(area.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: area.isArchived ? Colors.green : Colors.amber,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          area.isArchived ? LucideIcons.refreshCcw : LucideIcons.archive,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          notifier.deleteArea(area);
          UndoToast.show(
            context: context,
            message: 'Subject Area moved to Trash',
            onUndo: () => notifier.restoreArea(area.id),
          );
        } else {
          if (area.isArchived) {
            notifier.unarchiveArea(area);
          } else {
            notifier.archiveArea(area);
          }
        }
      },
      child: FlowCard(
        margin: const EdgeInsets.only(top: 16),
        padding: 20,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubjectAreaDetailScreen(area: area),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: areaColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(LucideIcons.book, color: areaColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    area.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${areaSubjects.length} subjects',
                    style: const TextStyle(fontSize: 12, color: FlowColors.slate500),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: areaColor,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : FlowColors.slate100,
                      valueColor: AlwaysStoppedAnimation<Color>(areaColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Icon(LucideIcons.chevronRight, size: 16, color: FlowColors.slate400),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Icon(LucideIcons.bookOpen, size: 64, color: FlowColors.slate200),
          const SizedBox(height: 16),
          Text(
            _showArchived ? 'No archived study areas' : 'Start your study path',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FlowColors.slate400),
          ),
          const SizedBox(height: 8),
          Text(
            _showArchived 
                ? 'Your archived areas will appear here.' 
                : 'Create a subject area to begin',
            style: const TextStyle(color: FlowColors.slate500),
          ),
        ],
      ),
    );
  }

}
