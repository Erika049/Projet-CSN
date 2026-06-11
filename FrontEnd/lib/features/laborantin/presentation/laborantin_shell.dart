import 'package:flutter/material.dart';
import 'laborantin_dashboard_screen.dart';
import 'laborantin_examens_screen.dart';
import 'laborantin_historique_screen.dart';
import 'laborantin_profil_screen.dart';

class LaborantinShell extends StatefulWidget {
  const LaborantinShell({super.key});

  @override
  State<LaborantinShell> createState() =>
      _LaborantinShellState();
}

class _LaborantinShellState
    extends State<LaborantinShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LaborantinDashboardScreen(),
    LaborantinExamensScreen(),
    LaborantinHistoriqueScreen(),
    LaborantinProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) =>
            setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon:
            Icon(Icons.science_rounded),
            label: 'Examens',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon:
            Icon(Icons.history_rounded),
            label: 'Historique',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon:
            Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}