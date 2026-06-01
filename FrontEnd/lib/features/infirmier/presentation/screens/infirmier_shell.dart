import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import 'infirmier_mon_activite_screen.dart';
import 'infirmier_passages_screen.dart';
import 'infirmier_profil_screen.dart';
import 'infirmier_saisie_constantes_screen.dart';

/// Coquille principale de l'infirmier : 4 onglets en bas
/// (À constanter · Constantes · Mon activité · Profil).
class InfirmierShell extends StatefulWidget {
  const InfirmierShell({super.key});

  @override
  State<InfirmierShell> createState() => _InfirmierShellState();
}

class _InfirmierShellState extends State<InfirmierShell> {
  int _index = 0;

  void _goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      InfirmierPassagesScreen(onOpenConstantes: () => _goToTab(1)),
      const InfirmierSaisieConstantesScreen(),
      const InfirmierMonActiviteScreen(),
      const InfirmierProfilScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _goToTab,
        selectedItemColor: AppColors.roleInfirmier,
        unselectedItemColor: AppColors.textLight,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'À constanter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            activeIcon: Icon(Icons.monitor_heart),
            label: 'Constantes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history),
            label: 'Mon activité',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}