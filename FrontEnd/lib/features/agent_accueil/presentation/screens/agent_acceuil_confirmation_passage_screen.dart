import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/agent_accueil_mock_data.dart';
import '../../data/agent_accueil_service.dart';
import '../widgets/agent_accueil_widgets.dart';

/// Écran "Confirmation & création passage" (AGENT 16/41).
///
/// Affiché après un scan QR réussi. Le patient est identifié via
/// [AgentAccueilService.identifyPatient], puis l'agent ouvre un passage via
/// [AgentAccueilService.createPassage].
class ConfirmationPassageScreen extends StatefulWidget {
  /// Jeton issu du QR scanné (mock par défaut tant que la caméra n'est pas
  /// branchée).
  final String qrToken;

  const ConfirmationPassageScreen({super.key, this.qrToken = 'MOCK-QR'});

  @override
  State<ConfirmationPassageScreen> createState() =>
      _ConfirmationPassageScreenState();
}

class _ConfirmationPassageScreenState extends State<ConfirmationPassageScreen> {
  static const _motif = 'Consultation Cardiologie';
  static const _service = 'Cardiologie — Bloc B';
  static const _medecin = 'Dr. Mballa Alphonse';

  final AgentAccueilService _api = AgentAccueilService.create();

  IdentifiedPatient? _patient;
  bool _loading = true;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _identify();
  }

  Future<void> _identify() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final patient = await _api.identifyPatient(widget.qrToken);
      if (!mounted) return;
      setState(() {
        _patient = patient;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _validerAdmission() async {
    final patient = _patient;
    if (patient == null) return;
    setState(() => _submitting = true);
    try {
      await _api.createPassage(
        patientId: patient.id,
        motif: _motif,
        service: _service,
        medecin: _medecin,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admission validée')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Confirmation admission'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null || _patient == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Patient introuvable',
                  style: AppTextStyles.h4, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _identify,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _PatientIdentifieCard(patient: _patient!),
        const SizedBox(height: 16),
        const _NouveauPassageCard(),
        const SizedBox(height: 24),
        _BottomActions(
          submitting: _submitting,
          onCancel: () => Navigator.pop(context),
          onValidate: _validerAdmission,
        ),
      ],
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
  const _NouveauPassageCard();

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
          const _TraceInfo(),
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
  const _TraceInfo();

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
  final bool submitting;
  final VoidCallback onCancel;
  final VoidCallback onValidate;

  const _BottomActions({
    required this.submitting,
    required this.onCancel,
    required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: submitting ? null : onCancel,
            child: const Text('Annuler'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: submitting ? null : onValidate,
            icon: submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check, size: 18),
            label: const Text("Valider l'admission"),
          ),
        ),
      ],
    );
  }
}
