import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/infirmier_mock_data.dart';

/// Écran Profil de l'infirmier (minimal — non détaillé dans la maquette).
class InfirmierProfilScreen extends StatelessWidget {
  const InfirmierProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inf = mockInfirmier;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            const Text('Profil', style: AppTextStyles.h1),
            const SizedBox(height: 4),
            const Text('Compte professionnel', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 20),

            AppCard(
              child: Row(
                children: [
                  InitialsAvatar(
                    initials: inf.initials,
                    size: 52,
                    background: const Color(0xFFFFF7ED),
                    foreground: AppColors.roleInfirmier,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inf.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text('Infirmière',
                            style: AppTextStyles.bodyMedium),
                        Text(inf.lieu, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.errorLight, width: 1.5),
                ),
                child: const Text('Se déconnecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}