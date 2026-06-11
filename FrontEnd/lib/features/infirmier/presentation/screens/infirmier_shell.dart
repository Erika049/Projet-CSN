import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../data/infirmier_api_service.dart';
import '../../../agent_accueil/data/agent_accueil_api_service.dart';
import 'infirmier_mon_activite_screen.dart';
import 'infirmier_passages_screen.dart';
import 'infirmier_profil_screen.dart';
import 'infirmier_saisie_constantes_screen.dart';

class InfirmierShell extends StatefulWidget {
  const InfirmierShell({super.key});

  @override
  State<InfirmierShell> createState() => _InfirmierShellState();
}

class _InfirmierShellState extends State<InfirmierShell> {
  final _local = AuthLocalService();
  final _api   = AgentAccueilApiService();

  int                  _index          = 0;
  PassageInfirmierApi? _selectedPassage;
  String               _infName        = '';
  String               _infInitials    = '?';

  // Notifie la liste des passages de se rafraîchir après save constantes
  final _passagesRefresh = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    final id = await _local.getUserId();
    if (id == null) return;
    try {
      final profil = await _api.getProfil(id);
      if (mounted) setState(() {
        _infName     = '${profil.prenom} ${profil.nom}';
        _infInitials = profil.initials;
      });
    } catch (_) {
      final name = await _local.getUserName();
      if (mounted && name != null) {
        setState(() {
          _infName     = name;
          _infInitials = name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();
        });
      }
    }
  }

  void _goToTab(int i) => setState(() => _index = i);

  void _selectPassage(PassageInfirmierApi passage) {
    setState(() {
      _selectedPassage = passage;
      _index           = 1;
    });
  }

  // Appelé après validation des constantes
  void _onConstantesSaved() {
    _selectedPassage = null;
    _passagesRefresh.value++;
    _goToTab(0);
  }

  @override
  void dispose() {
    _passagesRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      InfirmierPassagesScreen(
        onSelectPassage: _selectPassage,
        refreshNotifier: _passagesRefresh,
      ),
      InfirmierSaisieConstantesScreen(
        passage:         _selectedPassage,
        infName:         _infName,
        infInitials:     _infInitials,
        onSaved:         _onConstantesSaved,
        onCancel:        () => _goToTab(0),
      ),
      const InfirmierMonActiviteScreen(),
      const InfirmierProfilScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _goToTab,
        selectedItemColor:   AppColors.roleInfirmier,
        unselectedItemColor: AppColors.textLight,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),          activeIcon: Icon(Icons.home),          label: 'À constanter'),
          BottomNavigationBarItem(icon: Icon(Icons.monitor_heart_outlined), activeIcon: Icon(Icons.monitor_heart), label: 'Constantes'),
          BottomNavigationBarItem(icon: Icon(Icons.history),                activeIcon: Icon(Icons.history),       label: 'Mon activité'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),         activeIcon: Icon(Icons.person),        label: 'Profil'),
        ],
      ),
    );
  }
}
