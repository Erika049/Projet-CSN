import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../data/medecin_api_service.dart';
import '../../data/medecin_models.dart';

class MedecinDashboardScreen extends StatefulWidget {
  final void Function(int index)? onSwitchTab;
  const MedecinDashboardScreen({super.key, this.onSwitchTab});

  @override
  State<MedecinDashboardScreen> createState() =>
      _MedecinDashboardScreenState();
}

class _MedecinDashboardScreenState
    extends State<MedecinDashboardScreen> {
  final _service     = MedecinApiService();
  final _authService = AuthLocalService();

  String?             _nom;
  StatsDuJour?        _stats;
  List<PatientDuJour> _patients = [];
  bool                _loading  = true;
  String?             _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final nom = await _authService.getUserName();
      final results = await Future.wait([
        _service.getStatsDuJour(),
        _service.getPatientsDuJour(),
      ]);
      if (!mounted) { return; }
      setState(() {
        _nom      = nom;
        _stats    = results[0] as StatsDuJour;
        _patients = results[1] as List<PatientDuJour>;
        _loading  = false;
      });
    } catch (e) {
      if (!mounted) { return; }
      final message = e.toString().contains('timeout') ||
          e.toString().contains('longer than')
          ? 'Le serveur met du temps à répondre.\n'
          'Cliquez sur Réessayer dans quelques secondes.'
          : 'Impossible de charger les données.\n'
          'Vérifiez votre connexion.';
      setState(() {
        _loading = false;
        _error   = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(
              color: AppColors.success, strokeWidth: 2),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 64, color: AppColors.textLight),
                const SizedBox(height: 16),
                const Text(
                  'Impossible de charger\nles données',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                      height: 1.5),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Réessayer')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.success,
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      if (_stats != null)
                        _buildStats(_stats!),
                      const SizedBox(height: 24),
                      _buildPatientsDuJour(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person_outline,
                  color: AppColors.success, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonjour Dr,',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium),
                ),
                Text(
                  _nom ?? 'Médecin',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(StatsDuJour stats) {
    return Row(
      children: [
        _StatCard(
          label: 'Total',
          value: stats.total.toString(),
          color: AppColors.primary,
          bg:    AppColors.primaryLight,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'En cours',
          value: stats.enCours.toString(),
          color: AppColors.success,
          bg:    AppColors.successLight,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Urgences',
          value: stats.urgences.toString(),
          color: AppColors.error,
          bg:    AppColors.errorLight,
        ),
      ],
    );
  }

  Widget _buildPatientsDuJour() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Patients du jour',
                style: AppTextStyles.h4),
            Text(
              '${_patients.length} patient'
                  '${_patients.length > 1 ? 's' : ''}',
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_patients.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline,
                      size: 40,
                      color: AppColors.textLight),
                  SizedBox(height: 8),
                  Text(
                    'Aucun patient aujourd\'hui',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMedium),
                  ),
                ],
              ),
            ),
          )
        else
          ..._patients.map(
                (p) => _PatientCard(
              patient: p,
              onTap: () =>
                  widget.onSwitchTab?.call(1),
            ),
          ),
      ],
    );
  }
}

// ── Widgets locaux ────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;
  final Color  bg;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final PatientDuJour patient;
  final VoidCallback?  onTap;

  const _PatientCard({
    required this.patient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool urgent = patient.statut == 'urgence';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: urgent
                ? AppColors.error.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: urgent
                    ? AppColors.error
                    .withValues(alpha: 0.12)
                    : AppColors.success
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  patient.initiales,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: urgent
                          ? AppColors.error
                          : AppColors.success),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.nomComplet,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${patient.age} ans · '
                        '${patient.groupeSanguin} · '
                        '${patient.motifVisite}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMedium),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              patient.heure,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}