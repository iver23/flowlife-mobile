import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/models.dart';
import 'ui_components.dart';

class TaskEditSheet extends StatefulWidget {
  final TaskModel task;
  final Function(TaskModel) onSave;

  const TaskEditSheet({super.key, required this.task, required this.onSave});

  @override
  State<TaskEditSheet> createState() => _TaskEditSheetState();
}

class _TaskEditSheetState extends State<TaskEditSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late EnergyLevel? _energyLevel;
  late List<Subtask> _subtasks;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _energyLevel = widget.task.energyLevel;
    _subtasks = List.from(widget.task.subtasks);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? FlowColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Task',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Task Title',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add a description...',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14, color: FlowColors.slate500),
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text(
              'ENERGY LEVEL',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildEnergyChip(EnergyLevel.LOW, LucideIcons.coffee, 'Low'),
                const SizedBox(width: 8),
                _buildEnergyChip(EnergyLevel.MEDIUM, LucideIcons.smile, 'Med'),
                const SizedBox(width: 8),
                _buildEnergyChip(EnergyLevel.HIGH, LucideIcons.zap, 'High'),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'SUBTASKS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500),
            ),
            const SizedBox(height: 12),
            ..._subtasks.map((st) => _buildSubtaskItem(st)),
            _buildAddSubtaskField(),
            const SizedBox(height: 40),
            FlowButton(
              label: 'SAVE CHANGES',
              onPressed: () {
                final updatedTask = TaskModel(
                  id: widget.task.id,
                  title: _titleController.text,
                  description: _descController.text,
                  projectId: widget.task.projectId,
                  dueDate: widget.task.dueDate,
                  recurrence: widget.task.recurrence,
                  completed: widget.task.completed,
                  completedAt: widget.task.completedAt,
                  energyLevel: _energyLevel,
                  subtasks: _subtasks,
                  createdAt: widget.task.createdAt,
                  order: widget.task.order,
                );
                widget.onSave(updatedTask);
                Navigator.pop(context);
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyChip(EnergyLevel level, IconData icon, String label) {
    bool isSelected = _energyLevel == level;
    return GestureDetector(
      onTap: () => setState(() => _energyLevel = level),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? FlowColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? FlowColors.primary : FlowColors.slate500.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? FlowColors.primary : FlowColors.slate500),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? FlowColors.primary : FlowColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtaskItem(Subtask st) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            st.completed ? LucideIcons.checkCircle2 : LucideIcons.circle,
            size: 18,
            color: st.completed ? Colors.green : FlowColors.slate500,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              st.title,
              style: TextStyle(
                fontSize: 14,
                decoration: st.completed ? TextDecoration.lineThrough : null,
                color: st.completed ? FlowColors.slate500 : null,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _subtasks.removeWhere((item) => item.id == st.id);
              });
            },
            icon: const Icon(LucideIcons.trash2, size: 16, color: FlowColors.slate500),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSubtaskField() {
    return TextField(
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          setState(() {
            _subtasks.add(Subtask(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: value,
              completed: false,
            ));
          });
        }
      },
      decoration: const InputDecoration(
        hintText: 'Add a subtask...',
        hintStyle: TextStyle(fontSize: 14, color: FlowColors.slate500),
        icon: Icon(LucideIcons.plus, size: 18, color: FlowColors.slate500),
        border: InputBorder.none,
      ),
    );
  }
}
