import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme_notifier.dart';
import 'ui_components.dart';

class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final selection = themeState.selection;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : FlowColors.slate100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = (constraints.maxWidth) / 3;
          
          return Stack(
            children: [
              // Sliding background highlight
              AnimatedPositioned(
                duration: FlowAnimations.normal,
                curve: FlowAnimations.defaultCurve,
                left: _getOffset(selection, segmentWidth),
                child: Container(
                  width: segmentWidth,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? FlowColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Buttons
              Row(
                children: [
                  _buildSegment(context, ref, 'Light', ThemeSelection.light, segmentWidth),
                  _buildSegment(context, ref, 'Dark', ThemeSelection.dark, segmentWidth),
                  _buildSegment(context, ref, 'System', ThemeSelection.system, segmentWidth),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  double _getOffset(ThemeSelection selection, double width) {
    switch (selection) {
      case ThemeSelection.light:
        return 0;
      case ThemeSelection.dark:
        return width;
      case ThemeSelection.system:
        return width * 2;
      default:
        return 0;
    }
  }

  Widget _buildSegment(
    BuildContext context, 
    WidgetRef ref, 
    String label, 
    ThemeSelection selection, 
    double width
  ) {
    final currentSelection = ref.watch(themeNotifierProvider).selection;
    final isActive = currentSelection == selection;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => ref.read(themeNotifierProvider.notifier).setThemeSelection(selection),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: 40,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive 
                ? (isDark ? Colors.white : FlowColors.textLight)
                : FlowColors.slate500,
            ),
          ),
        ),
      ),
    );
  }
}
