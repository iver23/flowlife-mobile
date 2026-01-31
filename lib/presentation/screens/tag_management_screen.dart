import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/tag_notifier.dart';
import '../../data/models/tag_model.dart';
import '../widgets/ui_components.dart';

class TagManagementScreen extends ConsumerWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FlowColors.midnight : FlowColors.paper,
      appBar: AppBar(
        title: const Text('Manage Tags'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: tagsAsync.when(
        data: (tags) {
          if (tags.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.tag, size: 64, color: FlowColors.slate200),
                  const SizedBox(height: 16),
                  const Text(
                    'No tags yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FlowColors.slate400),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create tags while editing tasks.',
                    style: TextStyle(color: FlowColors.slate500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              final color = FlowColors.parseProjectColor(tag.color);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FlowCard(
                  padding: 16,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          tag.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(context, ref, tag),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, TagModel tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text('Are you sure you want to delete "${tag.name}"? This will remove the tag from all tasks and ideas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              ref.read(tagNotifierProvider.notifier).deleteTag(tag.id);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
