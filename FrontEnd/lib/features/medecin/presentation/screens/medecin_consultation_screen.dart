import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../data/medecin_models.dart';

class MedecinConsultationScreen extends StatefulWidget {
  final PatientDuJour patient;
  final PassageDetail passage;

  const MedecinConsultationScreen({
    super.key,
    required this.patient,
    required this.passage,
  });

  @override
  State<MedecinConsultationScreen> createState() =>
      _MedecinConsultationScreenState();
}

class _MedecinConsultationScreenState
    extends State<MedecinConsultationScreen> {
  final _diagnosticController   = TextEditingController();
  final _prescriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _diagnosticController.text =
        widget.passage.diagnostic ?? '';
    _prescriptionController.text =
        widget.passage.prescriptionOrdonnance ?? '';
  }

  @override
  void dispose() {
    _diagnosticController.dispose();
    _prescriptionController.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder({bool cloturer = false}) async {
    if (_diagnosticController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un diagnostic.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final dio = ApiClient.instance.dio;
      await dio.put(
        ApiEndpoints.consultation(
            widget.passage.idPassage),
        data: {
          'diagnostic': _diagnosticController.text.trim(),
          'prescriptionOrdonnance':
          _prescriptionController.text.trim(),
          'cloturerPassage': cloturer,
        },
      );
      if (!mounted) { return; }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cloturer
              ? 'Passage clôturé avec succès'
              : 'Consultation sauvegardée'),
          backgroundColor: cloturer
              ? AppColors.success
              : AppColors.primary,
        ),
      );
      if (cloturer) { Navigator.pop(context); }
    } catch (e) {
      if (!mounted) { return; }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Consultation'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius:
                  BorderRadius.circular(999),
                ),
                child: const Text(
                  'Brouillon',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  18, 8, 18, 20),
              child: Column(
                children: [
                  // ── Contexte patient ────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.patient.initiales,
                              style: const TextStyle(
                                fontSize: 13,
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
                              Text(
                                widget.patient.nomComplet,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                widget.passage.motifVisite,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color:
                                  AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Diagnostic ───────────────────────
                  _ConsultCard(
                    icon: Icons.person_outline,
                    title: 'Diagnostic',
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color:
                            AppColors.backgroundWhite,
                            borderRadius:
                            BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primary
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: TextField(
                            controller:
                            _diagnosticController,
                            maxLines: 4,
                            style: const TextStyle(
                                fontSize: 13,
                                height: 1.55),
                            decoration:
                            const InputDecoration(
                              hintText:
                              'Saisissez le diagnostic…',
                              contentPadding:
                              EdgeInsets.all(12),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Prescription ─────────────────────
                  _ConsultCard(
                    icon: Icons.medication_outlined,
                    title: 'Prescription / Ordonnance',
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color:
                            AppColors.backgroundWhite,
                            borderRadius:
                            BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primary
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: TextField(
                            controller:
                            _prescriptionController,
                            maxLines: 4,
                            style: const TextStyle(
                                fontSize: 13,
                                height: 1.55),
                            decoration:
                            const InputDecoration(
                              hintText:
                              'ex: Amoxicilline 1g · '
                                  '3x/jour · 5 jours',
                              contentPadding:
                              EdgeInsets.all(12),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Traçabilité ──────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                      BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined,
                            size: 16,
                            color: AppColors.primary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cette action sera tracée dans '
                                'logs_tracabilite — '
                                'Action : MODIF_DIAGNOSTIC.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Boutons ──────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(
                18, 12, 18, 32),
            decoration: const BoxDecoration(
              color: AppColors.backgroundWhite,
              border: Border(
                  top: BorderSide(
                      color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _sauvegarder(),
                    child: const Text('Enregistrer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () =>
                        _sauvegarder(cloturer: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                        CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2))
                        : const Text('Clôturer le passage'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget local ──────────────────────────────────────

class _ConsultCard extends StatelessWidget {
  final IconData icon;
  final String   title;
  final Widget   child;

  const _ConsultCard({
    required this.icon,
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
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}