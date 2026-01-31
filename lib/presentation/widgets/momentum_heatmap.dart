import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ui_components.dart';
import '../../data/models/models.dart';

import 'package:lucide_icons/lucide_icons.dart';

class MomentumHeatmap extends StatefulWidget {
  final List<TaskModel> tasks;

  const MomentumHeatmap({super.key, required this.tasks});

  @override
  State<MomentumHeatmap> createState() => _MomentumHeatmapState();
}

class _MomentumHeatmapState extends State<MomentumHeatmap> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final startOffset = (firstDayOfMonth.weekday - 1) % 7;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(monthName),
        AnimatedCrossFade(
          firstChild: _buildCollapsedView(context, now),
          secondChild: _buildExpandedView(context, daysInMonth, startOffset, now),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }

  Widget _buildHeader(String monthName) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              monthName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            Icon(
              _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              size: 20,
              color: FlowColors.slate400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedView(BuildContext context, DateTime now) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double spacing = 6.0;
          final double itemSize = (constraints.maxWidth - (6 * spacing)) / 7;
          
          return _buildCurrentWeekRow(context, itemSize, spacing, now);
        },
      ),
    );
  }

  Widget _buildExpandedView(BuildContext context, int daysInMonth, int startOffset, DateTime now) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildWeekdayHeaders(),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            const double spacing = 6.0;
            final double itemSize = (constraints.maxWidth - (6 * spacing)) / 7;
            
            return _buildCalendarGrid(context, daysInMonth, startOffset, itemSize, spacing, now);
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((d) => Expanded(
        child: Center(
          child: Text(
            d,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: FlowColors.slate400,
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCurrentWeekRow(BuildContext context, double itemSize, double spacing, DateTime now) {
    // Get current week (Mon-Sun)
    final weekDay = now.weekday; // 1-7 (Mon-Sun)
    final monday = now.subtract(Duration(days: weekDay - 1));
    
    final List<Widget> cells = [];
    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final count = _getTaskCountForDate(date);
      cells.add(_buildDayCell(context, date, date.day, count, itemSize, now));
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cells,
    );
  }

  Widget _buildCalendarGrid(BuildContext context, int daysInMonth, int startOffset, double itemSize, double spacing, DateTime now) {
    final List<Widget> rows = [];
    int dayCounter = 1;
    
    final totalCells = startOffset + daysInMonth;
    final numRows = (totalCells / 7).ceil();
    
    for (int row = 0; row < numRows; row++) {
      final List<Widget> rowChildren = [];
      
      for (int col = 0; col < 7; col++) {
        final cellIndex = row * 7 + col;
        
        if (cellIndex < startOffset || dayCounter > daysInMonth) {
          rowChildren.add(SizedBox(width: itemSize, height: itemSize));
        } else {
          final date = DateTime(now.year, now.month, dayCounter);
          final count = _getTaskCountForDate(date);
          rowChildren.add(_buildDayCell(context, date, dayCounter, count, itemSize, now));
          dayCounter++;
        }
      }
      
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: row < numRows - 1 ? spacing : 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rowChildren,
        ),
      ));
    }
    
    return Column(children: rows);
  }

  Widget _buildDayCell(BuildContext context, DateTime date, int day, int count, double size, DateTime now) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isToday = DateUtils.isSameDay(date, now);
    final bool isFuture = date.isAfter(now);
    
    Color cellColor;
    if (isFuture) {
      cellColor = isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03);
    } else if (count == 0) {
      cellColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
    } else if (count <= 2) {
      cellColor = FlowColors.primary.withOpacity(0.3);
    } else if (count <= 4) {
      cellColor = FlowColors.primary.withOpacity(0.6);
    } else {
      cellColor = FlowColors.primary;
    }

    return Tooltip(
      message: '${DateFormat('MMM d').format(date)}: ${isFuture ? '-' : '$count'} tasks',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isToday ? FlowColors.primary : cellColor,
          borderRadius: BorderRadius.circular(6),
          border: isToday ? Border.all(color: Colors.white, width: 1.5) : null,
          boxShadow: isToday ? [
            BoxShadow(
              color: FlowColors.primary.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 10,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday 
                  ? Colors.white 
                  : (isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.5)),
            ),
          ),
        ),
      ),
    );
  }

  int _getTaskCountForDate(DateTime date) {
    return widget.tasks.where((t) {
      if (!t.completed || t.completedAt == null) return false;
      final cDate = DateTime.fromMillisecondsSinceEpoch(t.completedAt!);
      return DateUtils.isSameDay(cDate, date);
    }).length;
  }
}

class _ChartDay {
  final DateTime date;
  final int count;
  _ChartDay({required this.date, required this.count});
}
