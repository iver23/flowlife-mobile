import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/ui_components.dart';
import '../../core/study_notifier.dart';
import '../../data/models/study_models.dart';
import 'settings_screen.dart';
import '../widgets/study_edit_sheet.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyNotifierProvider);
    final filteredAreas = state.areas.where((a) => a.isArchived == _showArchived).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildScreenHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(ref),
                    const SizedBox(height: 16),
                    _buildViewToggle(),
                    const SizedBox(height: 8),
                    if (filteredAreas.isEmpty)
                      _buildEmptyState(context)
                    else
                      ...filteredAreas.map((area) => _buildAreaTile(context, ref, area)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          color: FlowColors.surfaceDark.withOpacity(0.05),
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
            color: isActive ? FlowColors.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? FlowColors.primary : FlowColors.slate200.withOpacity(0.5),
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

  Widget _buildHeader(WidgetRef ref) {
    final notifier = ref.read(studyNotifierProvider.notifier);
    final total = notifier.getTotalLessonsCount();
    final completed = notifier.getCompletedLessonsCount();
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

  Widget _buildAreaTile(BuildContext context, WidgetRef ref, SubjectArea area) {
    final state = ref.watch(studyNotifierProvider);
    final notifier = ref.read(studyNotifierProvider.notifier);
    final areaSubjects = state.subjects.where((s) => s.areaId == area.id).toList();
    final progress = notifier.getAreaProgress(area.id);

    return Dismissible(
      key: Key(area.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
          color: area.isArchived ? Colors.green : Colors.amber,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          area.isArchived ? LucideIcons.refreshCcw : LucideIcons.archive,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        if (area.isArchived) {
          notifier.unarchiveArea(area);
        } else {
          notifier.archiveArea(area);
        }
      },
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: FlowCard(
          margin: const EdgeInsets.only(top: 24),
          padding: 0,
          child: ExpansionTile(
            key: PageStorageKey(area.id),
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: FlowColors.parseProjectColor(area.color),
                shape: BoxShape.circle,
              ),
            ),
            title: Text(
              area.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: FlowColors.slate500,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: FlowColors.slate100,
                  valueColor: AlwaysStoppedAnimation<Color>(FlowColors.parseProjectColor(area.color)),
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 12, color: FlowColors.parseProjectColor(area.color), fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(LucideIcons.chevronDown, size: 16),
              ],
            ),
            children: [
              if (areaSubjects.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No subjects yet', style: TextStyle(color: FlowColors.slate400, fontSize: 13, fontStyle: FontStyle.italic)),
                )
              else
                ...areaSubjects.map((subject) => _buildSubjectTile(context, ref, subject, FlowColors.parseProjectColor(area.color))),
              ListTile(
                dense: true,
                leading: Icon(LucideIcons.plus, size: 18, color: FlowColors.parseProjectColor(area.color)),
                title: Text('Add Subject', style: TextStyle(color: FlowColors.parseProjectColor(area.color), fontWeight: FontWeight.w600)),
                onTap: () => _showAddSubject(context, area.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectTile(BuildContext context, WidgetRef ref, Subject subject, Color areaColor) {
    final state = ref.watch(studyNotifierProvider);
    final notifier = ref.read(studyNotifierProvider.notifier);
    final lessons = state.lessons.where((l) => l.subjectId == subject.id).toList();
    final progress = notifier.getSubjectProgress(subject.id);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: FlowCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: 0,
        child: ExpansionTile(
          key: PageStorageKey(subject.id),
          title: Text(
            subject.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: FlowColors.slate100,
                valueColor: AlwaysStoppedAnimation<Color>(areaColor),
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 12, color: areaColor, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronDown, size: 16),
            ],
          ),
          children: [
            ...lessons.map((lesson) => ListTile(
              dense: true,
              leading: Checkbox(
                value: lesson.isCompleted,
                onChanged: (_) => notifier.toggleLesson(lesson.id),
                activeColor: areaColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              title: Text(
                lesson.title,
                style: TextStyle(
                  decoration: lesson.isCompleted ? TextDecoration.lineThrough : null,
                  color: lesson.isCompleted ? FlowColors.slate400 : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent),
                onPressed: () => notifier.deleteLesson(lesson.id),
              ),
            )),
            ListTile(
              dense: true,
              leading: Icon(LucideIcons.plus, size: 18, color: areaColor),
              title: Text('Add Lesson', style: TextStyle(color: areaColor, fontWeight: FontWeight.w600)),
              onTap: () => _showAddLesson(context, subject.id),
            ),
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

  void _showAddSubject(BuildContext context, String areaId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StudyEditSheet(type: StudyEntryType.subject, parentId: areaId),
    );
  }

  void _showAddLesson(BuildContext context, String subjectId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StudyEditSheet(type: StudyEntryType.lesson, parentId: subjectId),
    );
  }
}
