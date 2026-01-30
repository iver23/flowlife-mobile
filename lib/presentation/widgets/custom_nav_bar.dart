import 'dart:ui';
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
    LucideIcons.settings,   // Settings
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? FlowColors.surfaceDark.withOpacity(0.8) : Colors.white.withOpacity(0.9);

    Widget bar = Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      height: 72,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_icons.length, (index) {
          return Expanded(
            child: _buildNavItem(index, _icons[index]),
          );
        }),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: bar,
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isActive ? 1.0 : 0.0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isActive) ? FlowColors.primary.withOpacity(0.12) : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Icon(
            icon,
            color: isActive ? FlowColors.primary : FlowColors.slate400,
            size: 24,
          ),
        ],
      ),
    );
  }
}
