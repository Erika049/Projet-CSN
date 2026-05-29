import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/agent_accueil_mock_data.dart';

/// Écran "Profil" de l'agent d'accueil.
///
/// Non détaillé dans la maquette : version minimale (carte d'identité +
/// déconnexion). À enrichir si besoin (préférences, langue, etc.).
class ProfilAgentScreen extends StatelessWidget {
  const ProfilAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agent = mockAgent;

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
                    initials: agent.initials,
                    size: 52,
                    background: AppColors.primaryLight,
                    foreground: AppColors.primary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agent.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(agent.poste, style: AppTextStyles.bodyMedium),
                        Text(agent.lieu, style: AppTextStyles.bodySmall),
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
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(
                    color: AppColors.errorLight,
                    width: 1.5,
                  ),
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