import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/agent_accueil_mock_data.dart';
import '../widgets/agent_accueil_widgets.dart';

/// Écran "Confirmation & création passage" (AGENT 16/41).
///
/// Affiché après un scan QR réussi. Présente le patient identifié dans une
/// carte verte puis le formulaire de création d'un nouveau passage.
class ConfirmationPassageScreen extends StatelessWidget {
  const ConfirmationPassageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = mockIdentifiedPatient;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Confirmation admission'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _PatientIdentifieCard(patient: patient),
          const SizedBox(height: 16),
          _NouveauPassageCard(),
          const SizedBox(height: 24),
          _BottomActions(),
        ],
      ),
    );
  }
}

class _PatientIdentifieCard extends StatelessWidget {
  final IdentifiedPatient patient;
  const _PatientIdentifieCard({required this.patient});

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
          const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 16),
              SizedBox(width: 6),
              Text(
                'PATIENT IDENTIFIÉ · CARTE VALIDE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              InitialsAvatar(initials: patient.initials, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.nom,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(patient.idShort, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StatusChip(
                          label:
                          'Né ${patient.dateNaissance} · ${patient.age}',
                          foreground: AppColors.primary,
                          background: AppColors.primaryLight,
                        ),
                        StatusChip(
                          label: 'Groupe ${patient.groupe}',
                          foreground: AppColors.error,
                          background: AppColors.errorLight,
                        ),
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
              Expanded(
                child: _MetaField(label: 'TÉLÉPHONE', value: patient.telephone),
              ),
              Expanded(
                child: _MetaField(
                  label: 'DERNIER PASSAGE',
                  value: patient.dernierPassage,
                ),
              ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _NouveauPassageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ouvrir un nouveau passage',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "Hôpital Général · Aujourd'hui, 09:30",
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          const _FieldLabel('MOTIF DE VISITE'),
          const SizedBox(height: 6),
          const FakeDropdown(value: 'Consultation Cardiologie'),
          const SizedBox(height: 14),
          const _FieldLabel('SERVICE / UNITÉ'),
          const SizedBox(height: 6),
          const FakeDropdown(value: 'Cardiologie — Bloc B'),
          const SizedBox(height: 14),
          const _FieldLabel('MÉDECIN ASSIGNÉ'),
          const SizedBox(height: 6),
          const FakeDropdown(value: 'Dr. Mballa Alphonse'),
          const SizedBox(height: 14),
          _TraceInfo(),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _TraceInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDark,
                  height: 1.5,
                ),
                children: const [
                  TextSpan(text: 'Cette action sera tracée dans '),
                  TextSpan(
                    text: 'logs_tracabilite',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(text: ' — Action : '),
                  TextSpan(
                    text: 'CREER_PASSAGE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Admission validée')),
              );
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text("Valider l'admission"),
          ),
        ),
      ],
    );
  }
}