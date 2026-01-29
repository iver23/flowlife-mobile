import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'ui_components.dart';

class MultiActionFAB extends StatefulWidget {
  final VoidCallback onAddProject;
  final VoidCallback onAddTask;
  final VoidCallback onAddIdea;

  const MultiActionFAB({
    super.key,
    required this.onAddProject,
    required this.onAddTask,
    required this.onAddIdea,
  });

  @override
  State<MultiActionFAB> createState() => _MultiActionFABState();
}

class _MultiActionFABState extends State<MultiActionFAB> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isOpen) ...[
          _buildActionButton(
            icon: LucideIcons.folderPlus,
            label: 'Project',
            onPressed: () {
              _toggle();
              widget.onAddProject();
            },
            index: 3,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: LucideIcons.checkSquare,
            label: 'Task',
            onPressed: () {
              _toggle();
              widget.onAddTask();
            },
            index: 2,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: LucideIcons.lightbulb,
            label: 'Idea',
            onPressed: () {
              _toggle();
              widget.onAddIdea();
            },
            index: 1,
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: FlowColors.primary,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 250),
            child: const Icon(LucideIcons.plus, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required int index,
  }) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton.small(
              onPressed: onPressed,
              backgroundColor: Colors.white,
              elevation: 4,
              child: Icon(icon, color: FlowColors.primary, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
