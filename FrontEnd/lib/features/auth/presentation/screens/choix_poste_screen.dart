import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/models/role_pro.dart';
import 'login_pro_screen.dart';

class ChoixPosteScreen extends StatelessWidget {
  const ChoixPosteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Personnel médical'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quel est votre poste ?', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            const Text(
              "Votre rôle conditionne l'accès à certaines fonctions du dossier patient.",
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),

            _PosteCard(
              icon: Icons.medical_services_outlined,
              iconColor: AppColors.roleMedecin,
              iconBg: const Color(0xFFDCFCE7),
              title: 'Médecin',
              subtitle: 'Diagnostic & ordonnance',
              role: RolePro.medecin,
            ),
            const SizedBox(height: 12),
            _PosteCard(
              icon: Icons.monitor_heart_outlined,
              iconColor: AppColors.primary,
              iconBg: AppColors.primaryLight,
              title: 'Infirmier(ère)',
              subtitle: 'Constantes vitales',
              role: RolePro.infirmier,
            ),
            const SizedBox(height: 12),
            _PosteCard(
              icon: Icons.crop_free,
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFEDE9FE),
              title: "Agent d'accueil",
              subtitle: 'Admission & scan QR',
              role: RolePro.accueil,
            ),
            const SizedBox(height: 12),
            _PosteCard(
              icon: Icons.science_outlined,
              iconColor: AppColors.roleLaborantin,
              iconBg: const Color(0xFFFEF3C7),
              title: 'Laborantin',
              subtitle: 'Publication des examens',
              role: RolePro.laborantin,
            ),
            const SizedBox(height: 12),
            _PosteCard(
              icon: Icons.medication_outlined,
              iconColor: AppColors.rolePharmacien,
              iconBg: const Color(0xFFFEE2E2),
              title: 'Pharmacien',
              subtitle: 'Délivrance médicaments',
              role: RolePro.pharmacien,
            ),

            const SizedBox(height: 24),

            // Note information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Les comptes professionnels sont créés par l'administrateur système. Si votre poste n'apparaît pas, contactez votre service informatique.",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMedium,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosteCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final RolePro role;

  const _PosteCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigation vers le parcours du rôle choisi.
        // TODO: insérer le login biométrique en amont quand il sera prêt.
        if (role == RolePro.accueil) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginProScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h4),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}