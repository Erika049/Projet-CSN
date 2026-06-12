import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_personnel_screen.dart';
import 'admin_hopitaux_screen.dart';
import 'admin_logs_screen.dart';
import 'admin_profil_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() =>
      _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  List<Widget> get _screens => [
    AdminDashboardScreen(
        onNavigate: _navigateTo),
    const AdminPersonnelScreen(),
    const AdminHopitauxScreen(),
    const AdminLogsScreen(),
    const AdminProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1A3D),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B1A3D),
          border: Border(
            top: BorderSide(
                color: Color(0xFF1E3A6E),
                width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _AdminNavItem(
                  icon: Icons.dashboard_outlined,
                  iconActive:
                  Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(
                          () => _currentIndex = 0),
                ),
                _AdminNavItem(
                  icon: Icons.people_outline,
                  iconActive: Icons.people_rounded,
                  label: 'Personnel',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(
                          () => _currentIndex = 1),
                ),
                _AdminNavItem(
                  icon:
                  Icons.local_hospital_outlined,
                  iconActive:
                  Icons.local_hospital_rounded,
                  label: 'Hôpitaux',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(
                          () => _currentIndex = 2),
                ),
                _AdminNavItem(
                  icon: Icons.shield_outlined,
                  iconActive: Icons.shield_rounded,
                  label: 'Audit',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(
                          () => _currentIndex = 3),
                ),
                _AdminNavItem(
                  icon: Icons.person_outline,
                  iconActive: Icons.person_rounded,
                  label: 'Profil',
                  isActive: _currentIndex == 4,
                  onTap: () => setState(
                          () => _currentIndex = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData     icon;
  final IconData     iconActive;
  final String       label;
  final bool         isActive;
  final VoidCallback onTap;

  const _AdminNavItem({
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
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? iconActive : icon,
              color: isActive
                  ? Colors.white
                  : const Color(0xFF4A6FA5),
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
                    ? Colors.white
                    : const Color(0xFF4A6FA5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}