import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'presentation/widgets/ui_components.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/projects_screen.dart';
import 'presentation/screens/tasks_screen.dart';
import 'presentation/screens/ideas_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/widgets/search_overlay.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/widgets/custom_nav_bar.dart';
import 'presentation/widgets/multi_action_fab.dart';
import 'presentation/widgets/project_edit_sheet.dart';
import 'presentation/widgets/task_edit_sheet.dart';
import 'presentation/screens/study_screen.dart';
import 'presentation/widgets/study_edit_sheet.dart';
import 'presentation/widgets/tag_picker.dart';
import 'presentation/widgets/project_picker.dart';
import 'core/confetti_notifier.dart';
import 'core/auth_notifier.dart';
import 'core/project_notifier.dart';
import 'core/task_notifier.dart';
import 'core/idea_notifier.dart';
import 'core/notification_service.dart';
import 'data/models/models.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme_notifier.dart';
import 'core/biometric_notifier.dart';
import 'presentation/screens/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final themeState = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'FlowLife',
      debugShowCheckedModeBanner: false,
      theme: FlowTheme.light(),
      darkTheme: FlowTheme.dark(),
      themeMode: themeState.mode,
      home: user == null ? const LoginScreen() : const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 2; // Default to Dashboard
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      final bioState = ref.read(biometricProvider);
      if (bioState.isEnabled && bioState.isAutoLockEnabled) {
        ref.read(biometricProvider.notifier).lock();
      }
    }
  }

  static const List<Widget> _screens = [
    ProjectsScreen(),
    TasksScreen(),
    DashboardScreen(),
    IdeasScreen(),
    const StudyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.listen(confettiProvider, (previous, next) {
          if (next != null) {
            _confettiController.play();
          }
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            return Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent && 
                    event.logicalKey == LogicalKeyboardKey.keyK && 
                    (HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isControlPressed)) {
                  showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (context) => const SearchOverlay(),
                  );
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Stack(
                children: [
                  Scaffold(
                    appBar: AppBar(
                      title: const Text('FlowLife', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      actions: [
                        IconButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen())),
                          icon: const Icon(LucideIcons.search, size: 20),
                        ),
                        IconButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen())),
                          icon: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: FlowColors.primary.withOpacity(0.5), width: 1),
                            ),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: FlowColors.primary,
                              child: Icon(LucideIcons.user, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    body: Row(
                      children: [
                        if (isWide)
                          NavigationRail(
                            selectedIndex: _selectedIndex,
                            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                            labelType: NavigationRailLabelType.selected,
                            selectedIconTheme: const IconThemeData(color: FlowColors.primary),
                            unselectedIconTheme: const IconThemeData(color: FlowColors.slate500),
                            destinations: const [
                              NavigationRailDestination(icon: Icon(Icons.dashboard_rounded), label: Text('Dash')),
                              NavigationRailDestination(icon: Icon(LucideIcons.folder), label: Text('Projects')),
                              NavigationRailDestination(icon: Icon(Icons.check_box_rounded), label: Text('Tasks')),
                              NavigationRailDestination(icon: Icon(Icons.lightbulb_rounded), label: Text('Ideas')),
                            ],
                          ),
                        Expanded(
                          child: IndexedStack(
                            index: _selectedIndex,
                            children: _screens,
                          ),
                        ),
                      ],
                    ),
                    floatingActionButton: _buildFAB(context, ref),
                    bottomNavigationBar: isWide ? null : FlowNavigationBar(
                      currentIndex: _selectedIndex,
                      onTap: (index) => setState(() => _selectedIndex = index),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      colors: const [
                        FlowColors.primary,
                        Colors.blue,
                        Colors.purple,
                        Colors.pink,
                      ],
                    ),
                  ),
                  if (ref.watch(biometricProvider).isLocked) const LockScreen(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context, WidgetRef ref) {
    switch (_selectedIndex) {
      case 2: // Dashboard
        return MultiActionFAB(
          onAddProject: () => _showAddProjectSheet(context, ref),
          onAddTask: () => _showAddTaskSheet(context, ref),
          onAddIdea: () => _showAddIdeaSheet(context, ref),
        );
      case 0: // Projects
        return FloatingActionButton(
          onPressed: () => _showAddProjectSheet(context, ref),
          backgroundColor: FlowColors.primary,
          child: const Icon(LucideIcons.plus, color: Colors.white),
        );
      case 1: // Tasks
        return FloatingActionButton(
          onPressed: () => _showAddTaskSheet(context, ref),
          backgroundColor: FlowColors.primary,
          child: const Icon(LucideIcons.plus, color: Colors.white),
        );
      case 3: // Ideas
        return FloatingActionButton(
          onPressed: () => _showAddIdeaSheet(context, ref),
          backgroundColor: FlowColors.primary,
          child: const Icon(LucideIcons.plus, color: Colors.white),
        );
      case 4: // Study
        return FloatingActionButton(
          onPressed: () => _showAddStudyAreaSheet(context),
          backgroundColor: FlowColors.primary,
          child: const Icon(LucideIcons.plus, color: Colors.white),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showAddStudyAreaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const StudyEditSheet(type: StudyEntryType.area),
    );
  }

  void _showAddProjectSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectEditSheet(
        onSave: (project) => ref.read(projectNotifierProvider.notifier).addProject(project),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskEditSheet(
        task: TaskModel(
          id: '',
          title: '',
          completed: false,
          subtasks: [],
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
        onSave: (task) => ref.read(taskNotifierProvider.notifier).addTask(
          task.title, 
          projectId: task.projectId,
        ),
      ),
    );
  }

  void _showAddIdeaSheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    String? selectedProjectId;
    List<String> selectedCustomTags = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Idea'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  maxLines: 3,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'What\'s on your mind?'),
                ),
                const SizedBox(height: 24),
                ProjectPicker(
                  selectedProjectId: selectedProjectId,
                  onSelected: (id) => setDialogState(() => selectedProjectId = id),
                ),
                const SizedBox(height: 24),
                TagPicker(
                  selectedTagNames: selectedCustomTags,
                  onSelected: (tags) => setDialogState(() => selectedCustomTags = tags),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref.read(ideaNotifierProvider.notifier).addIdea(
                    controller.text,
                    projectId: selectedProjectId,
                    customTags: selectedCustomTags,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}
