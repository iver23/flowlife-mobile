import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'ui_components.dart';

class FlowNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FlowNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<IconData> _icons = [
    LucideIcons.leaf,       // Projects
    LucideIcons.listTodo,   // Tasks
    LucideIcons.layers,     // Dashboard
    LucideIcons.bookmark,   // Ideas
    LucideIcons.settings,   // Study/Settings
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? FlowColors.cardDark : Colors.white;
    final dividerColor = isDark ? FlowColors.slate500 : FlowColors.slate400.withOpacity(0.5);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 64,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_icons.length * 2 - 1, (i) {
          // Odd indices are dividers
          if (i.isOdd) {
            return Container(
              width: 1,
              height: 28,
              color: dividerColor,
            );
          }
          final index = i ~/ 2;
          return Expanded(
            child: _buildNavItem(index, _icons[index]),
          );
        }),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Icon(
          icon,
          color: isActive ? FlowColors.primary : FlowColors.slate400,
          size: 24,
        ),
      ),
    );
  }
}
