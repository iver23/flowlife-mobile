import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'presentation/widgets/ui_components.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/inbox_screen.dart';
import 'presentation/screens/ideas_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/widgets/search_overlay.dart';
import 'core/confetti_notifier.dart';
import 'core/auth_notifier.dart';
import 'core/notification_service.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return MaterialApp(
      title: 'FlowLife',
      debugShowCheckedModeBanner: false,
      theme: FlowTheme.light(),
      darkTheme: FlowTheme.dark(),
      themeMode: ThemeMode.system,
      home: user == null ? const LoginScreen() : const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  static const List<Widget> _screens = [
    DashboardScreen(),
    InboxScreen(),
    IdeasScreen(),
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
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.transparent,
                              builder: (context) => const SearchOverlay(),
                            );
                          },
                          icon: Icon(LucideIcons.search, size: 20),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                          icon: Hero(
                            tag: 'avatar',
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: FlowColors.primary.withOpacity(0.5), width: 1),
                              ),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: FlowColors.primary,
                                child: Icon(LucideIcons.user, size: 14, color: Colors.white),
                              ),
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
                              NavigationRailDestination(icon: Icon(Icons.inbox_rounded), label: Text('Inbox')),
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
                    bottomNavigationBar: isWide ? null : BottomNavigationBar(
                      currentIndex: _selectedIndex,
                      onTap: (index) => setState(() => _selectedIndex = index),
                      selectedItemColor: FlowColors.primary,
                      unselectedItemColor: FlowColors.slate500,
                      showSelectedLabels: true,
                      showUnselectedLabels: false,
                      items: const [
                        BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dash'),
                        BottomNavigationBarItem(icon: Icon(Icons.inbox_rounded), label: 'Inbox'),
                        BottomNavigationBarItem(icon: Icon(Icons.lightbulb_rounded), label: 'Ideas'),
                      ],
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
                ],
              ),
            );
          },
        );
      },
    );
  }
}
