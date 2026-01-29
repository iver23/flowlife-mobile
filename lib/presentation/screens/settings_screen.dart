import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/auth_notifier.dart';
import '../widgets/ui_components.dart';

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
            'PREFERENCES',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.slate500, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            icon: LucideIcons.moon,
            title: 'Dark Mode',
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
          _buildSettingsTile(
            icon: LucideIcons.bell,
            title: 'Notifications',
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

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return FlowCard(
      padding: 16,
      onTap: onTap,
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
  }
}
