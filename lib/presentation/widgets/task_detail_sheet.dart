import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../data/models/models.dart';
import '../../core/providers.dart';
import 'ui_components.dart';
import 'task_edit_sheet.dart';

class TaskDetailSheet extends ConsumerWidget {
  final TaskModel task;

  const TaskDetailSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projects = ref.watch(projectsProvider).value ?? [];
    final project = projects.firstWhere(
      (p) => p.id == task.projectId,
      orElse: () => ProjectModel(
        id: 'other',
        title: 'Other',
        color: 'slate',
        icon: 'hash',
        weight: Importance.low,
        isSystemProject: true,
      ),
    );
    final projectColor = FlowColors.parseProjectColor(project.color);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? FlowColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: projectColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(_getIconData(project.icon), size: 12, color: projectColor),
                    const SizedBox(width: 6),
                    Text(
                      project.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: projectColor,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      final firestore = ref.read(firestoreServiceProvider);
                      Navigator.pop(context); // Close detail sheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => TaskEditSheet(
                          task: task,
                          onSave: (updatedTask) {
                            firestore.updateTask(updatedTask);
                          },
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.edit3, size: 20, color: FlowColors.slate500),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, size: 20, color: FlowColors.slate500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.description!,
              style: const TextStyle(
                fontSize: 16,
                color: FlowColors.slate500,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Details Grid
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              if (task.dueDate != null)
                _DetailTile(
                  icon: LucideIcons.calendarDays,
                  label: 'DUE DATE',
                  value: DateFormat('MMM d, yyyy').format(task.dueDate!),
                ),
              _DetailTile(
                icon: _getUrgencyIcon(task.urgencyLevel),
                label: 'URGENCY',
                value: task.urgencyLevel.label,
                valueColor: Color(task.urgencyLevel.colorValue),
              ),
              if (task.recurrence != RecurrenceType.none)
                _DetailTile(
                  icon: LucideIcons.repeat,
                  label: 'REPEAT',
                  value: task.recurrence.name,
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Subtasks
          if (task.subtasks.isNotEmpty) ...[
            const Text(
              'SUBTASKS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: FlowColors.slate400,
              ),
            ),
            const SizedBox(height: 12),
            ...task.subtasks.map((st) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    st.completed ? LucideIcons.checkCircle2 : LucideIcons.circle,
                    size: 16,
                    color: st.completed ? Colors.green : FlowColors.slate400,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    st.title,
                    style: TextStyle(
                      fontSize: 14,
                      decoration: st.completed ? TextDecoration.lineThrough : null,
                      color: st.completed ? FlowColors.slate400 : null,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
          ], // This was missing
          const SizedBox(height: 12),
          // Complete Button
          FlowButton(
            label: task.completed ? 'MARK AS UNCOMPLETE' : 'COMPLETE TASK',
            onPressed: () {
              final updatedTask = task.copyWith(
                completed: !task.completed,
                completedAt: !task.completed ? DateTime.now().millisecondsSinceEpoch : null,
              );
              ref.read(firestoreServiceProvider).updateTask(updatedTask);
              Navigator.pop(context);
            },
            isFullWidth: true,
            backgroundColor: task.completed ? FlowColors.slate200 : FlowColors.primary,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'anchor': return LucideIcons.anchor;
      case 'box': return LucideIcons.box;
      case 'heart': return LucideIcons.heart;
      case 'code': return LucideIcons.code;
      case 'shoppingcart': return LucideIcons.shoppingCart;
      default: return LucideIcons.layout;
    }
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

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: FlowColors.slate400),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: FlowColors.slate400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value.titleCase,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String get titleCase => this[0].toUpperCase() + substring(1).toLowerCase();
}
