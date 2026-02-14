import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/auth_notifier.dart';
import '../widgets/ui_components.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: FlowColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.zap, size: 40, color: FlowColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'FlowLife',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Master your focus, flow through life.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: FlowColors.slate500,
              ),
            ),
            const SizedBox(height: 80),
            
            // Google Sign In Button
            FlowButton(
              label: 'SIGN IN WITH GOOGLE',
              onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
              isFullWidth: true,
              isPrimary: true,
            ),
            const SizedBox(height: 24),
            Text(
              'By signing in, you agree to our Terms and Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: FlowColors.slate500.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
