import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'laborantin_dashboard_screen.dart';
import 'laborantin_examens_screen.dart';
import 'laborantin_activite_screen.dart';
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
    LaborantinActiviteScreen(),
    LaborantinProfilScreen(),
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
          border: Border(
              top: BorderSide(
                  color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.science_outlined,
                  iconActive: Icons.science_rounded,
                  label: 'À traiter',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(
                          () => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.upload_outlined,
                  iconActive: Icons.upload_rounded,
                  label: 'Publier',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(
                          () => _currentIndex = 1),
                ),
                _NavItem(
                  icon:
                  Icons.access_time_outlined,
                  iconActive: Icons
                      .access_time_filled_rounded,
                  label: 'Mon activité',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(
                          () => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  iconActive: Icons.person_rounded,
                  label: 'Profil',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(
                          () => _currentIndex = 3),
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
  final IconData     icon;
  final IconData     iconActive;
  final String       label;
  final bool         isActive;
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
    const activeColor = Color(0xFFB45309);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? iconActive : icon,
              color: isActive
                  ? activeColor
                  : AppColors.textLight,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: isActive
                    ? activeColor
                    : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}