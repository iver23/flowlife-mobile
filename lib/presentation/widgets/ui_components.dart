import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlowColors {
  // New Palette
  static const Color duskBlue = Color(0xFF355070);
  static const Color dustyLavender = Color(0xFF6D597A);
  static const Color rosewood = Color(0xFFB56576);
  static const Color lightCoral = Color(0xFFE56B6F);
  static const Color lightBronze = Color(0xFFEAAC8B);

  static const Color primary = duskBlue;
  static const Color primaryDark = Color(0xFF2A425A); // Deepened Dusk Blue
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color textLight = Color(0xFF0F172A);
  static const Color textDark = Colors.white;
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);

  static Color parseProjectColor(String? colorStr) {
    if (colorStr == null) return slate500;
    switch (colorStr.toLowerCase()) {
      case 'duskblue':
      case 'blue': return duskBlue;
      case 'lavender':
      case 'violet': return dustyLavender;
      case 'rosewood':
      case 'rose': return rosewood;
      case 'coral':
      case 'red': return lightCoral;
      case 'bronze':
      case 'amber': return lightBronze;
      case 'emerald': return const Color(0xFF10B981);
      default: return primary;
    }
  }
}

class FlowTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: FlowColors.primary,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: FlowColors.textLight,
        displayColor: FlowColors.textLight,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: FlowColors.primaryDark,
      scaffoldBackgroundColor: FlowColors.surfaceDark,
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: FlowColors.textDark,
        displayColor: FlowColors.textDark,
      ),
    );
  }
}

// --- Card ---
class FlowCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double padding;
  final EdgeInsets? margin;

  const FlowCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = 20,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        margin: margin,
        decoration: BoxDecoration(
          color: isDark ? FlowColors.cardDark : FlowColors.cardLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
        ),
        child: child,
      ),
    );
  }
}

// --- Button ---
class FlowButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isFullWidth;

  final IconData? icon;

  const FlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.isFullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? (isDark ? FlowColors.primaryDark : FlowColors.primary)
              : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9)),
          foregroundColor: isPrimary
              ? Colors.white
              : (isDark ? Colors.white70 : const Color(0xFF334155)),
          elevation: isPrimary ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Badge ---
class FlowBadge extends StatelessWidget {
  final String label;
  final Color color;

  const FlowBadge({
    super.key,
    required this.label,
    this.color = FlowColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// --- ProgressBar ---
class FlowProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color color;

  const FlowProgressBar({
    super.key,
    required this.progress,
    this.color = FlowColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(100),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}
