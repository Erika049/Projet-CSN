import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/medecin_models.dart';

class MedecinConsultationScreen extends StatefulWidget {
  final PatientDuJour patient;
  final PassageActif passageActif;

  const MedecinConsultationScreen({
    super.key,
    required this.patient,
    required this.passageActif,
  });

  @override
  State<MedecinConsultationScreen> createState() =>
      _MedecinConsultationScreenState();
}

class _MedecinConsultationScreenState
    extends State<MedecinConsultationScreen> {
  final _diagnosticController = TextEditingController();
  final List<MedicamentConsult> _medicaments = [
    const MedicamentConsult(
        nom: 'Amlodipine 5 mg',
        posologie: '1 cp / jour · 30 jours'),
    const MedicamentConsult(
        nom: 'Paracétamol 500 mg',
        posologie: 'Si douleur · Au besoin'),
  ];
  final List<String> _examens = [
    'ECG repos',
    'Bilan lipidique',
    'Glycémie à jeun',
  ];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _diagnosticController.text =
        widget.passageActif.diagnostic ?? '';
  }

  @override
  void dispose() {
    _diagnosticController.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder({bool cloturer = false}) async {
    CsnLoaderOverlay.show(
      context,
      message: cloturer
          ? 'Clôture du passage…'
          : 'Enregistrement…',
    );
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) { return; }
    CsnLoaderOverlay.hide(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cloturer
            ? 'Passage clôturé avec succès'
            : 'Consultation sauvegardée'),
        backgroundColor:
        cloturer ? AppColors.success : AppColors.primary,
      ),
    );
    if (cloturer) {
      Navigator.popUntil(
          context, (route) => route.isFirst || route.settings.name == '/medecin');
    }
  }

  void _ajouterMedicament() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final nomCtrl = TextEditingController();
        final poseCtrl = TextEditingController();
        return Padding(
          padding: EdgeInsets.fromLTRB(
              24, 20, 24,
              MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text('Ajouter un médicament',
                  style: AppTextStyles.h4),
              const SizedBox(height: 16),
              TextField(
                controller: nomCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nom du médicament',
                  labelText: 'Médicament',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: poseCtrl,
                decoration: const InputDecoration(
                  hintText: 'ex: 1 cp / jour · 7 jours',
                  labelText: 'Posologie',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (nomCtrl.text.isNotEmpty) {
                      setState(() {
                        _medicaments.add(MedicamentConsult(
                          nom: nomCtrl.text,
                          posologie: poseCtrl.text,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                  borderRadius: BorderRadius.circular(999),
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
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
              child: Column(
                children: [
                  // Context patient
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
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
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'Passage ${widget.passageActif.id.substring(0, 8)}··· · ${widget.passageActif.heure}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMedium,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Diagnostic
                  _ConsultCard(
                    icon: Icons.person_outline,
                    title: 'Diagnostic',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.5)),
                          ),
                          child: TextField(
                            controller: _diagnosticController,
                            maxLines: 4,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.55,
                            ),
                            decoration: const InputDecoration(
                              hintText:
                              'Saisissez le diagnostic…',
                              contentPadding: EdgeInsets.all(12),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: ['CIM-10', 'I10',
                            'Cardiologie']
                              .map((t) => Container(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F4),
                              borderRadius:
                              BorderRadius.circular(999),
                            ),
                            child: Text(
                              '#$t',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Ordonnance
                  _ConsultCard(
                    icon: Icons.medication_outlined,
                    title: 'Ordonnance',
                    subtitle:
                    '${_medicaments.length} médicaments',
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        ..._medicaments.map(
                              (med) => Container(
                            margin: const EdgeInsets.only(
                                bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFBFC),
                              borderRadius:
                              BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color:
                                    AppColors.backgroundWhite,
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.medication_outlined,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        med.nom,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                          FontWeight.w600,
                                          color:
                                          AppColors.textDark,
                                        ),
                                      ),
                                      Text(
                                        med.posologie,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color:
                                          AppColors.textMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    size: 18,
                                    color: AppColors.textLight,
                                  ),
                                  onPressed: () {
                                    setState(() =>
                                        _medicaments.remove(med));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _ajouterMedicament,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.border,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded,
                                    size: 16,
                                    color: AppColors.primary),
                                SizedBox(width: 6),
                                Text(
                                  'Ajouter un médicament',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
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

                  // Examens prescrits
                  _ConsultCard(
                    icon: Icons.science_outlined,
                    title: 'Examens à prescrire',
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ..._examens.map(
                                (e) => GestureDetector(
                              onTap: () => setState(
                                      () => _examens.remove(e)),
                              child: Container(
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius:
                                  BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      e,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight:
                                        FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.close,
                                        size: 12,
                                        color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _examens
                                  .add('Nouvel examen'));
                            },
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F4),
                                borderRadius:
                                BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add,
                                      size: 12,
                                      color: AppColors.textMedium),
                                  SizedBox(width: 4),
                                  Text(
                                    'Ajouter',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Traçabilité info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary
                              .withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(
                                    text:
                                    'Cette action sera tracée dans '),
                                TextSpan(
                                  text: 'logs_tracabilite',
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w700),
                                ),
                                const TextSpan(
                                    text:
                                    ' — Action : MODIF_DIAGNOSTIC.'),
                              ],
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

          // Boutons
          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
            decoration: const BoxDecoration(
              color: AppColors.backgroundWhite,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _sauvegarder(),
                    child: const Text('Enregistrer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _sauvegarder(cloturer: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text('Clôturer le passage'),
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

class _ConsultCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const _ConsultCard({
    required this.icon,
    required this.title,
    this.subtitle,
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
              if (subtitle != null) ...[
                const SizedBox(width: 6),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ],
          ),
          child,
        ],
      ),
    );
  }
}