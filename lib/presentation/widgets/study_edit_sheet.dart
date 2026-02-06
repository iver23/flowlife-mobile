import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'ui_components.dart';
import '../../core/study_notifier.dart';

enum StudyEntryType { area, subject, lesson }

class StudyEditSheet extends ConsumerStatefulWidget {
  final StudyEntryType type;
  final String? parentId;

  const StudyEditSheet({
    super.key,
    required this.type,
    this.parentId,
  });

  @override
  ConsumerState<StudyEditSheet> createState() => _StudyEditSheetState();
}

class _StudyEditSheetState extends ConsumerState<StudyEditSheet> {
  final _nameController = TextEditingController();
  String _selectedColor = 'duskblue';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_nameController.text.trim().isEmpty) return;

    final notifier = ref.read(studyNotifierProvider.notifier);
    
    switch (widget.type) {
      case StudyEntryType.area:
        notifier.addArea(_nameController.text.trim(), _selectedColor);
        break;
      case StudyEntryType.subject:
        notifier.addSubject(widget.parentId!, _nameController.text.trim());
        break;
      case StudyEntryType.lesson:
        notifier.addLesson(widget.parentId!, _nameController.text.trim());
        break;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == StudyEntryType.area 
        ? 'Add Subject Area' 
        : (widget.type == StudyEntryType.subject ? 'Add Subject' : 'Add Lesson');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter name...',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.08) 
                  : FlowColors.slate50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onSubmitted: (_) => _handleSubmit(),
          ),
          if (widget.type == StudyEntryType.area) ...[
            const SizedBox(height: 24),
            const Text('Choose Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: FlowColors.slate500)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildColorOption('duskblue'),
                _buildColorOption('lavender'),
                _buildColorOption('rosewood'),
                _buildColorOption('coral'),
                _buildColorOption('bronze'),
              ],
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: FlowColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Add Entry', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(String colorName) {
    final color = FlowColors.parseProjectColor(colorName);
    final isSelected = _selectedColor == colorName;

    return GestureDetector(
      onTap: () => setState(() => _selectedColor = colorName),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)] : null,
        ),
        child: isSelected ? const Icon(LucideIcons.check, color: Colors.white, size: 20) : null,
      ),
    );
  }
}
