import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/models.dart';
import 'ui_components.dart';
import 'ui_components.dart';
import 'project_picker.dart';

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
  late UrgencyLevel _urgencyLevel;
  late String? _selectedProjectId;
  late bool _isPinned;
  late List<Subtask> _subtasks;
  late RecurrenceType _recurrence;
  late bool _reminderEnabled;
  late DateTime? _reminderTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _urgencyLevel = widget.task.urgencyLevel;
    _subtasks = List.from(widget.task.subtasks);
    _selectedProjectId = widget.task.projectId;
    _isPinned = widget.task.isPinned;
    _recurrence = widget.task.recurrence;
    _reminderEnabled = widget.task.reminderEnabled;
    _reminderTime = widget.task.reminderTime != null ? DateTime.fromMillisecondsSinceEpoch(widget.task.reminderTime!) : null;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? FlowColors.surfaceDark : Colors.white,
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
                  onPressed: () => setState(() => _isPinned = !_isPinned),
                  icon: Icon(
                    _isPinned ? LucideIcons.pin : LucideIcons.pinOff,
                    size: 20,
                    color: _isPinned ? FlowColors.primary : FlowColors.slate400,
                  ),
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
              'URGENCY',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildUrgencyChip(UrgencyLevel.planning, LucideIcons.calendar, 'Planning'),
                  const SizedBox(width: 8),
                  _buildUrgencyChip(UrgencyLevel.low, LucideIcons.clock, 'Low'),
                  const SizedBox(width: 8),
                  _buildUrgencyChip(UrgencyLevel.moderate, LucideIcons.alertCircle, 'Moderate'),
                  const SizedBox(width: 8),
                  _buildUrgencyChip(UrgencyLevel.urgent, LucideIcons.alertTriangle, 'Urgent'),
                  const SizedBox(width: 8),
                  _buildUrgencyChip(UrgencyLevel.critical, LucideIcons.flame, 'Critical'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ProjectPicker(
              selectedProjectId: _selectedProjectId,
              onSelected: (id) => setState(() => _selectedProjectId = id),
            ),
            const SizedBox(height: 32),
            const Text(
              'SUBTASKS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500),
            ),
            const SizedBox(height: 12),
            ..._subtasks.map((st) => _buildSubtaskItem(st)),
            _buildAddSubtaskField(),
            const SizedBox(height: 32),
            const Text(
              'REPEAT',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRecurrenceChip(RecurrenceType.NONE, 'None'),
                  const SizedBox(width: 8),
                  _buildRecurrenceChip(RecurrenceType.DAILY, 'Daily'),
                  const SizedBox(width: 8),
                  _buildRecurrenceChip(RecurrenceType.WEEKLY, 'Weekly'),
                  const SizedBox(width: 8),
                  _buildRecurrenceChip(RecurrenceType.MONTHLY, 'Monthly'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'REMINDER',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500),
            ),
            const SizedBox(height: 12),
            _buildReminderToggle(),
            if (_reminderEnabled) _buildReminderTimePicker(context),
            const SizedBox(height: 40),
            FlowButton(
              label: 'SAVE CHANGES',
              onPressed: () {
                final updatedTask = TaskModel(
                  id: widget.task.id,
                  title: _titleController.text,
                  description: _descController.text,
                  dueDate: widget.task.dueDate,
                  recurrence: _recurrence,
                  completed: widget.task.completed,
                  completedAt: widget.task.completedAt,
                  urgencyLevel: _urgencyLevel,
                  projectId: _selectedProjectId,
                  isPinned: _isPinned,
                  subtasks: _subtasks,
                  createdAt: widget.task.createdAt,
                  order: widget.task.order,
                  reminderEnabled: _reminderEnabled,
                  reminderTime: _reminderTime?.millisecondsSinceEpoch,
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

  Widget _buildUrgencyChip(UrgencyLevel level, IconData icon, String label) {
    bool isSelected = _urgencyLevel == level;
    final color = Color(level.colorValue);
    
    return GestureDetector(
      onTap: () => setState(() => _urgencyLevel = level),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : FlowColors.slate500.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? color : FlowColors.slate500),
            const SizedBox(width: 6),
            Text(
              level.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : FlowColors.slate500,
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

  Widget _buildRecurrenceChip(RecurrenceType type, String label) {
    bool isSelected = _recurrence == type;
    return GestureDetector(
      onTap: () => setState(() => _recurrence = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? FlowColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? FlowColors.primary : FlowColors.slate500.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? FlowColors.primary : FlowColors.slate500,
          ),
        ),
      ),
    );
  }

  Widget _buildReminderToggle() {
    return SwitchListTile(
      title: const Text('Enable Reminder', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      secondary: Icon(LucideIcons.bell, color: _reminderEnabled ? FlowColors.primary : FlowColors.slate400, size: 20),
      value: _reminderEnabled,
      onChanged: (val) => setState(() => _reminderEnabled = val),
      contentPadding: EdgeInsets.zero,
      activeColor: FlowColors.primary,
    );
  }

  Widget _buildReminderTimePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: InkWell(
        onTap: () async {
          final now = DateTime.now();
          final date = await showDatePicker(
            context: context,
            initialDate: _reminderTime ?? now,
            firstDate: now,
            lastDate: now.add(const Duration(days: 365)),
          );
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(_reminderTime ?? now),
            );
            if (time != null) {
              setState(() {
                _reminderTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
              });
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FlowColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FlowColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.calendarDays, size: 16, color: FlowColors.primary),
              const SizedBox(width: 12),
              Text(
                _reminderTime == null ? 'Set reminder time' : '${_reminderTime!.year}-${_reminderTime!.month}-${_reminderTime!.day} ${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: FlowColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
