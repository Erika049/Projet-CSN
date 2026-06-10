import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/utils.dart';
import 'patient_home_screen.dart';
import 'patient_carte_screen.dart';
import 'patient_historique_screen.dart';
import 'patient_ordonnances_screen.dart';
import 'patient_profil_screen.dart';

class PatientShell extends StatefulWidget {
  const PatientShell({super.key});

  @override
  State<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<PatientShell> {
  int _currentIndex = 0;

  bool get _isOffline => AppMode().isOffline;

  void _switchTab(int i) => setState(() => _currentIndex = i);

  List<Widget> get _screens => _isOffline
      ? const [
    PatientOrdonnancesScreen(),
    PatientProfilScreen(),
  ]
      : [
    PatientHomeScreen(onSwitchTab: _switchTab),
    const PatientCarteScreen(),
    const PatientHistoriqueScreen(),
    const PatientOrdonnancesScreen(),
    const PatientProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _isOffline
          ? _OfflineNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      )
          : _OnlineNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ==================== NAV ONLINE (5 onglets) ====================
class _OnlineNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _OnlineNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(icon: Icons.home_outlined, iconActive: Icons.home_rounded,
                  label: 'Accueil', isActive: currentIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.credit_card_outlined, iconActive: Icons.credit_card_rounded,
                  label: 'Carte', isActive: currentIndex == 1, onTap: () => onTap(1)),
              _NavItem(icon: Icons.history_outlined, iconActive: Icons.history_rounded,
                  label: 'Historique', isActive: currentIndex == 2, onTap: () => onTap(2)),
              _NavItem(icon: Icons.medication_outlined, iconActive: Icons.medication_rounded,
                  label: 'Ordonnances', isActive: currentIndex == 3, onTap: () => onTap(3)),
              _NavItem(icon: Icons.person_outline_rounded, iconActive: Icons.person_rounded,
                  label: 'Profil', isActive: currentIndex == 4, onTap: () => onTap(4)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== NAV OFFLINE (2 onglets) ====================
class _OfflineNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _OfflineNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: const Color(0xFFFEF3C7),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 12, color: Color(0xFFB45309)),
                  SizedBox(width: 6),
                  Text(
                    'Mode hors-réseau',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB45309),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  _NavItem(icon: Icons.medication_outlined, iconActive: Icons.medication_rounded,
                      label: 'Ordonnances', isActive: currentIndex == 0, onTap: () => onTap(0)),
                  _NavItem(icon: Icons.person_outline_rounded, iconActive: Icons.person_rounded,
                      label: 'Profil', isActive: currentIndex == 1, onTap: () => onTap(1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconActive;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconActive,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? iconActive : icon,
              color: isActive ? AppColors.primary : AppColors.textLight,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}