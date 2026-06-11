import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/agent_accueil_api_service.dart';
import '../widgets/agent_accueil_widgets.dart';

class ConfirmationPassageScreen extends StatefulWidget {
  final PatientScanApi patient;
  final int            idHopital;

  const ConfirmationPassageScreen({
    super.key,
    required this.patient,
    required this.idHopital,
  });

  @override
  State<ConfirmationPassageScreen> createState() =>
      _ConfirmationPassageScreenState();
}

class _ConfirmationPassageScreenState
    extends State<ConfirmationPassageScreen> {

  static const _motifs = [
    'Consultation générale',
    'Consultation cardiologie',
    'Consultation diabétologie',
    'Consultation pédiatrie',
    'Consultation gynécologie',
    'Urgence trauma',
    'Urgence cardiaque',
    'Urgence respiratoire',
    'Suivi post-opératoire',
    'Bilan de santé',
    'Vaccination',
    'Autre',
  ];

  final _serviceController = TextEditingController();
  final _medecinController  = TextEditingController();
  final _api = AgentAccueilApiService();

  String _motifSelectionne = 'Consultation générale';
  bool   _loading = false;

  @override
  void dispose() {
    _serviceController.dispose();
    _medecinController.dispose();
    super.dispose();
  }

  String get _motifFinal {
    final parts = [_motifSelectionne];
    if (_serviceController.text.trim().isNotEmpty) parts.add(_serviceController.text.trim());
    if (_medecinController.text.trim().isNotEmpty)  parts.add(_medecinController.text.trim());
    return parts.join(' · ');
  }

  Future<void> _valider() async {
    setState(() => _loading = true);
    try {
      await _api.creerPassage(
        idPatient:   widget.patient.idPatient,
        idHopital:   widget.idHopital,
        motifVisite: _motifFinal,
      );
      if (!mounted) return;
      // Retourner true pour signaler au scanner que l'admission est validée
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admission enregistrée avec succès.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confirmation admission',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _PatientCard(patient: widget.patient),
          const SizedBox(height: 16),
          _PassageForm(
            motifSelectionne:  _motifSelectionne,
            motifs:            _motifs,
            serviceController: _serviceController,
            medecinController: _medecinController,
            onMotifChanged:    (v) => setState(() => _motifSelectionne = v),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Annuler', style: TextStyle(color: AppColors.textMedium)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _valider,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                      label: Text(
                        _loading ? 'Enregistrement…' : "Valider l'admission",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Carte patient identifié
// ════════════════════════════════════════════════════════════════════════════
class _PatientCard extends StatelessWidget {
  final PatientScanApi patient;
  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border.all(color: AppColors.success, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge vert
          const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 15),
              SizedBox(width: 6),
              Text(
                'PATIENT IDENTIFIÉ · CARTE VALIDE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success, letterSpacing: 0.6),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Avatar + nom + ID + chips
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialsAvatar(initials: patient.initials, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.nomComplet,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      patient.idPatient.length > 8
                          ? '${patient.idPatient.substring(0, 8)}···'
                          : patient.idPatient,
                      style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: [
                        StatusChip(label: 'Né ${patient.dateNaissance}', foreground: AppColors.primary, background: AppColors.primaryLight),
                        StatusChip(label: 'Groupe ${patient.groupeSanguin}', foreground: AppColors.error, background: AppColors.errorLight),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          Row(
            children: [
              Expanded(child: _MetaField(label: 'TÉLÉPHONE', value: patient.telephone)),
              Expanded(child: _MetaField(
                label: 'DERNIER PASSAGE',
                value: patient.dernierPassageDate ?? 'Aucun',
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaField extends StatelessWidget {
  final String label;
  final String value;
  const _MetaField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 0.6)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Formulaire passage
// ════════════════════════════════════════════════════════════════════════════
class _PassageForm extends StatelessWidget {
  final String                motifSelectionne;
  final List<String>          motifs;
  final TextEditingController serviceController;
  final TextEditingController medecinController;
  final ValueChanged<String>  onMotifChanged;

  const _PassageForm({
    required this.motifSelectionne,
    required this.motifs,
    required this.serviceController,
    required this.medecinController,
    required this.onMotifChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now  = DateTime.now();
    final date = DateFormat("d MMMM yyyy, HH'h'mm", 'fr_FR').format(now);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ouvrir un nouveau passage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text('Hôpital Général · $date',
              style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
          const SizedBox(height: 18),

          // MOTIF DE VISITE
          _FieldLabel('MOTIF DE VISITE'),
          const SizedBox(height: 6),
          _Dropdown(
            value: motifSelectionne,
            items: motifs,
            onChanged: onMotifChanged,
          ),
          const SizedBox(height: 14),

          // SERVICE / UNITÉ
          _FieldLabel('SERVICE / UNITÉ'),
          const SizedBox(height: 6),
          _TextField(controller: serviceController, hint: 'ex : Cardiologie — Bloc B'),
          const SizedBox(height: 14),

          // MÉDECIN ASSIGNÉ
          _FieldLabel('MÉDECIN ASSIGNÉ'),
          const SizedBox(height: 6),
          _TextField(controller: medecinController, hint: 'ex : Dr. Dupont'),
          const SizedBox(height: 16),

          // Note audit
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, size: 15, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDark, height: 1.5),
                      children: const [
                        TextSpan(text: 'Cette action sera tracée dans '),
                        TextSpan(text: 'logs_tracabilite', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600, color: AppColors.primary)),
                        TextSpan(text: ' — Action : '),
                        TextSpan(text: 'CREER_PASSAGE', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600, color: AppColors.primary)),
                        TextSpan(text: '.'),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 0.6),
      );
}

class _Dropdown extends StatelessWidget {
  final String             value;
  final List<String>       items;
  final ValueChanged<String> onChanged;
  const _Dropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark),
          items: items.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String                hint;
  const _TextField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        filled: true,
        fillColor: AppColors.backgroundWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}
