import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

enum RolePro {
  medecin(
    label: 'Medecin',
    subtitle: 'Diagnostic & ordonnance',
    icon: Icons.medical_services_outlined,
    color: AppColors.roleMedecin,
    bgColor: Color(0xFFDCFCE7),
  ),
  infirmier(
    label: 'Infirmier(ere)',
    subtitle: 'Constantes vitales',
    icon: Icons.monitor_heart_outlined,
    color: AppColors.primary,
    bgColor: AppColors.primaryLight,
  ),
  accueil(
    label: "Agent d'accueil",
    subtitle: 'Admission & scan QR',
    icon: Icons.crop_free,
    color: Color(0xFF7C3AED),
    bgColor: Color(0xFFEDE9FE),
  ),
  laborantin(
    label: 'Laborantin',
    subtitle: 'Publication des examens',
    icon: Icons.science_outlined,
    color: AppColors.roleLaborantin,
    bgColor: Color(0xFFFEF3C7),
  ),
  pharmacien(
    label: 'Pharmacien',
    subtitle: 'Delivrance medicaments',
    icon: Icons.medication_outlined,
    color: AppColors.rolePharmacien,
    bgColor: Color(0xFFFEE2E2),
  );

  const RolePro({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
}
