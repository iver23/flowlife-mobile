import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers.dart';
import '../../core/idea_notifier.dart';
import '../../core/date_formatter.dart';
import '../widgets/ui_components.dart';
import '../../data/models/models.dart';

class IdeasScreen extends ConsumerWidget {
  const IdeasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ideasAsync = ref.watch(ideaNotifierProvider);
    final ideaNotifier = ref.read(ideaNotifierProvider.notifier);
    final textController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildCaptureCard(context, ideaNotifier, textController),
            Expanded(
              child: ideasAsync.when(
                data: (ideas) {
                  if (ideas.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: ideas.length,
                    itemBuilder: (context, index) {
                      final idea = ideas[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildIdeaCard(context, idea, ideaNotifier, ref),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(LucideIcons.lightbulb, color: FlowColors.slate500),
          Text(
            'Ideas & Thoughts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          SizedBox(width: 24), // Spacer for centering
        ],
      ),
    );
  }

  Widget _buildCaptureCard(BuildContext context, IdeaNotifier notifier, TextEditingController controller) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: FlowCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QUICK CAPTURE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: FlowColors.slate500,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                border: InputBorder.none,
                hintStyle: TextStyle(color: FlowColors.slate500.withOpacity(0.5)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.hash, size: 14, color: FlowColors.slate500),
                    const SizedBox(width: 4),
                    const Text('Add Tag', style: TextStyle(fontSize: 12, color: FlowColors.slate500)),
                  ],
                ),
                FlowButton(
                  label: 'SAVE IDEA',
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      notifier.addIdea(controller.text);
                      controller.clear();
                    }
                  },
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdeaCard(BuildContext context, IdeaModel idea, IdeaNotifier notifier, WidgetRef ref) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return FlowCard(
      padding: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            idea.content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          if (idea.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: idea.tags.map((tag) => FlowBadge(
                label: tag,
                color: FlowColors.primaryDark,
              )).toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.formatTimestamp(idea.createdAt),
                style: const TextStyle(fontSize: 12, color: FlowColors.slate500),
              ),
              GestureDetector(
                onTap: () => notifier.convertToTask(idea, ref),
                child: const Row(
                  children: [
                    Icon(LucideIcons.arrowRightCircle, size: 18, color: FlowColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'CONVERT TO TASK',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlowColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.sparkles, size: 64, color: FlowColors.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text(
            'No ideas yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start capturing your thoughts!',
            style: TextStyle(color: FlowColors.slate500),
          ),
        ],
      ),
    );
  }
}
