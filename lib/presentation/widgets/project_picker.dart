import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/project_notifier.dart';
import '../../data/models/models.dart';
import 'ui_components.dart';

class ProjectPicker extends ConsumerWidget {
  final String? selectedProjectId;
  final Function(String?) onSelected;

  const ProjectPicker({
    super.key,
    required this.selectedProjectId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TAG PROJECT',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: projectsAsync.when(
            data: (projects) {
              return ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...projects.map((p) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildChip(
                      context,
                      label: p.title,
                      isSelected: selectedProjectId == p.id,
                      onTap: () => onSelected(p.id),
                      icon: p.isSystemProject ? LucideIcons.hash : _parseIcon(p.icon),
                      color: FlowColors.parseProjectColor(p.color),
                    ),
                  )),
                ],
              );
            },
            loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            error: (_, __) => const Text('Error loading projects'),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : FlowColors.slate500.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? color : FlowColors.slate500),
            const SizedBox(width: 8),
            Text(
              label,
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


  IconData _parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'work': return LucideIcons.briefcase;
      case 'home': return LucideIcons.home;
      case 'favorite': return LucideIcons.heart;
      case 'bolt': return LucideIcons.zap;
      case 'menu_book': return LucideIcons.book;
      case 'coffee': return LucideIcons.coffee;
      case 'globe': return LucideIcons.globe;
      case 'anchor': return LucideIcons.anchor;
      case 'dumbbell': return LucideIcons.dumbbell;
      case 'shopping_cart': return LucideIcons.shoppingCart;
      case 'plane': return LucideIcons.plane;
      case 'music': return LucideIcons.music;
      case 'dog': return LucideIcons.dog;
      case 'flower': return LucideIcons.flower;
      case 'code': return LucideIcons.code;
      case 'banknote': return LucideIcons.banknote;
      default: return LucideIcons.folder;
    }
  }
}
