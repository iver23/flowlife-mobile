import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/auth_notifier.dart';
import '../../core/theme_notifier.dart';
import '../widgets/ui_components.dart';
import 'reports_screen.dart';
import 'habits_screen.dart';
import 'achievements_screen.dart';
import 'settings/trash_screen.dart';
import '../../core/biometric_notifier.dart';
import '../../core/reminder_settings_notifier.dart';
import '../widgets/theme_toggle.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: FlowColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // User Profile Section
          if (user != null) ...[
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                    child: user.photoURL == null ? const Icon(LucideIcons.user, size: 40) : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName ?? 'Anonymous User',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email ?? '',
                    style: const TextStyle(color: FlowColors.slate500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],

          const Text(
            'APPEARANCE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          const ThemeToggle(),
          const SizedBox(height: 32),
          const Text(
            'PRIVACY & SECURITY',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          FlowCard(
            padding: 0,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(LucideIcons.shieldCheck, color: FlowColors.slate500, size: 20),
                  title: const Text('Biometric Lock', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Require FaceID/Fingerprint', style: TextStyle(fontSize: 12)),
                  value: ref.watch(biometricProvider).isEnabled,
                  onChanged: (val) async {
                    final success = await ref.read(biometricProvider.notifier).toggleBiometric(val);
                    if (!success && val) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to enable biometric authentication')),
                        );
                      }
                    }
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
                if (ref.watch(biometricProvider).isEnabled) ...[
                  const Divider(height: 1, indent: 52, endIndent: 16),
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.lock, color: FlowColors.slate500, size: 20),
                    title: const Text('Lock on Background', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Lock app when minimized', style: TextStyle(fontSize: 12)),
                    value: ref.watch(biometricProvider).isAutoLockEnabled,
                    onChanged: (val) => ref.read(biometricProvider.notifier).setAutoLock(val),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'NOTIFICATIONS',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          _buildNotificationSettings(context, ref),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: LucideIcons.barChart2,
            title: 'Insights & Reports',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen())),
            trailing: const Icon(LucideIcons.chevronRight, size: 16, color: FlowColors.slate500),
          ),
          const Divider(height: 1, indent: 52, endIndent: 16),
          _buildSettingsTile(
            icon: LucideIcons.repeat,
            title: 'Habits',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HabitsScreen())),
            trailing: const Icon(LucideIcons.chevronRight, size: 16, color: FlowColors.slate500),
            useCard: false,
          ),
          const Divider(height: 1, indent: 52, endIndent: 16),
          _buildSettingsTile(
            icon: LucideIcons.trophy,
            title: 'Achievements',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AchievementsScreen())),
            trailing: const Icon(LucideIcons.chevronRight, size: 16, color: FlowColors.slate500),
            useCard: false,
          ),
          const Divider(height: 1, indent: 52, endIndent: 16),
          _buildSettingsTile(
            icon: LucideIcons.trash2,
            title: 'Trash',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TrashScreen())),
            trailing: const Icon(LucideIcons.chevronRight, size: 16, color: FlowColors.slate500),
            useCard: false,
          ),
          
          const SizedBox(height: 32),
          const Text(
            'ACCOUNT',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            icon: LucideIcons.logOut,
            title: 'Sign Out',
            titleColor: Colors.red,
            onTap: () {
              ref.read(authProvider.notifier).signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
    bool useCard = true,
  }) {
    Widget content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: titleColor ?? FlowColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );

    if (!useCard) {
      return InkWell(
        onTap: onTap,
        child: content,
      );
    }

    return FlowCard(
      padding: 0,
      onTap: onTap,
      child: content,
    );
  }

  Widget _buildNotificationSettings(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(reminderSettingsProvider);
    final notifier = ref.read(reminderSettingsProvider.notifier);

    return FlowCard(
      padding: 0,
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(LucideIcons.bell, color: FlowColors.slate500, size: 20),
            title: const Text('Smart Reminders', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Gentle task reminders', style: TextStyle(fontSize: 12)),
            value: settings.smartRemindersEnabled,
            onChanged: (val) => notifier.toggleSmartReminders(val),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          const Divider(height: 1, indent: 52, endIndent: 16),
          SwitchListTile(
            secondary: const Icon(LucideIcons.sunrise, color: FlowColors.slate500, size: 20),
            title: const Text('Morning Briefing', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Today\'s priorities at 8 AM', style: TextStyle(fontSize: 12)),
            value: settings.morningBriefingEnabled,
            onChanged: (val) => notifier.toggleMorningBriefing(val),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          const Divider(height: 1, indent: 52, endIndent: 16),
          SwitchListTile(
            secondary: const Icon(LucideIcons.compass, color: FlowColors.slate500, size: 20),
            title: const Text('Project Nudges', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Inactive project reminders', style: TextStyle(fontSize: 12)),
            value: settings.projectNudgesEnabled,
            onChanged: (val) => notifier.toggleProjectNudges(val),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          const Divider(height: 1, indent: 52, endIndent: 16),
          _buildTimeRangeRow(context, ref, settings, notifier),
        ],
      ),
    );
  }

  Widget _buildTimeRangeRow(BuildContext context, WidgetRef ref, ReminderSettings settings, ReminderSettingsNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.moon, size: 20, color: FlowColors.slate500),
              SizedBox(width: 16),
              Text('Quiet Hours', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeLabel(context, 'Start', settings.quietHoursStart, () async {
                final t = await showTimePicker(context: context, initialTime: settings.quietHoursStart);
                if (t != null) notifier.setQuietHours(t, settings.quietHoursEnd);
              }),
              const Icon(LucideIcons.arrowRight, size: 16, color: FlowColors.slate400),
              _buildTimeLabel(context, 'End', settings.quietHoursEnd, () async {
                final t = await showTimePicker(context: context, initialTime: settings.quietHoursEnd);
                if (t != null) notifier.setQuietHours(settings.quietHoursStart, t);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLabel(BuildContext context, String label, TimeOfDay time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: FlowColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: FlowColors.slate500)),
            Text(time.format(context), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: FlowColors.primary)),
          ],
        ),
      ),
    );
  }
}
