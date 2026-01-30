import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/auth_notifier.dart';
import '../../core/theme_notifier.dart';
import '../widgets/ui_components.dart';
import 'reports_screen.dart';
import '../../core/biometric_notifier.dart';

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
          FlowCard(
            padding: 0,
            child: Column(
              children: [
                _buildThemeOption(
                  ref,
                  ThemeSelection.system,
                  'Follow System',
                  LucideIcons.monitor,
                ),
                const Divider(height: 1, indent: 52, endIndent: 16),
                _buildThemeOption(
                  ref,
                  ThemeSelection.light,
                  'Light Mode',
                  LucideIcons.sun,
                ),
                const Divider(height: 1, indent: 52, endIndent: 16),
                _buildThemeOption(
                  ref,
                  ThemeSelection.dark,
                  'Dark Mode',
                  LucideIcons.moon,
                ),
                const Divider(height: 1, indent: 52, endIndent: 16),
                _buildThemeOption(
                  ref,
                  ThemeSelection.scheduled,
                  'Auto Schedule',
                  LucideIcons.calendar,
                ),
                if (ref.watch(themeNotifierProvider).selection == ThemeSelection.scheduled) ...[
                  const Divider(height: 1, indent: 52, endIndent: 16),
                  _buildTimeRow(
                    context,
                    ref,
                    'Start Time',
                    TimeOfDay(
                      hour: ref.watch(themeNotifierProvider).startHour,
                      minute: ref.watch(themeNotifierProvider).startMinute,
                    ),
                    (t) => ref.read(themeNotifierProvider.notifier).setScheduleTimes(startH: t.hour, startM: t.minute),
                    useCard: false,
                  ),
                  const Divider(height: 1, indent: 52, endIndent: 16),
                  _buildTimeRow(
                    context,
                    ref,
                    'End Time',
                    TimeOfDay(
                      hour: ref.watch(themeNotifierProvider).endHour,
                      minute: ref.watch(themeNotifierProvider).endMinute,
                    ),
                    (t) => ref.read(themeNotifierProvider.notifier).setScheduleTimes(endH: t.hour, endM: t.minute),
                    useCard: false,
                  ),
                ],
              ],
            ),
          ),
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
                  activeColor: FlowColors.primary,
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
                    activeColor: FlowColors.primary,
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
          _buildSettingsTile(
            icon: LucideIcons.bell,
            title: 'Notifications',
            trailing: const Icon(LucideIcons.chevronRight, size: 16, color: FlowColors.slate500),
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: LucideIcons.barChart2,
            title: 'Insights & Reports',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen())),
            trailing: const Icon(LucideIcons.chevronRight, size: 16, color: FlowColors.slate500),
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

  Widget _buildThemeOption(WidgetRef ref, ThemeSelection selection, String label, IconData icon) {
    final currentSelection = ref.watch(themeNotifierProvider).selection;
    final isActive = currentSelection == selection;

    return InkWell(
      onTap: () => ref.read(themeNotifierProvider.notifier).setThemeSelection(selection),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isActive ? FlowColors.primary : FlowColors.slate400),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? FlowColors.primary : null,
                ),
              ),
            ),
            if (isActive)
              const Icon(LucideIcons.check, size: 16, color: FlowColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context, WidgetRef ref, String label, TimeOfDay time, Function(TimeOfDay) onChange, {bool useCard = true}) {
    Widget content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            time.format(context),
            style: const TextStyle(color: FlowColors.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    if (!useCard) {
      return InkWell(
        onTap: () async {
          final t = await showTimePicker(context: context, initialTime: time);
          if (t != null) onChange(t);
        },
        child: content,
      );
    }

    return FlowCard(
      padding: 0,
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) onChange(t);
      },
      child: content,
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
}
