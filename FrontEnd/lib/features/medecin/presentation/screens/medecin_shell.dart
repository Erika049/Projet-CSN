import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'medecin_dashboard_screen.dart';
import 'medecin_patients_screen.dart';
import 'medecin_activite_screen.dart';
import 'medecin_profil_screen.dart';

class MedecinShell extends StatefulWidget {
  const MedecinShell({super.key});

  @override
  State<MedecinShell> createState() => _MedecinShellState();
}

class _MedecinShellState extends State<MedecinShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    MedecinDashboardScreen(),
    MedecinPatientsScreen(),
    MedecinActiviteScreen(),
    MedecinProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  iconActive: Icons.home_rounded,
                  label: "Aujourd'hui",
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.people_outline_rounded,
                  iconActive: Icons.people_rounded,
                  label: 'Patients',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.history_outlined,
                  iconActive: Icons.history_rounded,
                  label: 'Mon activité',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  iconActive: Icons.person_rounded,
                  label: 'Profil',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
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
                fontWeight:
                isActive ? FontWeight.w600 : FontWeight.w400,
                color:
                isActive ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}