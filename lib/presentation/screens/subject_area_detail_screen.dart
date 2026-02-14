import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/ui_components.dart';
import '../../core/study_notifier.dart';
import '../../data/models/study_models.dart';
import '../widgets/study_edit_sheet.dart';
import '../widgets/undo_toast.dart';

class SubjectAreaDetailScreen extends ConsumerWidget {
  final SubjectArea area;

  const SubjectAreaDetailScreen({super.key, required this.area});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyAsync = ref.watch(studyNotifierProvider);


    return Scaffold(
      extendBody: true,
      body: studyAsync.when(
        data: (state) {
          // Watch the area from state to keep it reactive to edits
          final currentArea = state.areas.firstWhere((a) => a.id == area.id, orElse: () => area);
          final areaSubjects = state.subjects.where((s) => s.areaId == area.id).toList();
          
          final progress = ref.read(studyNotifierProvider.notifier).getAreaProgress(area.id);
          
          int totalLessons = 0;
          int completedLessons = 0;
          for (var subject in areaSubjects) {
            final lessons = state.lessons.where((l) => l.subjectId == subject.id).toList();
            totalLessons += lessons.length;
            completedLessons += lessons.where((l) => l.isCompleted).length;
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, ref, currentArea),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    children: [
                      _buildProgressCard(context, progress, completedLessons, totalLessons, currentArea),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SUBJECTS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              color: FlowColors.slate400,
                            ),
                          ),
                          FlowBadge(
                            label: '${areaSubjects.length} SUBJECTS',
                            color: FlowColors.parseProjectColor(currentArea.color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (areaSubjects.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          Icon(LucideIcons.bookOpen, size: 48, color: FlowColors.slate200),
                          const SizedBox(height: 16),
                          const Text('No subjects yet', style: TextStyle(color: FlowColors.slate400, fontSize: 13, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final subject = areaSubjects[index];
                      final subjectLessons = state.lessons.where((l) => l.subjectId == subject.id).toList();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: _buildSubjectCard(context, ref, subject, subjectLessons, currentArea),
                      );
                    },
                    childCount: areaSubjects.length,
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildAddSubjectButton(context, ref, currentArea.id),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref, SubjectArea currentArea) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildActionCircle(LucideIcons.chevronLeft, () => Navigator.pop(context)),
      ),
      title: Text(
        currentArea.name,
        style: TextStyle(
          color: isDark ? Colors.white : FlowColors.textLight,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          fontFamily: 'Outfit',
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildActionCircle(LucideIcons.edit3, () => _showEditArea(context, ref, currentArea)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 16.0),
          child: _buildActionCircle(LucideIcons.trash2, () => _confirmDelete(context, ref, currentArea), color: Colors.red.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  void _showEditArea(BuildContext context, WidgetRef ref, SubjectArea currentArea) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StudyEditSheet(
        type: StudyEntryType.area,
        area: currentArea,
      ),
    );
  }

  Widget _buildActionCircle(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: FlowColors.surfaceDark.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color ?? FlowColors.slate500),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, double progress, int completed, int total, SubjectArea area) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final areaColor = FlowColors.parseProjectColor(area.color);
    final tintedBg = FlowColors.getTintedBackground(areaColor, isDark);
    final textColor = FlowColors.getContrastTextColor(tintedBg);
    final secondaryColor = FlowColors.getContrastSecondaryColor(tintedBg);
    
    return FlowCard(
      useGlass: true,
      backgroundColor: tintedBg,
      padding: 24,
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : FlowColors.slate100,
                  valueColor: AlwaysStoppedAnimation<Color>(areaColor),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completed / $total Lessons',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total subject area progress',
                  style: TextStyle(
                    fontSize: 12, 
                    color: secondaryColor, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, WidgetRef ref, Subject subject, List<Lesson> lessons, SubjectArea area) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final areaColor = FlowColors.parseProjectColor(area.color);
    final progress = ref.read(studyNotifierProvider.notifier).getSubjectProgress(subject.id);
    

    return FlowCard(
      padding: 0,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(subject.id),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            subject.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : FlowColors.slate100,
                      valueColor: AlwaysStoppedAnimation<Color>(areaColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: areaColor),
                ),
              ],
            ),
          ),
          children: [
            const Divider(height: 1),
            ...lessons.map((lesson) => _buildLessonTile(context, ref, lesson, areaColor)),
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: Icon(LucideIcons.plus, size: 18, color: areaColor),
              title: Text('Add Lesson', style: TextStyle(color: areaColor, fontWeight: FontWeight.w600)),
              onTap: () => _showAddLesson(context, subject.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonTile(BuildContext context, WidgetRef ref, Lesson lesson, Color activeColor) {
    final notifier = ref.read(studyNotifierProvider.notifier);
    
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 8, right: 12),
      leading: Checkbox(
        value: lesson.isCompleted,
        onChanged: (_) => notifier.toggleLesson(lesson.id),
        activeColor: activeColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      title: Text(
        lesson.title,
        style: TextStyle(
          decoration: lesson.isCompleted ? TextDecoration.lineThrough : null,
          color: lesson.isCompleted ? FlowColors.slate400 : null,
          fontSize: 14,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent),
        onPressed: () {
          notifier.deleteLesson(lesson);
          UndoToast.show(
            context: context,
            message: 'Lesson moved to Trash',
            onUndo: () => notifier.restoreLesson(lesson.id),
          );
        },
      ),
    );
  }

  Widget _buildAddSubjectButton(BuildContext context, WidgetRef ref, String areaId) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => StudyEditSheet(
            type: StudyEntryType.subject,
            parentId: areaId,
          ),
        );
      },
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : FlowColors.slate200,
            width: 1,
            style: BorderStyle.solid, // Or use a custom dash painter if needed, but solid is fine for now
          ),
          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : FlowColors.slate50,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.plus, size: 18, color: FlowColors.slate400),
            ),
            const SizedBox(width: 16),
            const Text(
              'Add a new subject',
              style: TextStyle(
                fontSize: 14,
                color: FlowColors.slate400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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

  void _confirmDelete(BuildContext context, WidgetRef ref, SubjectArea currentArea) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject Area?'),
        content: const Text('This will delete the area and all its subjects and lessons. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              ref.read(studyNotifierProvider.notifier).deleteArea(currentArea);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to Study list
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
