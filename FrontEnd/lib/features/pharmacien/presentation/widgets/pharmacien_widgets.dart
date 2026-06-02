import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../data/pharmacien_mock_data.dart';

// Couleur d'avatar du pharmacien (ambre, cohérent avec la maquette FA)
const pharmAvatarBg = Color(0xFFFEF3C7);
const pharmAvatarFg = Color(0xFFD97706);

/// Carte statistique pharmacien (même pattern que les autres rôles).
class PharmStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final Color background;

  const PharmStatCard({
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

/// Retourne (icon, fg, bg, badge) pour chaque type d'activité pharmacien.
({IconData icon, Color fg, Color bg, String badge}) pharmActivityVisual(
    PharmacienActivityKind kind) {
  switch (kind) {
    case PharmacienActivityKind.delivrance:
      return (
        icon: Icons.medication_outlined,
        fg: AppColors.primary,
        bg: AppColors.primaryLight,
        badge: 'Délivrance',
      );
    case PharmacienActivityKind.refus:
      return (
        icon: Icons.cancel_outlined,
        fg: AppColors.error,
        bg: AppColors.errorLight,
        badge: 'Refus',
      );
  }
}
