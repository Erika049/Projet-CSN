import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../data/agent_accueil_mock_data.dart';

/// Carte statistique colorée (utilisée sur Dashboard et Mon activité).
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final Color background;

  const StatCard({
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

/// Champ "dropdown" stylisé (visuel uniquement pour l'instant, n'ouvre pas de
/// menu — branchement de vraies options à venir).
class FakeDropdown extends StatelessWidget {
  final String value;

  const FakeDropdown({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
        ],
      ),
    );
  }
}

/// Couleurs / icône / libellé du badge associés à un type d'activité.
({IconData icon, Color fg, Color bg, String badge}) activityVisual(
    ActivityKind kind) {
  switch (kind) {
    case ActivityKind.scan:
      return (
      icon: Icons.qr_code_scanner,
      fg: AppColors.success,
      bg: AppColors.successLight,
      badge: 'Scan',
      );
    case ActivityKind.creation:
      return (
      icon: Icons.add,
      fg: AppColors.primary,
      bg: AppColors.primaryLight,
      badge: 'Création',
      );
    case ActivityKind.urgence:
      return (
      icon: Icons.flash_on,
      fg: AppColors.error,
      bg: AppColors.errorLight,
      badge: 'Urgence',
      );
  }
}