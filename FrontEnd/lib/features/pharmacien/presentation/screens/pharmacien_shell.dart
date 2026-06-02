import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import 'pharmacien_dashboard_screen.dart';
import 'pharmacien_mon_activite_screen.dart';
import 'pharmacien_profil_screen.dart';
import 'pharmacien_scanner_screen.dart';

/// Coquille principale du pharmacien : 4 onglets en bas
/// (À dispenser · Scanner · Mon activité · Profil).
class PharmacienShell extends StatefulWidget {
  const PharmacienShell({super.key});

  @override
  State<PharmacienShell> createState() => _PharmacienShellState();
}

class _PharmacienShellState extends State<PharmacienShell> {
  int _index = 0;

  void _goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      PharmacienDashboardScreen(onOpenScanner: () => _goToTab(1)),
      const PharmacienScannerScreen(),
      const PharmacienMonActiviteScreen(),
      const PharmacienProfilScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _goToTab,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'À dispenser',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
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
