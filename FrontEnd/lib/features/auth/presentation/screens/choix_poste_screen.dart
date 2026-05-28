import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/models/role_pro.dart';

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
        title: const Text('Personnel medical'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quel est votre poste ?', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            const Text(
              "Votre role conditionne l'acces a certaines fonctions du dossier patient.",
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),

            ...RolePro.values.map((role) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PosteCard(role: role),
            )),

            const SizedBox(height: 12),

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
                      "Les comptes professionnels sont crees par l'administrateur systeme. Si votre poste n'apparait pas, contactez votre service informatique.",
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
  final RolePro role;

  const _PosteCard({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: role.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(role.icon, color: role.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role.label, style: AppTextStyles.h4),
                const SizedBox(height: 2),
                Text(role.subtitle, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
