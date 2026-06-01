import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/infirmier_mock_data.dart';

/// Écran "Passages à constanter" — tableau de bord de l'infirmier (24/41).
class InfirmierPassagesScreen extends StatelessWidget {
  final VoidCallback onOpenConstantes;

  const InfirmierPassagesScreen({super.key, required this.onOpenConstantes});

  @override
  Widget build(BuildContext context) {
    final inf = mockInfirmier;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // En-tête
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service ${inf.service} · ${inf.bloc}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bonjour ${inf.prenom}',
                        style: AppTextStyles.h1,
                      ),
                    ],
                  ),
                ),
                InitialsAvatar(
                  initials: inf.initials,
                  size: 44,
                  background: AppColors.successLight,
                  foreground: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Cartes de stats
            Row(
              children: const [
                Expanded(
                  child: InfStatCardWidget(
                    value: '7',
                    label: 'À CONSTANTER',
                    valueColor: AppColors.textDark,
                    background: AppColors.primaryLight,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: InfStatCardWidget(
                    value: '1',
                    label: 'URGENCE',
                    valueColor: AppColors.error,
                    background: AppColors.errorLight,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: InfStatCardWidget(
                    value: '14',
                    label: 'FAITS',
                    valueColor: AppColors.textMedium,
                    background: AppColors.surfaceLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SectionHeader(
              title: 'Passages à constanter',
              actionLabel: 'Trier',
              onAction: () {},
            ),
            const SizedBox(height: 12),

            for (final p in mockPassages) ...[
              _PassageRow(
                passage: p,
                onTap: onOpenConstantes,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _PassageRow extends StatelessWidget {
  final PassageAConstanter passage;
  final VoidCallback onTap;

  const _PassageRow({required this.passage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          InitialsAvatar(initials: passage.initials, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        passage.nom,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (passage.isUrgence)
                      StatusChip(
                        label: 'Urgence',
                        foreground: AppColors.error,
                        background: AppColors.errorLight,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${passage.service} · ${passage.lit} · admis ${passage.heure}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textLight),
        ],
      ),
    );
  }
}

// Widget proxy pour éviter l'import circulaire avec infirmier_widgets.dart
class InfStatCardWidget extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final Color background;

  const InfStatCardWidget({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: valueColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}