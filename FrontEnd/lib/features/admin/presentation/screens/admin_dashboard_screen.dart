import 'package:flutter/material.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../data/admin_api_service.dart';
import '../../data/admin_models.dart';

class AdminDashboardScreen extends StatefulWidget {
  final void Function(int index)? onNavigate;

  const AdminDashboardScreen({
    super.key,
    this.onNavigate,
  });

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  final _service     = AdminApiService();
  final _authService = AuthLocalService();

  String?     _nom;
  AdminStats? _stats;
  bool        _loading = true;
  String?     _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final nom   = await _authService.getUserName();
      final stats = await _service.getStats();
      if (!mounted) { return; }
      setState(() {
        _nom     = nom;
        _stats   = stats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) { return; }
      setState(() {
        _loading = false;
        _error   = 'Impossible de charger.';
      });
    }
  }

  String _initiales(String? nom) {
    if (nom == null || nom.isEmpty) { return 'AD'; }
    return nom
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B1A3D),
        body: Center(
          child: CircularProgressIndicator(
              color: Colors.white54,
              strokeWidth: 2),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1A3D),
        body: Center(
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48,
                  color: Colors.white38),
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(
                      color: Colors.white60)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loadData,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                      color: Colors.white30),
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1A3D),
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor:
          const Color(0xFF1E3A6E),
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                20, 20, 20, 32),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CONSOLE ADMIN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                              FontWeight.w700,
                              color:
                              Color(0xFF4A6FA5),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _nom ?? 'Administrateur',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight:
                              FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const Text(
                            'Supervision · Personnel'
                                ' · Hôpitaux · Audit',
                            style: TextStyle(
                              fontSize: 11,
                              color:
                              Color(0xFF4A6FA5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFF1E3A6E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(
                              0xFF2D5A9E),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _initiales(_nom),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── KPI ──────────────────────────
                const Text(
                  'VUE D\'ENSEMBLE (KPI)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A6FA5),
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 14),

                if (_stats != null) ...[
                  Row(
                    children: [
                      _KpiCard(
                        icon: Icons.people_outline,
                        label: 'Patients',
                        value: _stats!.nbPatients
                            .toString(),
                        color:
                        const Color(0xFF4FC3F7),
                        bg: const Color(0xFF0D2B4A),
                        // ── KPI cliquable ───────
                        onTap: null,
                      ),
                      const SizedBox(width: 12),
                      _KpiCard(
                        icon: Icons
                            .medical_services_outlined,
                        label: 'Personnel',
                        value: _stats!.nbPersonnel
                            .toString(),
                        color:
                        const Color(0xFF81C784),
                        bg: const Color(0xFF0D3A1A),
                        onTap: () =>
                            widget.onNavigate
                                ?.call(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _KpiCard(
                        icon: Icons
                            .local_hospital_outlined,
                        label: 'Hôpitaux',
                        value: _stats!.nbHopitaux
                            .toString(),
                        color:
                        const Color(0xFFCE93D8),
                        bg: const Color(0xFF2A1040),
                        onTap: () =>
                            widget.onNavigate
                                ?.call(2),
                      ),
                      const SizedBox(width: 12),
                      _KpiCard(
                        icon: Icons.today_outlined,
                        label: 'Passages/jour',
                        value: _stats!
                            .nbPassagesAujourdhui
                            .toString(),
                        color:
                        const Color(0xFFFFB74D),
                        bg: const Color(0xFF3A2000),
                        onTap: null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _KpiCardFull(
                    icon: Icons.science_outlined,
                    label:
                    'Examens publiés aujourd\'hui',
                    value: _stats!.nbExamensAujourdhui
                        .toString(),
                    color: const Color(0xFF80CBC4),
                    bg: const Color(0xFF0D2E2B),
                  ),
                ],

                const SizedBox(height: 28),

                // ── Accès rapides ────────────────
                const Text(
                  'ACCÈS RAPIDES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A6FA5),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    _QuickAction(
                      icon:
                      Icons.person_add_outlined,
                      label: 'Nouveau\ncompte',
                      // ── Navigate vers Personnel
                      // + ouvre le sheet de création
                      onTap: () =>
                          widget.onNavigate
                              ?.call(1),
                    ),
                    const SizedBox(width: 10),
                    _QuickAction(
                      icon: Icons
                          .add_business_outlined,
                      label: 'Nouvel\nhôpital',
                      onTap: () =>
                          widget.onNavigate
                              ?.call(2),
                    ),
                    const SizedBox(width: 10),
                    _QuickAction(
                      icon: Icons.history_outlined,
                      label: 'Journal\naudit',
                      onTap: () =>
                          widget.onNavigate
                              ?.call(3),
                    ),
                    const SizedBox(width: 10),
                    _QuickAction(
                      icon: Icons.refresh_rounded,
                      label: 'Actualiser',
                      onTap: _loadData,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets locaux ─────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final IconData      icon;
  final String        label;
  final String        value;
  final Color         color;
  final Color         bg;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  if (onTap != null) ...[
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: color.withValues(
                          alpha: 0.5),
                      size: 12,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCardFull extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;
  final Color    bg;

  const _KpiCardFull({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white60),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A6E),
            borderRadius:
            BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2D5A9E),
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: Colors.white70,
                  size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}