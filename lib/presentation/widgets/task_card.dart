import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/models.dart';
import '../widgets/ui_components.dart';
import '../../core/date_formatter.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final String projectIcon;
  final Color projectColor;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.projectIcon,
    required this.projectColor,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
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
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Checkbox / Icon
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onToggle();
                },
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 1.0),
                  duration: const Duration(milliseconds: 100),
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: task.completed
                            ? Colors.green.withOpacity(isDark ? 0.2 : 0.1)
                            : projectColor.withOpacity(isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        task.completed ? LucideIcons.check : LucideIcons.circle,
                        size: 20,
                        color: task.completed ? Colors.green : projectColor,
                      ),
                    ),
                  ),
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: task.completed ? TextDecoration.lineThrough : null,
                        color: task.completed
                            ? FlowColors.slate500
                            : (isDark ? Colors.white : FlowColors.textLight),
                      ),
                    ),
                    if (task.description != null && !task.completed) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: FlowColors.slate500,
                        ),
                      ),
                    ],
                    if (task.dueDate != null || task.subtasks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (task.dueDate != null) ...[
                            Icon(LucideIcons.calendar, size: 10, color: DateFormatter.isOverdue(task.dueDate!, task.completed) ? Colors.red : FlowColors.slate500),
                            const SizedBox(width: 4),
                            Text(
                              DateFormatter.format(task.dueDate!),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: DateFormatter.isOverdue(task.dueDate!, task.completed) ? Colors.red : FlowColors.slate500,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (task.subtasks.isNotEmpty) ...[
                            const Icon(LucideIcons.checkSquare, size: 10, color: FlowColors.slate500),
                            const SizedBox(width: 4),
                            Text(
                              '${task.subtasks.where((s) => s.completed).length}/${task.subtasks.length}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: FlowColors.slate500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (task.energyLevel != null && !task.completed) ...[
                const SizedBox(width: 8),
                _buildEnergyIndicator(task.energyLevel!),
              ],
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
