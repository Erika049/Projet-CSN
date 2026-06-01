import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/infirmier_mock_data.dart';

/// Écran "Saisie des constantes vitales" (25/41).
///
/// Accessible depuis le dashboard (taper un patient) ou depuis l'onglet
/// Constantes. Les champs sont éditables ; les valeurs mock sont pré-remplies.
class InfirmierSaisieConstantesScreen extends StatefulWidget {
  const InfirmierSaisieConstantesScreen({super.key});

  @override
  State<InfirmierSaisieConstantesScreen> createState() =>
      _InfirmierSaisieConstantesScreenState();
}

class _InfirmierSaisieConstantesScreenState
    extends State<InfirmierSaisieConstantesScreen> {
  final _tensionCtrl = TextEditingController(text: mockConstantes.tension);
  final _tempCtrl = TextEditingController(text: mockConstantes.temperature);
  final _poidsCtrl = TextEditingController(text: mockConstantes.poids);
  final _freqCardCtrl =
      TextEditingController(text: mockConstantes.freqCardiaque);
  final _spo2Ctrl = TextEditingController(text: mockConstantes.spo2);
  final _freqRespiCtrl =
      TextEditingController(text: mockConstantes.freqRespi);
  final _noteCtrl =
      TextEditingController(text: mockConstantes.noteInfirmiere);

  @override
  void dispose() {
    _tensionCtrl.dispose();
    _tempCtrl.dispose();
    _poidsCtrl.dispose();
    _freqCardCtrl.dispose();
    _spo2Ctrl.dispose();
    _freqRespiCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _valider() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Constantes enregistrées avec succès'),
        backgroundColor: AppColors.success,
      ),
    );
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final patient = mockPassages.first;
    final inf = mockInfirmier;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18,
              color: AppColors.textDark),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          'Constantes vitales',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            // Carte patient
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  InitialsAvatar(initials: patient.initials, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.nom,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${patient.service} · ${patient.lit} · Adm. ${patient.heure}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: 'Triage',
                    foreground: AppColors.warning,
                    background: AppColors.warningLight,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Grille 2×3 des constantes vitales
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _VitalInputCard(
                  label: 'TENSION',
                  controller: _tensionCtrl,
                  unit: 'cmHg',
                  valueColor: AppColors.primary,
                  background: AppColors.primaryLight,
                ),
                _VitalInputCard(
                  label: 'TEMPÉRATURE',
                  controller: _tempCtrl,
                  unit: '°C',
                  valueColor: AppColors.warning,
                  background: AppColors.warningLight,
                ),
                _VitalInputCard(
                  label: 'POIDS',
                  controller: _poidsCtrl,
                  unit: 'kg',
                  valueColor: AppColors.textDark,
                  background: AppColors.backgroundWhite,
                ),
                _VitalInputCard(
                  label: 'FRÉQ. CARDIAQUE',
                  controller: _freqCardCtrl,
                  unit: 'bpm',
                  valueColor: AppColors.success,
                  background: AppColors.successLight,
                ),
                _VitalInputCard(
                  label: 'SPO₂',
                  controller: _spo2Ctrl,
                  unit: '%',
                  valueColor: AppColors.success,
                  background: AppColors.successLight,
                ),
                _VitalInputCard(
                  label: 'FRÉQ. RESPI.',
                  controller: _freqRespiCtrl,
                  unit: '/min',
                  valueColor: AppColors.textDark,
                  background: AppColors.backgroundWhite,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Note infirmière
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.notes, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Note infirmière',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMedium,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Signature
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  InitialsAvatar(
                    initials: inf.initials,
                    size: 32,
                    background: AppColors.success,
                    foreground: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Enregistré par ${inf.displayName} · 09:42 · IP locale 192.168.1.42',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.textMedium,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _valider,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Valider les constantes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VitalInputCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;
  final Color valueColor;
  final Color background;

  const _VitalInputCard({
    required this.label,
    required this.controller,
    required this.unit,
    required this.valueColor,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}