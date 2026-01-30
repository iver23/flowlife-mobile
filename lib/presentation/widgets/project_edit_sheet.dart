import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/models.dart';
import 'ui_components.dart';

class ProjectEditSheet extends StatefulWidget {
  final ProjectModel? project;
  final Function(ProjectModel) onSave;

  const ProjectEditSheet({super.key, this.project, required this.onSave});

  @override
  State<ProjectEditSheet> createState() => _ProjectEditSheetState();
}

class _ProjectEditSheetState extends State<ProjectEditSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedColor;
  late String _selectedIcon;
  late Importance _selectedWeight;
  late bool _isArchived;

  final List<String> _colors = ['emerald', 'blue', 'violet', 'rose', 'amber', 'cyan'];
  final List<String> _icons = [
    'work', 'home', 'favorite', 'bolt', 'menu_book', 'coffee', 
    'public', 'anchor', 'fitness_center', 'shopping_cart', 
    'flight', 'music_note', 'pets', 'spa', 'code', 'savings'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project?.title ?? '');
    _descController = TextEditingController(text: widget.project?.description ?? '');
    _selectedColor = widget.project?.color ?? 'blue';
    _selectedIcon = widget.project?.icon ?? 'work';
    _selectedWeight = widget.project?.weight ?? Importance.medium;
    _isArchived = widget.project?.isArchived ?? false;
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
                Text(
                  widget.project == null ? 'New Project' : 'Edit Project',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                hintText: 'Project Title',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Add a description...',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14, color: FlowColors.slate500),
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('IMPORTANCE'),
            const SizedBox(height: 12),
            _buildImportancePicker(),
            const SizedBox(height: 24),
            _buildSectionTitle('COLOR'),
            const SizedBox(height: 12),
            _buildColorPicker(),
            const SizedBox(height: 24),
            _buildIconPicker(),
            const SizedBox(height: 24),
            if (widget.project != null) ...[
              _buildSectionTitle('PROJECT STATUS'),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Archived', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Archived projects are hidden from the main view', style: TextStyle(fontSize: 12)),
                value: _isArchived,
                onChanged: (val) => setState(() => _isArchived = val),
                activeColor: FlowColors.primary,
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 40),
            FlowButton(
              label: widget.project == null ? 'CREATE PROJECT' : 'SAVE CHANGES',
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  final project = ProjectModel(
                    id: widget.project?.id ?? '',
                    title: _titleController.text,
                    description: _descController.text,
                    color: _selectedColor,
                    icon: _selectedIcon,
                    weight: _selectedWeight,
                    isArchived: _isArchived,
                  );
                  widget.onSave(project);
                  Navigator.pop(context);
                }
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500),
    );
  }

  Widget _buildImportancePicker() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: Importance.values.map((imp) {
          bool isSelected = _selectedWeight == imp;
          return GestureDetector(
            onTap: () => setState(() => _selectedWeight = imp),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? FlowColors.primary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? FlowColors.primary : FlowColors.slate500.withOpacity(0.2),
                ),
              ),
              child: Text(
                imp.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? FlowColors.primary : FlowColors.slate500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _colors.map((c) {
        bool isSelected = _selectedColor == c;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = c),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _parseColor(c),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
              boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)] : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _icons.map((iconName) {
        bool isSelected = _selectedIcon == iconName;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = iconName),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? FlowColors.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? FlowColors.primary : FlowColors.slate500.withOpacity(0.2),
              ),
            ),
            child: Icon(
              _parseIcon(iconName),
              size: 20,
              color: isSelected ? FlowColors.primary : FlowColors.slate500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _parseColor(String colorStr) {
    switch (colorStr.toLowerCase()) {
      case 'emerald': return Colors.green;
      case 'blue': return Colors.blue;
      case 'violet': return Colors.purple;
      case 'rose': return Colors.pink;
      case 'amber': return Colors.amber;
      case 'cyan': return Colors.cyan;
      default: return FlowColors.primary;
    }
  }

  IconData _parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'work': return LucideIcons.briefcase;
      case 'home': return LucideIcons.home;
      case 'favorite': return LucideIcons.heart;
      case 'bolt': return LucideIcons.zap;
      case 'menu_book': return LucideIcons.book;
      case 'coffee': return LucideIcons.coffee;
      case 'public': return LucideIcons.globe;
      case 'anchor': return LucideIcons.anchor;
      case 'fitness_center': return LucideIcons.dumbbell;
      case 'shopping_cart': return LucideIcons.shoppingCart;
      case 'flight': return LucideIcons.plane;
      case 'music_note': return LucideIcons.music;
      case 'pets': return LucideIcons.dog;
      case 'spa': return LucideIcons.flower;
      case 'code': return LucideIcons.code;
      case 'savings': return LucideIcons.banknote;
      default: return LucideIcons.folder;
    }
  }
}
