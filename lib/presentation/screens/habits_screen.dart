import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/habit_notifier.dart';
import '../../data/models/habit_model.dart';
import '../widgets/ui_components.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: FlowColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitSheet(context, ref),
        backgroundColor: FlowColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          // Group by category
          final categories = <String, List<HabitModel>>{};
          for (final habit in habits) {
            categories.putIfAbsent(habit.category, () => []).add(habit);
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Today's overview
              _buildTodayOverview(habits, isDark),
              const SizedBox(height: 32),

              // Habits by category
              ...categories.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: FlowColors.slate500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...entry.value.map((habit) => _buildHabitTile(context, ref, habit, isDark)),
                  const SizedBox(height: 24),
                ],
              )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.repeat, size: 64, color: FlowColors.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No habits yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Start building good habits!', style: TextStyle(color: FlowColors.slate500)),
          const SizedBox(height: 24),
          FlowButton(
            label: 'Add Habit',
            icon: LucideIcons.plus,
            onPressed: () => _showAddHabitSheet(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayOverview(List<HabitModel> habits, bool isDark) {
    final completedToday = habits.where((h) => h.isCompletedToday).length;
    final progress = habits.isEmpty ? 0.0 : completedToday / habits.length;

    return FlowCard(
      padding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Today\'s Progress', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '$completedToday/${habits.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: progress == 1.0 ? Colors.green : FlowColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FlowProgressBar(progress: progress, color: progress == 1.0 ? Colors.green : FlowColors.primary),
          if (progress == 1.0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.partyPopper, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text('All habits completed!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHabitTile(BuildContext context, WidgetRef ref, HabitModel habit, bool isDark) {
    final streakColor = habit.currentStreak >= 7
        ? Colors.orange
        : (habit.currentStreak >= 3 ? Colors.amber : FlowColors.primary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FlowCard(
        padding: 16,
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: habit.isCompletedToday
                      ? FlowColors.primary
                      : (isDark ? Colors.white.withOpacity(0.05) : FlowColors.slate100),
                  borderRadius: BorderRadius.circular(10),
                  border: habit.isCompletedToday ? null : Border.all(color: FlowColors.slate200),
                ),
                child: habit.isCompletedToday
                    ? const Icon(LucideIcons.check, size: 18, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Title & Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: habit.isCompletedToday ? TextDecoration.lineThrough : null,
                      color: habit.isCompletedToday ? FlowColors.slate400 : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(habit.weeklyCompletionRate * 100).toInt()}% this week',
                    style: const TextStyle(fontSize: 12, color: FlowColors.slate500),
                  ),
                ],
              ),
            ),
            // Streak
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: streakColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.flame, size: 14, color: streakColor),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.currentStreak}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: streakColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('streak', style: TextStyle(fontSize: 10, color: FlowColors.slate400)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    String selectedCategory = 'productivity';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? FlowColors.surfaceDark
                : FlowColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: FlowColors.slate200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('New Habit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Habit name...',
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : FlowColors.slate50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['health', 'productivity', 'learning', 'wellness'].map((cat) {
                  final isSelected = selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat[0].toUpperCase() + cat.substring(1)),
                    selected: isSelected,
                    onSelected: (sel) => setState(() => selectedCategory = cat),
                    selectedColor: FlowColors.primary.withOpacity(0.1),
                    checkmarkColor: FlowColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? FlowColors.primary : FlowColors.slate500,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FlowButton(
                label: 'Create Habit',
                isFullWidth: true,
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    ref.read(habitNotifierProvider.notifier).addHabit(
                      HabitModel(
                        id: '',
                        title: titleController.text,
                        category: selectedCategory,
                        createdAt: DateTime.now().millisecondsSinceEpoch,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
