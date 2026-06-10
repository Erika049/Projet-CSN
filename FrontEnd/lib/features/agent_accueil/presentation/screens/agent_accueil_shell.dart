import 'package:flutter/material.dart';

import 'agent_acceuil_dashboard_accueil_screen.dart';
import 'agent_acceuil_mon_activite_screen.dart';
import 'agent_acceuil_profil_agent_screen.dart';
import 'agent_acceuil_scanner_carte_screen.dart';

/// Coquille principale de l'agent d'accueil : 4 onglets en bas
/// (Tableau · Scanner · Mon activité · Profil).
class AgentAccueilShell extends StatefulWidget {
  const AgentAccueilShell({super.key});

  @override
  State<AgentAccueilShell> createState() => _AgentAccueilShellState();
}

class _AgentAccueilShellState extends State<AgentAccueilShell> {
  int _index = 0;

  void _goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardAccueilScreen(onOpenScanner: () => _goToTab(1)),
      const ScannerCarteScreen(embedded: true),
      const MonActiviteScreen(),
      const ProfilAgentScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _goToTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Tableau',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
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