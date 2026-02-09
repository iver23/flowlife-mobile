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
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.projectTitle,
    required this.projectIcon,
    required this.projectColor,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(task.id),
      movementDuration: FlowAnimations.normal,
      resizeDuration: FlowAnimations.normal,
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Circular Indicator or Checkbox
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (isSelectionMode) {
                    onSelectionToggle?.call();
                  } else {
                    onToggle();
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelectionMode
                        ? (isSelected ? FlowColors.primary : Colors.transparent)
                        : (task.completed ? FlowColors.primary : Colors.transparent),
                    shape: isSelectionMode ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: isSelectionMode ? BorderRadius.circular(6) : null,
                    border: Border.all(
                      color: isSelectionMode
                          ? (isSelected ? FlowColors.primary : FlowColors.slate200)
                          : (task.completed ? FlowColors.primary : FlowColors.slate200),
                      width: 2,
                    ),
                  ),
                  child: (isSelectionMode ? isSelected : task.completed)
                      ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: task.completed ? TextDecoration.lineThrough : null,
                        color: task.completed
                            ? FlowColors.slate400
                            : (isDark ? Colors.white : FlowColors.textLight),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (task.dueDate != null)
                          _buildChip(
                            label: DateFormatter.format(task.dueDate!),
                            icon: LucideIcons.calendar,
                            color: DateFormatter.isOverdue(task.dueDate!, task.completed) 
                                ? Colors.red 
                                : FlowColors.slate400,
                          ),
                        if (task.subtasks.isNotEmpty)
                          _buildChip(
                            label: '${task.subtasks.where((s) => s.completed).length}/${task.subtasks.length}',
                            icon: LucideIcons.checkSquare,
                            color: FlowColors.slate400,
                          ),
                        _buildUrgencyChip(task.urgencyLevel),
                        _buildProjectChip(projectTitle, projectColor, projectIcon),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProjectChip(String title, Color color, String iconName) {
    return _buildChip(
      label: title,
      icon: _parseIcon(iconName),
      color: color,
    );
  }

  Widget _buildUrgencyChip(UrgencyLevel level) {
    final color = Color(level.colorValue);
    final icon = {
      UrgencyLevel.planning: LucideIcons.calendar,
      UrgencyLevel.low: LucideIcons.clock,
      UrgencyLevel.moderate: LucideIcons.alertCircle,
      UrgencyLevel.urgent: LucideIcons.alertTriangle,
      UrgencyLevel.critical: LucideIcons.flame,
    }[level]!;
    
    // Capitalize first letter of level.name
    final label = level.name[0].toUpperCase() + level.name.substring(1);

    return _buildChip(
      label: label,
      icon: icon,
      color: color,
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'work': return LucideIcons.briefcase;
      case 'home': return LucideIcons.home;
      case 'favorite': return LucideIcons.heart;
      case 'personal': return LucideIcons.user;
      case 'health': return LucideIcons.activity;
      case 'finance': return LucideIcons.wallet;
      case 'learning': return LucideIcons.book;
      case 'fitness': return LucideIcons.dumbbell;
      case 'shopping': return LucideIcons.shoppingCart;
      case 'social': return LucideIcons.users;
      default: return LucideIcons.folder;
    }
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
