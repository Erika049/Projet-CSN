import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/medecin_api_service.dart';
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
  final _service = MedecinApiService();
  PassageDetail? _passage;
  bool    _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final passage = await _service.getPassageDetail(
          widget.patient.idPassage);
      if (!mounted) { return; }
      setState(() {
        _passage = passage;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) { return; }
      setState(() {
        _loading = false;
        _error   = 'Impossible de charger le dossier.';
      });
    }
  }

  String _constante(String key) {
    if (_passage?.constantesVitales == null) { return '—'; }
    return _passage!.constantesVitales![key]
        ?.toString() ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: AppColors.textLight),
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.textMedium)),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }

    final p = _passage!;

    return Scaffold(
      body: Column(
        children: [
          // ── Header gradient ──────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0B3D91),
                  Color(0xFF1A73E8)
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    20, 12, 20, 18),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              Navigator.pop(context),
                          child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 18),
                        ),
                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4),
                          decoration: BoxDecoration(
                            color: p.estEnCours
                                ? const Color(0xFFFEF3C7)
                                : AppColors.successLight,
                            borderRadius:
                            BorderRadius.circular(999),
                          ),
                          child: Text(
                            p.estEnCours
                                ? 'En cours'
                                : 'Terminé',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: p.estEnCours
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFF1E7E34),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.patient.initiales,
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
                                p.nomComplet,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.patient.age} ans · '
                                    '${widget.patient.groupeSanguin} · '
                                    '${p.hopital}',
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
                        _Chip(p.hopital),
                        _Chip(p.motifVisite),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenu scrollable ───────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  18, 14, 18, 28),
              child: Column(
                children: [
                  // Passage actif
                  if (p.estEnCours) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius:
                        BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius:
                              const BorderRadius
                                  .vertical(
                                  top:
                                  Radius.circular(
                                      16)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      const Text(
                                        'PASSAGE ACTUEL',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight:
                                          FontWeight.w700,
                                          color: AppColors
                                              .primary,
                                          letterSpacing:
                                          0.6,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 4),
                                      Text(
                                        p.motifVisite,
                                        style:
                                        const TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight.w700,
                                          color: AppColors
                                              .textDark,
                                        ),
                                      ),
                                      Text(
                                        p.dateAdmission
                                            .substring(
                                            0,
                                            p.dateAdmission
                                                .length >
                                                16
                                                ? 16
                                                : p.dateAdmission
                                                .length),
                                        style:
                                        const TextStyle(
                                          fontSize: 11,
                                          color: AppColors
                                              .textMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              MedecinConsultationScreen(
                                                patient:
                                                widget.patient,
                                                passage: p,
                                              ),
                                        ),
                                      ),
                                  style: ElevatedButton
                                      .styleFrom(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                        horizontal: 14,
                                        vertical: 10),
                                  ),
                                  child: const Text(
                                      'Consulter ▸'),
                                ),
                              ],
                            ),
                          ),

                          // Constantes vitales
                          if (p.constantesVitales != null)
                            Padding(
                              padding:
                              const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  _ConstanteMini(
                                      label: 'Tension',
                                      value: _constante(
                                          'tension')),
                                  _ConstanteMini(
                                      label: 'Temp.',
                                      value: _constante(
                                          'temperature')),
                                  _ConstanteMini(
                                      label: 'Poids',
                                      value: _constante(
                                          'poids')),
                                  _ConstanteMini(
                                      label: 'Pouls',
                                      value: _constante(
                                          'frequence_cardiaque')),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Diagnostic si existant
                  if (p.diagnostic != null) ...[
                    _SectionCard(
                      title: 'Diagnostic',
                      child: Padding(
                        padding:
                        const EdgeInsets.only(top: 8),
                        child: Text(
                          p.diagnostic!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Prescription si existante
                  if (p.prescriptionOrdonnance != null) ...[
                    _SectionCard(
                      title: 'Prescription',
                      child: Padding(
                        padding:
                        const EdgeInsets.only(top: 8),
                        child: Text(
                          p.prescriptionOrdonnance!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets locaux ─────────────────────────────────────

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.2)),
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
  final String  title;
  final Widget  child;

  const _SectionCard({
    required this.title,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          child,
        ],
      ),
    );
  }
}