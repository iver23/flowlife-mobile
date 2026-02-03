import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/dashboard_widget_notifier.dart';
import '../widgets/ui_components.dart';
import '../../data/models/widget_model.dart';

class DashboardWidgetSettingsSheet extends ConsumerWidget {
  const DashboardWidgetSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widgetsAsync = ref.watch(dashboardWidgetProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 50),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isDark ? FlowColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customize Dashboard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: widgetsAsync.when(
              data: (widgets) => ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widgets.length,
                onReorder: (oldIndex, newIndex) {
                  ref.read(dashboardWidgetProvider.notifier).reorderWidgets(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final widget = widgets[index];
                  return Container(
                    key: ValueKey(widget.id),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? FlowColors.surfaceDark.withOpacity(0.3) : FlowColors.slate50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.gripVertical, size: 20, color: FlowColors.slate400),
                          const SizedBox(width: 16),
                          Icon(_getIcon(widget.type), size: 18, color: FlowColors.primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Switch(
                            value: widget.isEnabled,
                            activeColor: FlowColors.primary,
                            onChanged: (val) {
                              ref.read(dashboardWidgetProvider.notifier).toggleWidget(widget.id, val);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  IconData _getIcon(WidgetType type) {
    switch (type) {
      case WidgetType.stats: return LucideIcons.barChart2;
      case WidgetType.habits: return LucideIcons.flame;
      case WidgetType.tasks: return LucideIcons.checkSquare;
      case WidgetType.projects: return LucideIcons.folder;
      case WidgetType.ideas: return LucideIcons.lightbulb;
      case WidgetType.achievements: return LucideIcons.trophy;
    }
  }
}
