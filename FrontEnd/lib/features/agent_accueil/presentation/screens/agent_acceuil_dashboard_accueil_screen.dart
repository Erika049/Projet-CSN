import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../data/agent_accueil_mock_data.dart';
import '../../data/agent_accueil_service.dart';
import '../widgets/agent_accueil_widgets.dart';

/// Écran "Dashboard accueil" (AGENT 14/41).
///
/// [onOpenScanner] permet de basculer vers l'onglet Scanner depuis les
/// raccourcis du dashboard.
///
/// Les données (profil agent + admissions du jour) sont chargées via
/// [AgentAccueilService] : API en ligne, données fictives en hors-réseau.
class DashboardAccueilScreen extends StatefulWidget {
  final VoidCallback onOpenScanner;

  const DashboardAccueilScreen({super.key, required this.onOpenScanner});

  @override
  State<DashboardAccueilScreen> createState() => _DashboardAccueilScreenState();
}

class _DashboardAccueilScreenState extends State<DashboardAccueilScreen> {
  final AgentAccueilService _service = AgentAccueilService.create();

  AgentProfile? _agent;
  List<Admission> _admissions = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final agent = await _service.getAgentProfile();
      final admissions = await _service.getAdmissions();
      if (!mounted) return;
      setState(() {
        _agent = agent;
        _admissions = admissions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  int get _nbUrgences =>
      _admissions.where((a) => a.statut == AdmissionStatut.urgence).length;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 48, color: AppColors.textLight),
                const SizedBox(height: 12),
                const Text('Impossible de charger le tableau de bord',
                    style: AppTextStyles.h4, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _loadData,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final agent = _agent!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              // En-tête : lieu + "Bonjour <prénom>" + avatar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(agent.lieu, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 2),
                        Text('Bonjour ${agent.prenom}', style: AppTextStyles.h1),
                      ],
                    ),
                  ),
                  InitialsAvatar(
                    initials: agent.initials,
                    size: 44,
                    background: AppColors.successLight,
                    foreground: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3 cartes de stats (dérivées des admissions chargées)
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: '${_admissions.length}',
                      label: 'ADMISSIONS',
                      valueColor: AppColors.textDark,
                      background: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      value: '${_admissions.length - _nbUrgences}',
                      label: 'STANDARD',
                      valueColor: AppColors.warning,
                      background: AppColors.warningLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      value: '$_nbUrgences',
                      label: 'URGENCE',
                      valueColor: AppColors.error,
                      background: AppColors.errorLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Grosse CTA bleue : "Scanner une carte patient"
              GestureDetector(
                onTap: widget.onOpenScanner,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scanner une carte patient',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Identification instantanée via QR',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const SectionHeader(
                title: 'Admissions du jour',
                actionLabel: 'Tout voir',
              ),
              const SizedBox(height: 12),

              for (final a in _admissions) ...[
                _AdmissionRow(admission: a),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 4),
              AppCard(
                onTap: () {},
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: AppColors.success),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nouveau patient',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Créer un dossier + carte numérique',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textLight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdmissionRow extends StatelessWidget {
  final Admission admission;
  const _AdmissionRow({required this.admission});

  @override
  Widget build(BuildContext context) {
    final isUrgence = admission.statut == AdmissionStatut.urgence;

    return AppCard(
      onTap: () {},
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          InitialsAvatar(initials: admission.initials, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admission.nom,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${admission.service} · admis à ${admission.heure}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          StatusChip(
            label: isUrgence ? 'Urgence' : 'OK',
            foreground: isUrgence ? AppColors.error : AppColors.success,
            background: isUrgence ? AppColors.errorLight : AppColors.successLight,
          ),
        ],
      ),
    );
  }
}
