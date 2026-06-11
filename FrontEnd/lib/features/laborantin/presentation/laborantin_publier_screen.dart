import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../data/laborantin_api_service.dart';
import '../data/laborantin_models.dart';

class LaborantinPublierScreen extends StatefulWidget {
  final PassageEnAttente passage;

  const LaborantinPublierScreen({
    super.key,
    required this.passage,
  });

  @override
  State<LaborantinPublierScreen> createState() =>
      _LaborantinPublierScreenState();
}

class _LaborantinPublierScreenState
    extends State<LaborantinPublierScreen> {
  final _service           = LaborantinApiService();
  final _typeController    = TextEditingController();
  final _resultatsController = TextEditingController();
  bool  _isSaving = false;

  // Types d'examens fréquents
  final List<String> _typesSuggeres = [
    'Hémogramme (NFS)',
    'Test Paludisme',
    'Glycémie à jeun',
    'Bilan lipidique',
    'Créatininémie',
    'Transaminases (ASAT/ALAT)',
    'Radiographie',
    'Échographie',
    'ECG',
    'Analyse urine',
  ];

  @override
  void dispose() {
    _typeController.dispose();
    _resultatsController.dispose();
    super.dispose();
  }

  Future<void> _publier() async {
    if (_typeController.text.trim().isEmpty) {
      _showSnack('Veuillez saisir le type d\'examen',
          isError: true);
      return;
    }
    if (_resultatsController.text.trim().isEmpty) {
      _showSnack('Veuillez saisir les résultats',
          isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _service.publierExamen(
        idPassage:  widget.passage.idPassage,
        typeExamen: _typeController.text.trim(),
        resultats:  _resultatsController.text.trim(),
      );
      if (!mounted) { return; }
      _showSnack('Résultats publiés sur le carnet '
          'du patient ✓');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) { return; }
      _showSnack('Erreur : ${e.toString()}',
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnack(String msg,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? AppColors.error
            : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Publier résultats'),
        actions: [
          Padding(
            padding:
            const EdgeInsets.only(right: 16),
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
                  'Labo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
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
                  // ── Contexte patient ────────────
                  Container(
                    padding:
                    const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.warning
                                .withValues(
                                alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.passage.initiales,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w700,
                                color:
                                AppColors.warning,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                widget.passage
                                    .nomComplet,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight.w700,
                                  color: AppColors
                                      .textDark,
                                ),
                              ),
                              Text(
                                '${widget.passage.age} ans · '
                                    '${widget.passage.groupeSanguin} · '
                                    '${widget.passage.hopital}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors
                                      .textMedium,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow
                                    .ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Type d'examen ────────────────
                  _LaboCard(
                    icon: Icons.science_outlined,
                    title: 'Type d\'examen',
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors
                                .backgroundWhite,
                            borderRadius:
                            BorderRadius.circular(
                                10),
                            border: Border.all(
                              color: AppColors.warning
                                  .withValues(
                                  alpha: 0.5),
                            ),
                          ),
                          child: TextField(
                            controller:
                            _typeController,
                            style: const TextStyle(
                                fontSize: 13),
                            decoration:
                            const InputDecoration(
                              hintText:
                              'ex: Hémogramme (NFS)',
                              contentPadding:
                              EdgeInsets.all(12),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Suggestions rapides
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _typesSuggeres
                              .map((t) =>
                              GestureDetector(
                                onTap: () =>
                                    setState(() =>
                                    _typeController
                                        .text = t),
                                child: Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                      horizontal:
                                      10,
                                      vertical:
                                      5),
                                  decoration:
                                  BoxDecoration(
                                    color: const Color(
                                        0xFFFEF3C7),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                        999),
                                  ),
                                  child: Text(
                                    t,
                                    style:
                                    const TextStyle(
                                      fontSize: 11,
                                      color: AppColors
                                          .warning,
                                      fontWeight:
                                      FontWeight
                                          .w500,
                                    ),
                                  ),
                                ),
                              ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Résultats ────────────────────
                  _LaboCard(
                    icon: Icons.description_outlined,
                    title: 'Résultats',
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors
                                .backgroundWhite,
                            borderRadius:
                            BorderRadius.circular(
                                10),
                            border: Border.all(
                              color: AppColors.warning
                                  .withValues(
                                  alpha: 0.5),
                            ),
                          ),
                          child: TextField(
                            controller:
                            _resultatsController,
                            maxLines: 6,
                            style: const TextStyle(
                                fontSize: 13,
                                height: 1.55),
                            decoration:
                            const InputDecoration(
                              hintText:
                              'ex: Globules blancs : 11 000 /mm³ (Élevés)\n'
                                  'Hémoglobine : 14.2 g/dL (Normal)',
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

                  // ── Traçabilité ──────────────────
                  Container(
                    padding:
                    const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius:
                      BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined,
                            size: 16,
                            color: AppColors.warning),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cette action sera tracée · '
                                'Le patient recevra une '
                                'notification automatique.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
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

          // ── Bouton publier ────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(
                18, 12, 18, 32),
            decoration: const BoxDecoration(
              color: AppColors.backgroundWhite,
              border: Border(
                  top: BorderSide(
                      color: AppColors.border)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                _isSaving ? null : _publier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
                child: _isSaving
                    ? const SizedBox(
                    width: 20, height: 20,
                    child:
                    CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2))
                    : const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                        Icons
                            .publish_rounded,
                        size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Publier les résultats',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LaboCard extends StatelessWidget {
  final IconData icon;
  final String   title;
  final Widget   child;

  const _LaboCard({
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
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: Icon(icon,
                    color: AppColors.warning,
                    size: 16),
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