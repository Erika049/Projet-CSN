import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../data/pharmacien_mock_data.dart';

/// Page 42 — Délivrance validée (écran de confirmation).
class PharmacienDelivranceValideeScreen extends StatelessWidget {
  final OrdonnanceItem item;

  const PharmacienDelivranceValideeScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    const pharm = mockPharmacien;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Bouton fermer
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 20, 0),
                child: TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMedium,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                  ),
                  child: const Text(
                    'Fermer ×',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Icône succès
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Délivrance validée',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMedium,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: "L'ordonnance de "),
                          TextSpan(
                            text: item.patient
                                .split(' ')
                                .reversed
                                .join(' '), // "Jean TCHAMENI" → prénom + nom
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const TextSpan(
                            text:
                                ' a été dispensée et journalisée au dossier patient.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Reçu
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REÇU',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _ReceiptRow(
                            label: 'N° dispensation',
                            value: 'DSP-2026-09421',
                            valueBold: true,
                          ),
                          const SizedBox(height: 8),
                          for (final med in item.medicaments) ...[
                            _ReceiptRow(
                              label: med.nom,
                              value: med.quantite,
                              valueBold: true,
                            ),
                            const SizedBox(height: 8),
                          ],
                          const Divider(height: 16),
                          const _ReceiptRow(
                            label: 'Horodatage',
                            value: '24 Mai 2026 · 14:08',
                            valueBold: true,
                          ),
                          const SizedBox(height: 8),
                          _ReceiptRow(
                            label: 'Pharmacien',
                            value: pharm.shortName,
                            valueBold: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
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
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.textMedium,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Imprimer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Retour file d'attente"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueBold;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w400,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
