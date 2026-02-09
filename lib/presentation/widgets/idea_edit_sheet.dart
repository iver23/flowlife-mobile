import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/models.dart';
import 'ui_components.dart';
import 'project_picker.dart';

class IdeaEditSheet extends StatefulWidget {
  final IdeaModel idea;
  final Function(IdeaModel) onSave;

  const IdeaEditSheet({super.key, required this.idea, required this.onSave});

  @override
  State<IdeaEditSheet> createState() => _IdeaEditSheetState();
}

class _IdeaEditSheetState extends State<IdeaEditSheet> {
  late TextEditingController _contentController;
  late String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.idea.content);
    _selectedProjectId = widget.idea.projectId;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Idea',
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
              controller: _contentController,
              maxLines: 5,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 16, color: FlowColors.slate500),
              ),
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'ASSIGN TO PROJECT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: FlowColors.slate400,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ProjectPicker(
              selectedProjectId: _selectedProjectId,
              onSelected: (id) => setState(() => _selectedProjectId = id),
            ),
            const SizedBox(height: 40),
            FlowButton(
              label: 'SAVE CHANGES',
              onPressed: () {
                if (_contentController.text.trim().isEmpty) {
                  Navigator.pop(context);
                  return;
                }
                
                final updatedIdea = widget.idea.copyWith(
                  content: _contentController.text.trim(),
                  projectId: _selectedProjectId,
                );
                
                widget.onSave(updatedIdea);
                Navigator.pop(context);
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
