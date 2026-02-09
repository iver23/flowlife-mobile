import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'ui_components.dart';

class UndoToast {
  static void show({
    required BuildContext context,
    required String message,
    required VoidCallback onUndo,
    Duration duration = const Duration(seconds: 4),
  }) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.clearSnackBars();
    
    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.trash2, size: 18, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                scaffold.hideCurrentSnackBar();
                onUndo();
              },
              style: TextButton.styleFrom(
                foregroundColor: FlowColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('UNDO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        backgroundColor: FlowColors.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        elevation: 8,
      ),
    );
  }
}
