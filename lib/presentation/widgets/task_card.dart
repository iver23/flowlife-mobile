import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/models.dart';
import '../widgets/ui_components.dart';
import '../../core/date_formatter.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final String projectTitle;
  final String projectIcon;
  final Color projectColor;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final Map<String, Color> tagColors;

  const TaskCard({
    super.key,
    required this.task,
    required this.projectTitle,
    required this.projectIcon,
    required this.projectColor,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
    this.tagColors = const {},
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(task.id),
      background: _buildSwipeBackground(
        Alignment.centerLeft,
        Colors.green,
        LucideIcons.check,
        'Complete',
      ),
      secondaryBackground: _buildSwipeBackground(
        Alignment.centerRight,
        Colors.red,
        LucideIcons.trash2,
        'Delete',
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
        } else {
          onDelete();
        }
      },
      child: FlowCard(
        onTap: onTap,
        padding: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              // Circular Indicator
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onToggle();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: task.completed
                        ? FlowColors.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.completed ? FlowColors.primary : FlowColors.slate200,
                      width: 2,
                    ),
                  ),
                  child: task.completed
                      ? const Icon(LucideIcons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.completed ? TextDecoration.lineThrough : null,
                        color: task.completed
                            ? FlowColors.slate400
                            : (isDark ? Colors.white : FlowColors.textLight),
                      ),
                    ),
                    if (task.customTags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: task.customTags.map((tag) => FlowBadge(
                          label: tag, 
                          color: tagColors[tag] ?? FlowColors.slate500,
                        )).toList(),
                      ),
                    ],
                    if (task.dueDate != null || task.subtasks.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (task.dueDate != null) ...[
                            Icon(LucideIcons.calendar, size: 12, color: DateFormatter.isOverdue(task.dueDate!, task.completed) ? Colors.red.withOpacity(0.8) : FlowColors.slate400),
                            const SizedBox(width: 4),
                            Text(
                              DateFormatter.format(task.dueDate!),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: DateFormatter.isOverdue(task.dueDate!, task.completed) ? Colors.red.withOpacity(0.8) : FlowColors.slate400,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (task.subtasks.isNotEmpty) ...[
                            const Icon(LucideIcons.checkSquare, size: 12, color: FlowColors.slate400),
                            const SizedBox(width: 4),
                            Text(
                              '${task.subtasks.where((s) => s.completed).length}/${task.subtasks.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: FlowColors.slate400,
                              ),
                            ),
                          ],
                          const Spacer(),
                          FlowBadge(
                            label: projectTitle,
                            color: projectColor,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildEnergyIndicator(EnergyLevel level) {
    Color color;
    IconData icon;
    switch (level) {
      case EnergyLevel.LOW:
        color = FlowColors.slate400;
        icon = LucideIcons.coffee;
        break;
      case EnergyLevel.MEDIUM:
        color = Colors.blue;
        icon = LucideIcons.smile;
        break;
      case EnergyLevel.HIGH:
        color = Colors.amber;
        icon = LucideIcons.zap;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }

  Widget _buildSwipeBackground(
      Alignment alignment, Color color, IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (alignment == Alignment.centerRight) ...[
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white),
          ],
        ],
      ),
    );
  }
}
