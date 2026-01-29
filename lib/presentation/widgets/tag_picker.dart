import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/tag_notifier.dart';
import '../../data/models/tag_model.dart';
import 'ui_components.dart';

class TagPicker extends ConsumerWidget {
  final List<String> selectedTagNames;
  final Function(List<String>) onSelected;

  const TagPicker({
    super.key,
    required this.selectedTagNames,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CUSTOM TAGS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500, letterSpacing: 1.2),
            ),
            IconButton(
              onPressed: () => _showAddTagDialog(context, ref),
              icon: const Icon(LucideIcons.plus, size: 16, color: FlowColors.primary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: tagsAsync.when(
            data: (tags) {
              if (tags.isEmpty) {
                return const Text('No tags created yet.', style: TextStyle(fontSize: 12, color: FlowColors.slate500));
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final isSelected = selectedTagNames.contains(tag.name);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tag.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        final newList = List<String>.from(selectedTagNames);
                        if (selected) {
                          newList.add(tag.name);
                        } else {
                          newList.remove(tag.name);
                        }
                        onSelected(newList);
                      },
                      selectedColor: FlowColors.parseProjectColor(tag.color).withOpacity(0.2),
                      checkmarkColor: FlowColors.parseProjectColor(tag.color),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? FlowColors.parseProjectColor(tag.color) : FlowColors.slate500,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.transparent,
                      shape: StadiumBorder(side: BorderSide(
                        color: isSelected ? FlowColors.parseProjectColor(tag.color) : FlowColors.slate400.withOpacity(0.2),
                      )),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            error: (_, __) => const Text('Error loading tags'),
          ),
        ),
      ],
    );
  }

  void _showAddTagDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    String selectedColor = 'blue';
    final colors = ['blue', 'emerald', 'violet', 'rose', 'amber', 'cyan'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Tag name (e.g. #urgent)'),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: colors.map((c) => GestureDetector(
                  onTap: () => setDialogState(() => selectedColor = c),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: FlowColors.parseProjectColor(c),
                      shape: BoxShape.circle,
                      border: selectedColor == c ? Border.all(color: Colors.white, width: 2) : null,
                      boxShadow: selectedColor == c ? [BoxShadow(color: Colors.black26, blurRadius: 4)] : [],
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref.read(tagNotifierProvider.notifier).addTag(controller.text, selectedColor);
                  Navigator.pop(context);
                }
              },
              child: const Text('CREATE'),
            ),
          ],
        ),
      ),
    );
  }
}
