import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../data/infirmier_mock_data.dart';

// Teinte ambrée propre au rôle infirmier
const _infirmierColor = AppColors.roleInfirmier; // 0xFF92400E
const _infirmierLight = Color(0xFFFFF7ED);

/// Carte statistique pour le dashboard infirmier.
class InfStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final Color background;

  const InfStatCard({
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

/// Retourne (icon, fg, bg, badge) pour chaque type d'activité infirmier.
({IconData icon, Color fg, Color bg, String badge}) infActivityVisual(
    InfirmierActivityKind kind) {
  switch (kind) {
    case InfirmierActivityKind.constantes:
      return (
        icon: Icons.monitor_heart_outlined,
        fg: _infirmierColor,
        bg: _infirmierLight,
        badge: 'Constantes',
      );
    case InfirmierActivityKind.urgence:
      return (
        icon: Icons.monitor_heart_outlined,
        fg: AppColors.error,
        bg: AppColors.errorLight,
        badge: 'Constantes',
      );
    case InfirmierActivityKind.soin:
      return (
        icon: Icons.healing_outlined,
        fg: AppColors.success,
        bg: AppColors.successLight,
        badge: 'Soin',
      );
    case InfirmierActivityKind.injection:
      return (
        icon: Icons.vaccines_outlined,
        fg: AppColors.primary,
        bg: AppColors.primaryLight,
        badge: 'Injection',
      );
  }
}