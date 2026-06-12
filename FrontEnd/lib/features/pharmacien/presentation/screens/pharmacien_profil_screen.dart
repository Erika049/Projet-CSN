import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../../../features/auth/presentation/screens/splash_screen.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/pharmacien_mock_data.dart';
import '../../data/pharmacien_repository.dart';
import '../widgets/pharmacien_widgets.dart';

/// Écran "Profil" du pharmacien — Tab 4.
class PharmacienProfilScreen extends StatefulWidget {
  const PharmacienProfilScreen({super.key});

  @override
  State<PharmacienProfilScreen> createState() => _PharmacienProfilScreenState();
}

class _PharmacienProfilScreenState extends State<PharmacienProfilScreen> {
  final PharmacienRepository _repository = PharmacienRepository();
  PharmacienProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      // TODO: Remplacer '1' par l'ID réel du personnel connecté
      final data = await _repository.getPersonnelProfil('1');
      if (!mounted) return;
      setState(() {
        _profile = PharmacienProfile.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final pharm = _profile ?? mockPharmacien;

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
                    initials: pharm.initials,
                    size: 52,
                    background: pharmAvatarBg,
                    foreground: pharmAvatarFg,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pharm.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text('Pharmacien',
                            style: AppTextStyles.bodyMedium),
                        Text(pharm.service, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ... (reste de la UI identique)
            const SizedBox(height: 16),

            AppCard(
              child: Column(
                children: [
                  const _InfoRow(
                    icon: Icons.medication_outlined,
                    label: 'Spécialité',
                    value: 'Dispensation & Conseil',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Localisation',
                    value: pharm.service,
                  ),
                  const Divider(height: 24),
                  const _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Matricule',
                    value: 'PH-2024-0047',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await AuthLocalService().logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                },
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLight,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
