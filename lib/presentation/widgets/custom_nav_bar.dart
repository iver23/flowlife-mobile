import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'ui_components.dart';

class FlowNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FlowNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? FlowColors.cardDark : Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 80),
          painter: NotchedPainter(color: backgroundColor),
        ),
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, LucideIcons.leaf, 'Projects'),
              _buildNavItem(1, LucideIcons.listTodo, 'Tasks'),
              const SizedBox(width: 48), // Space for center button (Dashboard)
              _buildNavItem(3, LucideIcons.bookmark, 'Ideas'),
              _buildNavItem(4, LucideIcons.settings, 'Study'),
            ],
          ),
        ),
        // Central Dashboard Button
        Positioned(
          top: -24,
          left: (MediaQuery.of(context).size.width / 2) - 28,
          child: GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: FlowColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(LucideIcons.flower2, color: Colors.white, size: 28),
            ),
          ),
        ),
        // Bottom indicator dot for Dashboard if active
        if (currentIndex == 2)
          Positioned(
            bottom: 12,
            left: (MediaQuery.of(context).size.width / 2) - 3,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: FlowColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? FlowColors.primary : FlowColors.slate400,
            size: 24,
          ),
          const SizedBox(height: 6),
          if (isActive)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: FlowColors.primary,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class NotchedPainter extends CustomPainter {
  final Color color;

  NotchedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path = Path();
    double notchRadius = 38;
    double centerX = size.width / 2;

    path.moveTo(0, 0);
    path.lineTo(centerX - notchRadius * 1.6, 0);
    
    // Smooth entrance to notch
    path.quadraticBezierTo(
      centerX - notchRadius, 
      0, 
      centerX - notchRadius, 
      notchRadius * 0.4
    );
    
    // Circular notch
    path.arcToPoint(
      Offset(centerX + notchRadius, notchRadius * 0.4),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    
    // Smooth exit from notch
    path.quadraticBezierTo(
      centerX + notchRadius, 
      0, 
      centerX + notchRadius * 1.6, 
      0
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Shadow for the bar
    canvas.drawShadow(path.shift(const Offset(0, -2)), Colors.black12, 10, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
