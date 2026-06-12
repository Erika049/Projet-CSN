import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/pharmacien_mock_data.dart';
import '../../data/pharmacien_repository.dart';
import 'pharmacien_delivrance_validee_screen.dart';

/// Page 41 — Détail ordonnance pharmacien.
class PharmacienDetailOrdonnanceScreen extends StatefulWidget {
  final OrdonnanceItem item;

  const PharmacienDetailOrdonnanceScreen({super.key, required this.item});

  @override
  State<PharmacienDetailOrdonnanceScreen> createState() => _PharmacienDetailOrdonnanceScreenState();
}

class _PharmacienDetailOrdonnanceScreenState extends State<PharmacienDetailOrdonnanceScreen> {
  final PharmacienRepository _repository = PharmacienRepository();
  bool _isLoading = false;

  Future<void> _handleAction(bool isDelivery) async {
    setState(() => _isLoading = true);
    try {
      if (isDelivery) {
        await _repository.delivrerOrdonnance(widget.item.ordonnanceId);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PharmacienDelivranceValideeScreen(item: widget.item),
          ),
        );
      } else {
        await _repository.refuserOrdonnance(widget.item.ordonnanceId);
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ordonnance refusée')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          icon: const Icon(Icons.arrow_back_ios,
              size: 18, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ordonnance #${widget.item.ordonnanceId}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            // Carte patient
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  InitialsAvatar(initials: widget.item.initials, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.patient,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (widget.item.allergies.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodySmall,
                              children: [
                                const TextSpan(text: 'Allergies : '),
                                TextSpan(
                                  text: widget.item.allergies,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Identifié',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Carte prescripteur
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: AppColors.textLight),
                      const SizedBox(width: 8),
                      Text(
                        'Prescripteur',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      InitialsAvatar(
                        initials: widget.item.medecinInitials,
                        size: 36,
                        background: AppColors.successLight,
                        foreground: AppColors.success,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.medecinNom,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              widget.item.medecinService,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.item.dateOrdonnance,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textMedium),
                      children: [
                        const TextSpan(
                          text: 'Diagnostic : ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        TextSpan(text: widget.item.diagnosticComplet),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Carte médicaments
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medication_outlined,
                          size: 16, color: AppColors.textLight),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'À délivrer',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              '${widget.item.nbMedicaments} médicament${widget.item.nbMedicaments > 1 ? 's' : ''}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (int i = 0; i < widget.item.medicaments.length; i++) ...[
                    if (i > 0) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                    ],
                    _MedicamentRow(med: widget.item.medicaments[i]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notice traçabilité
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.radio_button_unchecked,
                    size: 14, color: AppColors.textLight),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textLight, height: 1.5),
                      children: const [
                        TextSpan(
                            text: 'Cette délivrance sera tracée — Action '),
                        TextSpan(
                          text: 'DELIVRANCE_MEDICAMENT',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMedium,
                          ),
                        ),
                        TextSpan(
                            text:
                                ' avec ID prescripteur, ID patient, horodatage et IP.'),
                      ],
                    ),
                  ),
                ),
              ],
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
                  onPressed: () => _handleAction(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.textMedium,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Refuser'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _handleAction(true),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Valider la délivrance'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ligne médicament
// ---------------------------------------------------------------------------

class _MedicamentRow extends StatelessWidget {
  final MedicamentItem med;

  const _MedicamentRow({required this.med});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                med.nom,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  med.quantite,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                if (med.stockOk)
                  Text(
                    '• Stock OK',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.success),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(med.posologie, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
