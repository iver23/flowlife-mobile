import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/ui_components.dart';
import '../../core/biometric_notifier.dart';

class LockScreen extends ConsumerWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with blur
          Positioned.fill(
            child: Container(
              color: FlowColors.primary.withValues(alpha: 0.05),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: FlowColors.primary,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: FlowColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.lock,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'FLOWLIFE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'App is locked for your privacy',
                    style: TextStyle(
                      color: FlowColors.slate500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 64),
                  FlowButton(
                    label: 'UNLOCK APP',
                    onPressed: () => ref.read(biometricProvider.notifier).authenticate(),
                    icon: LucideIcons.fingerprint,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
