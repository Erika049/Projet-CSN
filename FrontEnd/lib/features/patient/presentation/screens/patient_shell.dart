import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import 'accueil_screen.dart';
import 'historique_screen.dart';
import 'mes_ordonnances_screen.dart';
import 'profil_screen.dart';

/// Conteneur principal du parcours patient avec barre de navigation à 5 onglets
/// (Accueil · Carte · Historique · Ordonnances · Profil).
///
/// C'est l'écran sur lequel on arrive après la connexion patient. L'onglet
/// "Carte" est pour l'instant un simple placeholder (la carte numérique sera
/// implémentée dans un second temps).
class PatientShell extends StatefulWidget {
  const PatientShell({super.key});

  @override
  State<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<PatientShell> {
  int _index = 0;

  void _goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      AccueilScreen(onGoToTab: _goToTab),
      const _CartePlaceholder(),
      const HistoriqueScreen(),
      const MesOrdonnancesScreen(),
      const ProfilScreen(),
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
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            activeIcon: Icon(Icons.credit_card),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_outlined),
            activeIcon: Icon(Icons.medication),
            label: 'Ordonnances',
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

/// Placeholder temporaire de l'onglet "Ma carte numérique".
class _CartePlaceholder extends StatelessWidget {
  const _CartePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Ma carte numérique')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_2, size: 64, color: AppColors.textLight),
            SizedBox(height: 16),
            Text(
              'Carte numérique',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 6),
            Text('Bientôt disponible', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}