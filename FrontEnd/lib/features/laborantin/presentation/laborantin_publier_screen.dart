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
  final _service = LaborantinApiService();

  String _typeExamen = 'Hémogramme (NFS)';
  final List<_ResultatLigne> _resultats = [];
  bool _isSaving = false;

  final List<String> _typesSuggeres = [
    'Hémogramme (NFS)',
    'Test Paludisme',
    'Glycémie à jeun',
    'Glycémie urgence',
    'HbA1c',
    'Bilan lipidique',
    'Créatininémie',
    'Transaminases (ASAT/ALAT)',
    'Radiographie thorax',
    'Échographie abdominale',
    'ECG repos',
    'Analyse urine',
  ];

  String _datePrelevement() {
    final now = DateTime.now();
    const mois = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai',
      'Juin', 'Juil', 'Août', 'Sep', 'Oct',
      'Nov', 'Déc'
    ];
    return '${now.day} ${mois[now.month]} ${now.year}'
        ' · ${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  void _ajouterLigne() {
    showDialog(
      context: context,
      builder: (_) {
        final nomCtrl    = TextEditingController();
        final valeurCtrl = TextEditingController();
        final uniteCtrl  = TextEditingController();
        String statut = 'Normal';

        return StatefulBuilder(
          builder: (ctx, setDialog) => AlertDialog(
            title: const Text('Ajouter une valeur'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Paramètre',
                    hintText: 'ex: Globules blancs',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: valeurCtrl,
                        decoration:
                        const InputDecoration(
                          labelText: 'Valeur',
                          hintText: '11 000',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: uniteCtrl,
                        decoration:
                        const InputDecoration(
                          labelText: 'Unité',
                          hintText: '/mm³',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: ['Normal', 'Élevé', 'Bas']
                      .map((s) => GestureDetector(
                    onTap: () => setDialog(
                            () => statut = s),
                    child: Container(
                      margin:
                      const EdgeInsets
                          .only(right: 8),
                      padding:
                      const EdgeInsets
                          .symmetric(
                          horizontal: 10,
                          vertical: 5),
                      decoration: BoxDecoration(
                        color: statut == s
                            ? _statutColor(s)
                            : const Color(
                            0xFFF1F3F4),
                        borderRadius:
                        BorderRadius
                            .circular(999),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w600,
                          color: statut == s
                              ? Colors.white
                              : AppColors
                              .textMedium,
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nomCtrl.text.isNotEmpty &&
                      valeurCtrl.text.isNotEmpty) {
                    setState(() {
                      _resultats.add(_ResultatLigne(
                        nom:    nomCtrl.text,
                        valeur: valeurCtrl.text,
                        unite:  uniteCtrl.text,
                        statut: statut,
                      ));
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'Élevé': return const Color(0xFFE65100);
      case 'Bas':   return AppColors.error;
      default:      return AppColors.success;
    }
  }

  Color _statutBg(String statut) {
    switch (statut) {
      case 'Élevé': return const Color(0xFFFFF3E0);
      case 'Bas':   return AppColors.errorLight;
      default:      return AppColors.successLight;
    }
  }

  String _buildResultatsString() {
    if (_resultats.isEmpty) { return ''; }
    return _resultats.map((r) =>
    '${r.nom} : ${r.valeur} ${r.unite} (${r.statut})'
    ).join('\n');
  }

  Future<void> _publier() async {
    if (_resultats.isEmpty) {
      _showSnack(
          'Ajoutez au moins une valeur', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      await _service.publierExamen(
        idPassage:  widget.passage.idPassage,
        typeExamen: _typeExamen,
        resultats:  _buildResultatsString(),
      );
      if (!mounted) { return; }
      _showSnack('Résultats publiés sur le'
          ' carnet du patient ✓');
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
          icon: const Icon(
              Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Publier un examen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  18, 12, 18, 20),
              child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
              // ── Contexte patient ────────────
              Container(
              padding:
              const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                AppColors.backgroundWhite,
                borderRadius:
                BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(
                          alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.passage
                            .initiales,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          AppColors.primary,
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
                          'Passage ${widget.passage.idPassage.length > 8 ? '${widget.passage.idPassage.substring(0, 8)}···' : widget.passage.idPassage}'
                              ' · ${widget.passage.heure}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors
                                .textMedium,
                            fontFamily:
                            'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                        horizontal: 8,
                        vertical: 4),
                    decoration: BoxDecoration(
                      color:
                      AppColors.primaryLight,
                      borderRadius:
                      BorderRadius.circular(
                          999),
                    ),
                    child: Text(
                      widget.passage
                          .motifVisite,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Type d'examen ────────────────
            Container(
              padding:
              const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                AppColors.backgroundWhite,
                borderRadius:
                BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
              Row(
              children: [
              Container(
              width: 28, height: 28,
                decoration: BoxDecoration(
                  color: AppColors
                      .primaryLight,
                  borderRadius:
                  BorderRadius
                      .circular(8),
                ),
                child: const Icon(
                  Icons.science_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Type d\'examen',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                  FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              ],
            ),
            const SizedBox(height: 12),
            // Dropdown
            Container(
              padding:
              const EdgeInsets.symmetric(
                  horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(
                    0xFFF8F9FA),
                borderRadius:
                BorderRadius.circular(
                    10),
                border: Border.all(
                    color: AppColors.border),
              ),
              child:
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _typeExamen,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMedium,
                  ),
                  items: _typesSuggeres
                      .map((t) => DropdownMenuItem<String>(
                    value: t,
                    child: Text(
                      t,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                  ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _typeExamen = v);
                    }
                  },
                ),
              ),
          ),
          const SizedBox(height: 12),
          // Date prélèvement
          const Text(
            'DATE DU PRÉLÈVEMENT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMedium,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding:
            const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12),
            decoration: BoxDecoration(
              color: const Color(
                  0xFFF8F9FA),
              borderRadius:
              BorderRadius.circular(
                  10),
              border: Border.all(
                  color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons
                      .calendar_today_outlined,
                  size: 16,
                  color:
                  AppColors.textMedium,
                ),
                const SizedBox(width: 8),
                Text(
                  _datePrelevement(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),

    const SizedBox(height: 14),

    // ── Résultats ────────────────────
    Container(
    padding:
    const EdgeInsets.all(14),
    decoration: BoxDecoration(
    color:
    AppColors.backgroundWhite,
    borderRadius:
    BorderRadius.circular(14),
    border: Border.all(
    color: AppColors.border),
    ),
    child: Column(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [
    Row(
    children: [
    Container(
    width: 28, height: 28,
    decoration: BoxDecoration(
    color: AppColors
        .primaryLight,
    borderRadius:
    BorderRadius
        .circular(8),
    ),
    child: const Icon(
    Icons
        .description_outlined,
    size: 16,
    color: AppColors.primary,
    ),
    ),
    const SizedBox(width: 10),
    const Text(
    'Résultats',
    style: TextStyle(
    fontSize: 13,
    fontWeight:
    FontWeight.w700,
    color: AppColors.textDark,
    ),
    ),
    const SizedBox(width: 6),
    if (_resultats.isNotEmpty)
    Text(
    '${_resultats.length} valeurs'
    ' · ${_resultats.where((r) => r.statut != 'Normal').length} anormale(s)',
    style: const TextStyle(
    fontSize: 11,
    color:
    AppColors.textMedium,
    ),
    ),
    ],
    ),
    const SizedBox(height: 12),

    // Lignes de résultats
    ..._resultats
        .asMap()
        .entries
        .map((entry) {
    final i = entry.key;
    final r = entry.value;
    return Container(
    margin:
    const EdgeInsets.only(
    bottom: 8),
    padding:
    const EdgeInsets
        .symmetric(
    horizontal: 12,
    vertical: 10),
    decoration: BoxDecoration(
    color: const Color(
    0xFFF8F9FA),
    borderRadius:
    BorderRadius.circular(
    10),
    border: Border.all(
    color:
    AppColors.border),
    ),
    child: Row(
    children: [
    Expanded(
    child: Column(
    crossAxisAlignment:
    CrossAxisAlignment
        .start,
    children: [
    Text(
    r.nom,
    style:
    const TextStyle(
    fontSize: 12,
    color: AppColors
        .textMedium,
    ),
    ),
    RichText(
    text: TextSpan(
    children: [
    TextSpan(
    text: r.valeur,
    style:
    const TextStyle(
    fontSize:
    16,
    fontWeight:
    FontWeight
        .w700,
    color: AppColors
        .textDark,
    ),
    ),
    if (r.unite
        .isNotEmpty)
    TextSpan(
    text:
    ' ${r.unite}',
    style:
    const TextStyle(
    fontSize:
    12,
    color: AppColors
        .textMedium,
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    Container(
    padding:
    const EdgeInsets
        .symmetric(
    horizontal: 10,
    vertical: 4),
    decoration:
    BoxDecoration(
    color: _statutBg(
    r.statut),
    borderRadius:
    BorderRadius
        .circular(
    999),
    ),
    child: Text(
    r.statut == 'Élevé'
    ? '↑ ${r.statut}'
        : r.statut ==
    'Bas'
    ? '↓ ${r.statut}'
        : r.statut,
    style: TextStyle(
    fontSize: 11,
    fontWeight:
    FontWeight.w600,
    color: _statutColor(
    r.statut),
    ),
    ),
    ),
    const SizedBox(width: 8),
    GestureDetector(
    onTap: () =>
    setState(() =>
    _resultats
        .removeAt(
    i)),
    child: const Icon(
    Icons.close,
    size: 16,
    color: AppColors
        .textLight,
    ),
    ),
    ],
    ),
    );
    }),

    // Bouton ajouter une valeur
    GestureDetector(
    onTap: _ajouterLigne,
    child: Container(
    width: double.infinity,
    padding:
    const EdgeInsets
        .symmetric(
    vertical: 12),
    decoration: BoxDecoration(
    borderRadius:
    BorderRadius.circular(
    10),
    border: Border.all(
    color: AppColors.border,
    ),
    ),
    child: const Row(
    mainAxisAlignment:
    MainAxisAlignment
        .center,
    children: [
    Icon(Icons.add_rounded,
    size: 16,
    color:
    AppColors.primary),
    SizedBox(width: 6),
    Text(
    'Ajouter une valeur',
    style: TextStyle(
    fontSize: 13,
    fontWeight:
    FontWeight.w600,
    color:
    AppColors.primary,
    ),
    ),
    ],
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
    'Cette publication sera tracée'
    ' · Le patient recevra une'
    ' notification automatique.',
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

    // ── Boutons ──────────────────────────────
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
        : () => Navigator.pop(context),
    child: const Text(
    'Enregistrer brouillon'),
    ),
    ),
    const SizedBox(width: 12),
    Expanded(
    flex: 2,
    child: ElevatedButton(
    onPressed:
    _isSaving ? null : _publier,
    child: _isSaving
    ? const SizedBox(
    width: 20, height: 20,
    child:
    CircularProgressIndicator(
    color: Colors.white,
    strokeWidth: 2,
    ),
    )
        : const Row(
    mainAxisAlignment:
    MainAxisAlignment.center,
    children: [
    Icon(Icons.check_rounded,
    size: 16),
    SizedBox(width: 6),
    Text('Publier au dossier'),
    ],
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
}

// ── Classes locales ────────────────────────────────────

class _ResultatLigne {
  final String nom;
  final String valeur;
  final String unite;
  final String statut;

  const _ResultatLigne({
    required this.nom,
    required this.valeur,
    required this.unite,
    required this.statut,
  });
}