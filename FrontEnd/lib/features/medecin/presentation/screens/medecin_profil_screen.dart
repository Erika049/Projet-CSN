import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../../../features/auth/presentation/screens/app_entry.dart';

class MedecinProfilScreen extends StatelessWidget {
  const MedecinProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Dr. Alphonse Mballa · Cardiologue',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),

              const SizedBox(height: 20),

              // Carte profil
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color:
                        AppColors.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'AM',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. Alphonse Mballa',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Médecin · Cardiologie',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMedium,
                            ),
                          ),
                          Text(
                            'Hôpital Général · dr_mballa',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Mon établissement',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildCard([
                _Row(
                  icon: Icons.local_hospital_outlined,
                  label: 'Hôpital principal',
                  value: 'Hôpital Général',
                ),
                _Row(
                  icon: Icons.medical_services_outlined,
                  label: 'Service',
                  value: 'Cardiologie',
                ),
                _Row(
                  icon: Icons.badge_outlined,
                  label: 'Matricule',
                  value: 'MED-HG-0042',
                ),
              ]),

              const SizedBox(height: 24),

              const Text(
                'Accès & sécurité',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildCard([
                _Row(
                  icon: Icons.fingerprint,
                  label: 'Biométrie',
                  value: 'Active',
                  onTap: () {},
                ),
                _Row(
                  icon: Icons.key_outlined,
                  label: 'Changer mot de passe',
                  onTap: () {},
                ),
                _Row(
                  icon: Icons.history_outlined,
                  label: 'Mon journal d\'activité',
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () async {
                    final auth = AuthLocalService();
                    await auth.logout();
                    AppMode().reset();
                    if (!context.mounted) { return; }
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AppEntry()),
                          (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text('Se déconnecter'),
                ),
              ),

              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Carnet Santé Numérique · v1.0.0',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<_Row> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return Column(
            children: [
              if (i > 0)
                const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                child: row,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  const _Row({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textMedium),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium,
                ),
              ),
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textLight),
              ),
          ],
        ),
      ),
    );
  }
}