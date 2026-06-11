import 'package:flutter/material.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/theme/theme.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/agent_accueil_api_service.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../widgets/agent_accueil_widgets.dart';

/// Écran "Dashboard accueil" (AGENT 14/41).
///
/// Charge le dashboard depuis [GET /api/v1/admission/dashboard/{id}].
/// Ce endpoint retourne en un seul appel : nom de l'agent, nom de l'hôpital,
/// stats du jour (admissions / en attente / urgences) + liste des passages.
/// En cas d'erreur réseau, conserve les dernières données chargées.
class DashboardAccueilScreen extends StatefulWidget {
  final VoidCallback         onOpenScanner;
  final VoidCallback         onNouveauPatient;
  final ValueNotifier<int>?  refreshNotifier;

  const DashboardAccueilScreen({
    super.key,
    required this.onOpenScanner,
    required this.onNouveauPatient,
    this.refreshNotifier,
  });

  @override
  State<DashboardAccueilScreen> createState() => _DashboardAccueilScreenState();
}

class _DashboardAccueilScreenState extends State<DashboardAccueilScreen> {
  final _api   = AgentAccueilApiService();
  final _local = AuthLocalService();

  DashboardAccueilApi? _data;
  bool  _loading = true;
  bool  _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    widget.refreshNotifier?.addListener(_loadDashboard);
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_loadDashboard);
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() { _loading = true; _isOffline = false; });

    try {
      final id = await _local.getUserId();
      if (id == null) {
        // Session absente → pas un problème réseau, on arrête sans forcer offline
        if (mounted) setState(() => _loading = false);
        return;
      }
      final data = await _api.getDashboard(id);
      if (mounted) setState(() { _data = data; _loading = false; });
    } on ApiException catch (e) {
      // Erreur réseau (statusCode 0) → offline
      // Erreur serveur (401, 500…) → pas offline, juste une erreur
      if (mounted) setState(() {
        _loading   = false;
        _isOffline = (e.statusCode == 0);
      });
    } catch (_) {
      // Erreur inattendue → considérer offline uniquement si on n'a pas de données
      if (mounted) setState(() {
        _loading   = false;
        _isOffline = _data == null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboard,
                child: _buildContent(),
              ),
      ),
    );
  }

  Widget _buildContent() {
    // ── Valeurs affichées (données réelles uniquement) ────────────────────────
    final prenom     = _data?.agentPrenom     ?? '—';
    final initiales  = _data?.agentInitials   ?? '?';
    final nomHopital = _data?.nomHopital      ?? 'Hôpital';
    final total      = _data?.totalAdmissions ?? 0;
    final enAttente  = _data?.enAttente       ?? 0;
    final urgences   = _data?.urgences        ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // ── Bannière hors-ligne ──────────────────────────────────────────────
        if (_isOffline) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, size: 15, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _data != null
                        ? 'Hors ligne · dernières données chargées'
                        : 'Hors ligne · aucune donnée disponible',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                  ),
                ),
                GestureDetector(
                  onTap: _loadDashboard,
                  child: const Icon(Icons.refresh, size: 16, color: AppColors.warning),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── En-tête ──────────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nomHopital, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text('Bonjour $prenom', style: AppTextStyles.h1),
                ],
              ),
            ),
            InitialsAvatar(
              initials: initiales,
              size: 44,
              background: AppColors.successLight,
              foreground: AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Stat cards ───────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: total.toString(),
                label: 'ADMISSIONS',
                valueColor: AppColors.textDark,
                background: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                value: enAttente.toString(),
                label: 'EN ATTENTE',
                valueColor: AppColors.warning,
                background: AppColors.warningLight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                value: urgences.toString(),
                label: 'URGENCE',
                valueColor: AppColors.error,
                background: AppColors.errorLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── CTA Scanner ──────────────────────────────────────────────────────
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
                  child: const Icon(Icons.qr_code_scanner, color: Colors.white),
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
                        style: TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
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

        // ── Liste admissions ─────────────────────────────────────────────────
        if (_data == null && _isOffline)
          _buildEmptyOffline()
        else if (_data == null || _data!.admissions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                "Aucune admission enregistrée aujourd'hui.",
                style: TextStyle(color: AppColors.textMedium),
              ),
            ),
          )
        else
          for (final a in _data!.admissions) ...[
            _AdmissionApiRow(admission: a),
            const SizedBox(height: 10),
          ],

        // ── Nouveau patient ──────────────────────────────────────────────────
        const SizedBox(height: 4),
        AppCard(
          onTap: widget.onNouveauPatient,
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
              const Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyOffline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 36, color: AppColors.textLight),
          const SizedBox(height: 12),
          const Text(
            'Aucune donnée disponible hors ligne.\nConnectez-vous au réseau pour charger les admissions.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMedium, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ligne admission depuis l'API
// ---------------------------------------------------------------------------

class _AdmissionApiRow extends StatelessWidget {
  final AdmissionApi admission;
  const _AdmissionApiRow({required this.admission});

  @override
  Widget build(BuildContext context) {
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
                  admission.nomComplet,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${admission.motifVisite} · admis à ${admission.heure}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          StatusChip(
            label: admission.isUrgence ? 'Urgence' : 'OK',
            foreground: admission.isUrgence ? AppColors.error   : AppColors.success,
            background: admission.isUrgence ? AppColors.errorLight : AppColors.successLight,
          ),
        ],
      ),
    );
  }
}

