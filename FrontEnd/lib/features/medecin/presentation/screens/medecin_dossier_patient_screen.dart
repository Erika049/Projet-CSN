import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/medecin_mock_service.dart';
import '../../data/medecin_models.dart';
import 'medecin_consultation_screen.dart';

class MedecinDossierPatientScreen extends StatefulWidget {
  final PatientDuJour patient;
  const MedecinDossierPatientScreen({
    super.key,
    required this.patient,
  });

  @override
  State<MedecinDossierPatientScreen> createState() =>
      _MedecinDossierPatientScreenState();
}

class _MedecinDossierPatientScreenState
    extends State<MedecinDossierPatientScreen> {
  final _service = MedecinMockService();
  DossierPatient? _dossier;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dossier = await _service.getDossierPatient(widget.patient.id);
    if (!mounted) { return; }
    setState(() {
      _dossier = dossier;
      _loading = false;
    });
  }

  Color _antecedentColor(String tone) {
    switch (tone) {
      case 'danger': return AppColors.error;
      case 'warning': return const Color(0xFFB45309);
      default: return AppColors.primary;
    }
  }

  Color _antecedentBg(String tone) {
    switch (tone) {
      case 'danger': return AppColors.errorLight;
      case 'warning': return const Color(0xFFFEF3C7);
      default: return AppColors.primaryLight;
    }
  }

  IconData _antecedentIcon(String type) {
    switch (type) {
      case 'allergie': return Icons.warning_amber_rounded;
      case 'maladie': return Icons.monitor_heart_outlined;
      default: return Icons.science_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final d = _dossier!;

    return Scaffold(
      body: Column(
        children: [
          // ── Hero header gradient ──
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0B3D91), Color(0xFF1A73E8)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Passage en cours',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              d.initiales,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.nomComplet,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${d.genre == 'M' ? '♂' : '♀'} · ${d.age} ans · Groupe ${d.groupeSanguin} · ${d.telephone}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 6,
                      children: [
                        _Chip('${d.nbHopitaux} hôpitaux'),
                        _Chip('${d.nbPassages} passages'),
                        _Chip('${d.nbOrdonnancesActives} ordonnances'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenu scrollable ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              child: Column(
                children: [
                  // Passage actif
                  if (d.passageActif != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // Header passage
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              color: AppColors.primaryLight,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'PASSAGE ACTUEL',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight:
                                            FontWeight.w700,
                                            color: AppColors.primary,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          d.passageActif!.motif,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                            FontWeight.w700,
                                            color:
                                            AppColors.textDark,
                                          ),
                                        ),
                                        Text(
                                          "Aujourd'hui · ${d.passageActif!.heure}",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color:
                                            AppColors.textMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MedecinConsultationScreen(
                                              patient: widget.patient,
                                              passageActif:
                                              d.passageActif!,
                                            ),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: const Text('Consulter ▸'),
                                  ),
                                ],
                              ),
                            ),

                            // Constantes vitales
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  if (d.passageActif!.tension != null)
                                    _ConstanteMini(
                                      label: 'Tension',
                                      value: d.passageActif!.tension!,
                                    ),
                                  if (d.passageActif!.temperature !=
                                      null)
                                    _ConstanteMini(
                                      label: 'Temp.',
                                      value:
                                      d.passageActif!.temperature!,
                                    ),
                                  if (d.passageActif!.poids != null)
                                    _ConstanteMini(
                                      label: 'Poids',
                                      value: d.passageActif!.poids!,
                                    ),
                                  if (d.passageActif!.pouls != null)
                                    _ConstanteMini(
                                      label: 'Pouls',
                                      value: d.passageActif!.pouls!,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Antécédents
                  _SectionCard(
                    title: 'Antécédents notables',
                    trailing: "Tout l'historique →",
                    child: Column(
                      children: d.antecedents.map((a) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _antecedentBg(a.tone),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _antecedentIcon(a.type),
                                size: 16,
                                color: _antecedentColor(a.tone),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.titre,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                        _antecedentColor(a.tone),
                                      ),
                                    ),
                                    Text(
                                      a.date,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Derniers passages
                  _SectionCard(
                    title: '3 derniers passages',
                    child: Column(
                      children: d.derniersPassages.map((p) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.circular(10),
                            border:
                            Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F3F4),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.local_hospital_outlined,
                                  size: 14,
                                  color: AppColors.textMedium,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.titre,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    Text(
                                      '${p.hopital} · ${p.date}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== WIDGETS LOCAUX ====================

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ConstanteMini extends StatelessWidget {
  final String label;
  final String value;

  const _ConstanteMini({
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
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textLight,
              letterSpacing: 0.4,
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

class _SectionCard extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}