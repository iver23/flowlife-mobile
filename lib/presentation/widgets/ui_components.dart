import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlowColors {
  // --- New "Calm-Tech" Palette ---
  
  // Neutrals (60%)
  static const Color linen = Color(0xFFFDFCFB); 
  static const Color paper = Color(0xFFF8F4EA); // Calm, organic background
  static const Color midnight = Color(0xFF0F172A); 
  
  // Secondary / Surfaces (30%)
  static const Color surfaceLight = Colors.white; 
  static const Color surfaceDark = Color(0xFF1E293B); // Slightly lighter than midnight for depth
  
  // Accents (10%)
  static const Color indigoAccent = Color(0xFF6366F1); // Primary brand color
  static const Color blueAccent = Color(0xFF3B82F6); 
  
  // Semantic / Constants
  static const Color primary = indigoAccent;
  static const Color primaryDark = Color(0xFF4F46E5); // Vibrant Indigo
  
  static const Color textLight = Color(0xFF0F172A); // Dark navy for visibility
  static const Color textDark = Color(0xFFF1F5F9); // Off-white to reduce glare
  
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);

  // Legacy Project Colors mapped to new aesthetic
  static const Color duskBlue = Color(0xFF355070);
  static const Color dustyLavender = Color(0xFF6D597A);
  static const Color rosewood = Color(0xFFB56576);
  static const Color lightCoral = Color(0xFFE56B6F);
  static const Color lightBronze = Color(0xFFEAAC8B);

  static Color parseProjectColor(String? colorStr) {
    if (colorStr == null) return slate500;
    switch (colorStr.toLowerCase()) {
      case 'duskblue':
      case 'blue': return blueAccent;
      case 'lavender':
      case 'violet': return const Color(0xFFA855F7); // Purple-500
      case 'rosewood':
      case 'rose': return const Color(0xFFEC4899); // Pink-500
      case 'coral':
      case 'red': return const Color(0xFFEF4444); // Red-500
      case 'bronze':
      case 'amber': return const Color(0xFFF59E0B); // Amber-500
      case 'emerald': return const Color(0xFF10B981);
      default: return primary;
    }
  }

  static Color getSubtleProjectColor(Color color, bool isDark) {
    return color.withOpacity(isDark ? 0.15 : 0.12);
  }
}

class FlowTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: FlowColors.primary,
      scaffoldBackgroundColor: FlowColors.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FlowColors.primary,
        surface: FlowColors.surfaceLight,
        onSurface: FlowColors.textLight,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: FlowColors.textLight,
        displayColor: FlowColors.textLight,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return FlowColors.primary;
          return FlowColors.slate400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return FlowColors.primary.withOpacity(0.5);
          return FlowColors.slate200;
        }),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: FlowColors.textLight, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: FlowColors.primaryDark,
      scaffoldBackgroundColor: FlowColors.midnight,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: FlowColors.primaryDark,
        surface: FlowColors.surfaceDark,
        onSurface: FlowColors.textDark,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: FlowColors.textDark,
        displayColor: FlowColors.textDark,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return FlowColors.primaryDark;
          return FlowColors.slate500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return FlowColors.primaryDark.withOpacity(0.3);
          return FlowColors.midnight;
        }),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: FlowColors.textDark, fontSize: 18, fontWeight: FontWeight.bold),
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
  final bool useGlass;
  final Color? backgroundColor;

  const FlowCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = 20,
    this.margin,
    this.useGlass = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color surfaceColor = backgroundColor ?? (isDark ? FlowColors.surfaceDark : FlowColors.surfaceLight);
    
    Widget card = Container(
      padding: EdgeInsets.all(padding),
      margin: margin,
      decoration: BoxDecoration(
        color: (isDark && useGlass && backgroundColor == null) ? surfaceColor.withOpacity(0.7) : surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.03),
          width: 0.5,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF64748B).withOpacity(0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
              ],
      ),
      child: child,
    );

    if (isDark && useGlass) {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: card,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: card,
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
