import 'package:flutter/material.dart';

import '../../../../features/auth/presentation/screens/inscription_screen.dart';
import 'agent_acceuil_dashboard_accueil_screen.dart';
import 'agent_acceuil_mon_activite_screen.dart';
import 'agent_acceuil_profil_agent_screen.dart';
import 'agent_acceuil_scanner_carte_screen.dart';

class AgentAccueilShell extends StatefulWidget {
  const AgentAccueilShell({super.key});

  @override
  State<AgentAccueilShell> createState() => _AgentAccueilShellState();
}

class _AgentAccueilShellState extends State<AgentAccueilShell> {
  int _index = 0;

  // Notifie le dashboard de se rafraîchir (incrémenté à chaque admission validée)
  final _dashRefresh = ValueNotifier<int>(0);

  void _goToTab(int i) => setState(() => _index = i);

  // Appelé après une admission validée : retour dashboard + refresh
  void _onAdmissionSuccess() {
    _dashRefresh.value++;
    _goToTab(0);
  }

  // Ouvre l'écran d'inscription d'un nouveau patient
  void _ouvrirInscription() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InscriptionScreen()),
    );
  }

  @override
  void dispose() {
    _dashRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardAccueilScreen(
        refreshNotifier:  _dashRefresh,
        onOpenScanner:    () => _goToTab(1),
        onNouveauPatient: _ouvrirInscription,
      ),
      ScannerCarteScreen(
        embedded:           true,
        onAdmissionSuccess: _onAdmissionSuccess,
        onNouveauPatient:   _ouvrirInscription,
      ),
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
