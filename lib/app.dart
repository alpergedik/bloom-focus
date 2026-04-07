import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_background.dart';
import 'features/focus/presentation/focus_page.dart';
import 'features/tasks/presentation/tasks_page.dart';
import 'features/plant/presentation/plant_page.dart';
import 'features/sounds/presentation/sounds_page.dart';
import 'features/progress/presentation/progress_page.dart';

class BloomFocusApp extends StatelessWidget {
  const BloomFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bloom Focus',
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 2;

  final List<Widget> pages = const [
    FocusPage(),
    TasksPage(),
    PlantPage(),
    SoundsPage(),
    ProgressPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: pages[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              label: 'Focus',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_rounded),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_florist_outlined),
              label: 'Plant',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note_outlined),
              label: 'Sounds',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Progress',
            ),
          ],
        ),
      ),
    );
  }
}