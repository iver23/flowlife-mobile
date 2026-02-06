import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/habit_notifier.dart';
import '../../data/models/habit_model.dart';
import 'ui_components.dart';

class HabitStreakCard extends ConsumerWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onSettingsTap;

  const HabitStreakCard({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return habitsAsync.when(
      data: (habits) {
        if (habits.isEmpty) {
          return const SizedBox.shrink();
        }

        final completedCount = habits.where((h) => h.isCompletedToday).length;

        return FlowCard(
          padding: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'HABITS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: FlowColors.slate400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                          size: 14,
                          color: FlowColors.slate400,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '$completedCount/${habits.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? FlowColors.slate400 : FlowColors.slate500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: onSettingsTap,
                          child: Icon(
                            LucideIcons.settings,
                            size: 16,
                            color: FlowColors.slate400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Progress bar (always visible)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: habits.isEmpty ? 0.0 : completedCount / habits.length,
                  backgroundColor: isDark ? Colors.white.withOpacity(0.1) : FlowColors.slate100,
                  valueColor: AlwaysStoppedAnimation<Color>(FlowColors.primary),
                  minHeight: 6,
                ),
              ),
              // Expanded: show all habits with smooth animation
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          ...habits.map((habit) => _buildHabitRow(context, ref, habit, isDark)),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
      loading: () => const FlowCard(
        padding: 20,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildHabitRow(BuildContext context, WidgetRef ref, HabitModel habit, bool isDark) {
    final streakColor = habit.currentStreak >= 7
        ? Colors.orange
        : (habit.currentStreak >= 3 ? Colors.amber : FlowColors.primary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () {
              if (!habit.isCompletedToday) {
                ref.read(habitNotifierProvider.notifier).completeHabitToday(habit);
              }
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: habit.isCompletedToday
                    ? FlowColors.primary
                    : (isDark ? Colors.white.withOpacity(0.05) : FlowColors.slate100),
                borderRadius: BorderRadius.circular(8),
                border: habit.isCompletedToday
                    ? null
                    : Border.all(color: FlowColors.slate200),
              ),
              child: habit.isCompletedToday
                  ? const Icon(LucideIcons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              habit.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: habit.isCompletedToday ? TextDecoration.lineThrough : null,
                color: habit.isCompletedToday ? FlowColors.slate400 : null,
              ),
            ),
          ),
          // Streak
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: streakColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.flame, size: 12, color: streakColor),
                const SizedBox(width: 4),
                Text(
                  '${habit.currentStreak}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: streakColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
