import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/patient_api_service.dart';
import '../../data/patient_models.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import 'patient_notifications_screen.dart';
import 'patient_detail_passage_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  final void Function(int index)? onSwitchTab;
  const PatientHomeScreen({super.key, this.onSwitchTab});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final _service = PatientApiService();
  final _authService = AuthLocalService();

  String? _patientId;
  Patient? _patient;
  PassageMedical? _passageEnCours;
  int _notifCount = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatientId();
  }

  Future<void> _loadPatientId() async {
    _patientId = await _authService.getUserId();
    if (_patientId != null) {
      _loadData();
    } else {
      if (!mounted) { return; }
      setState(() {
        _loading = false;
        _error = 'Session introuvable. Veuillez vous reconnecter.';
      });
    }
  }

  Future<void> _loadData() async {
    if (_patientId == null) { return; }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.getProfil(_patientId!),
        _service.getPassageEnCours(_patientId!),
        _service.getNombreNonLues(_patientId!),
      ]);
      if (!mounted) { return; }
      setState(() {
        _patient = results[0] as Patient;
        _passageEnCours = results[1] as PassageMedical?;
        _notifCount = results[2] as int;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) { return; }
      // Message lisible selon le type d'erreur
      final message = e.toString().contains('timeout') ||
          e.toString().contains('longer than')
          ? 'Le serveur met du temps à répondre.\nCliquez sur Réessayer dans quelques secondes.'
          : 'Impossible de charger les données.\nVérifiez votre connexion.';
      setState(() {
        _loading = false;
        _error = message;
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
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_error != null || _patient == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Impossible de charger\nles données',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error ?? 'Données indisponibles',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMedium,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final patient = _patient!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(patient),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCarteNumerique(patient),
                      const SizedBox(height: 12),
                      if (_passageEnCours != null) ...[
                        _buildPassageEnCours(_passageEnCours!),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 8),
                      _buildGrille(),
                      const SizedBox(height: 20),
                      if (_passageEnCours != null)
                        _buildDernierPassage(_passageEnCours!),
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

  Widget _buildHeader(Patient patient) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          20, 16, 20, 0),
      child: Row(
        children: [
          // ── Initiales à gauche ─────────────────
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                patient.initiales,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonjour,',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMedium,
                  ),
                ),
                Text(
                  patient.nomComplet,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          // ── Cloche notifications ───────────────
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const PatientNotificationsScreen(),
              ),
            ),
            child: Stack(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: AppColors.textDark,
                  ),
                ),
                if (_notifCount > 0)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarteNumerique(Patient patient) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CARTE SANTÉ NUMÉRIQUE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      patient.nomComplet,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID · ${patient.id.length > 14 ? '${patient.id.substring(0, 8)}···${patient.id.substring(patient.id.length - 6)}' : patient.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: QrImageView(
                  data: patient.carte.qrCodeToken.isNotEmpty
                      ? patient.carte.qrCodeToken
                      : patient.id,
                  version: QrVersions.auto,
                  size: 64,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _CarteInfo(
                label: 'GROUPE',
                value: patient.groupeSanguin,
              ),
              const SizedBox(width: 24),
              _CarteInfo(
                label: 'NÉ(E) LE',
                value: patient.dateNaissance,
              ),
              const SizedBox(width: 24),
              _CarteInfo(
                label: 'STATUT',
                value: patient.carte.estActive
                    ? '● Actif'
                    : '● Inactif',
                valueColor: patient.carte.estActive
                    ? const Color(0xFF7BD491)
                    : AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassageEnCours(PassageMedical passage) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_hospital_outlined,
              color: AppColors.success,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vous êtes à ${passage.hopital}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  passage.service,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'En cours',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrille() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _GridCard(
          icon: Icons.qr_code_2_rounded,
          title: 'Ma carte QR',
          subtitle: 'Présenter à l\'accueil',
          iconColor: AppColors.primary,
          iconBg: const Color(0xFFE8F0FE),
          onTap: () => widget.onSwitchTab?.call(1),
        ),
        _GridCard(
          icon: Icons.history_rounded,
          title: 'Historique',
          subtitle: 'Mes passages',
          iconColor: const Color(0xFF0B6E4F),
          iconBg: const Color(0xFFE6F4EA),
          onTap: () => widget.onSwitchTab?.call(2),
        ),
        _GridCard(
          icon: Icons.medication_outlined,
          title: 'Mes ordonnances',
          subtitle: 'Actives & archives',
          iconColor: const Color(0xFFB45309),
          iconBg: const Color(0xFFFEF3C7),
          onTap: () => widget.onSwitchTab?.call(3),
        ),
        _GridCard(
          icon: Icons.local_hospital_outlined,
          title: 'Hôpitaux',
          subtitle: 'Établissements',
          iconColor: const Color(0xFF7C3AED),
          iconBg: const Color(0xFFEDE9FE),
          onTap: _showHopitauxSheet,
        ),
      ],
    );
  }

  void _showHopitauxSheet() {
    const hopitaux = [
      ('Hôpital Général', 'Yaoundé · Cardiologie, Urgences, Labo'),
      ('Clinique Pasteur', 'Douala · Médecine générale, Imagerie'),
      ('Hôpital Central', 'Yaoundé · Pédiatrie, Maternité'),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Établissements partenaires',
                    style: AppTextStyles.h4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...hopitaux.map(
                    (h) => ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(
                      horizontal: 24),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_hospital_outlined,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  title: Text(h.$1,
                      style: AppTextStyles.labelLarge),
                  subtitle: Text(h.$2,
                      style: AppTextStyles.bodySmall),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDernierPassage(PassageMedical passage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Passage en cours',
                style: AppTextStyles.h4),
            TextButton(
              onPressed: () => widget.onSwitchTab?.call(2),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
              ),
              child: const Text(
                'Voir tout',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PatientDetailPassageScreen(passage: passage),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        passage.motifVisite,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'En cours',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${passage.hopital} · ${passage.dateAdmission}, ${passage.heureAdmission}',
                  style: AppTextStyles.bodySmall,
                ),
                if (passage.constantes != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (passage.constantes!.tension != null)
                        _ConstanteItem(
                          label: 'TENSION',
                          value: passage.constantes!.tension!,
                        ),
                      if (passage.constantes!.temperature !=
                          null)
                        _ConstanteItem(
                          label: 'TEMP.',
                          value: passage
                              .constantes!.temperature!,
                        ),
                      if (passage.constantes!.poids != null)
                        _ConstanteItem(
                          label: 'POIDS',
                          value: passage.constantes!.poids!,
                        ),
                      if (passage.constantes!.pouls != null)
                        _ConstanteItem(
                          label: 'POULS',
                          value: passage.constantes!.pouls!,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CarteInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _CarteInfo({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.white60,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}

class _GridCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback? onTap;

  const _GridCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConstanteItem extends StatelessWidget {
  final String label;
  final String value;

  const _ConstanteItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textLight,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}