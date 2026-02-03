import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/achievement_notifier.dart';
import '../../data/models/achievement_model.dart';
import '../widgets/ui_components.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementProvider);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDark),
          achievementsAsync.when(
            data: (achievements) => _buildGrid(context, achievements, isDark),
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: isDark ? FlowColors.surfaceDark : Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Achievements',
          style: TextStyle(
            color: FlowColors.primary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        background: Center(
          child: Icon(
            LucideIcons.trophy,
            size: 64,
            color: FlowColors.primary.withOpacity(0.1),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(LucideIcons.chevronLeft, color: FlowColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<AchievementModel> achievements, bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final ach = achievements[index];
            return _buildAchievementCard(ach, isDark);
          },
          childCount: achievements.length,
        ),
      ),
    );
  }

  Widget _buildAchievementCard(AchievementModel ach, bool isDark) {
    return FlowCard(
      padding: 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ach.isUnlocked
                  ? FlowColors.primary.withOpacity(0.1)
                  : (isDark ? Colors.white.withOpacity(0.05) : FlowColors.slate100),
              shape: BoxShape.circle,
              boxShadow: ach.isUnlocked ? [
                BoxShadow(
                  color: FlowColors.primary.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ] : null,
            ),
            child: Icon(
              _getIcon(ach.icon),
              color: ach.isUnlocked
                  ? FlowColors.primary
                  : FlowColors.slate400,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ach.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: ach.isUnlocked ? null : FlowColors.slate500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ach.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: FlowColors.slate500.withOpacity(0.8),
            ),
          ),
          if (ach.isUnlocked && ach.unlockedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Unlocked!',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: FlowColors.primary.withOpacity(0.8),
              ),
            ),
          ]
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'check': return LucideIcons.checkCircle2;
      case 'target': return LucideIcons.target;
      case 'flame': return LucideIcons.flame;
      case 'layout': return LucideIcons.layout;
      default: return LucideIcons.trophy;
    }
  }
}
