import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/patient_mock_service.dart';
import '../../data/patient_models.dart';

class PatientProfilScreen extends StatefulWidget {
  const PatientProfilScreen({super.key});

  @override
  State<PatientProfilScreen> createState() => _PatientProfilScreenState();
}

class _PatientProfilScreenState extends State<PatientProfilScreen> {
  final _service = PatientMockService();
  Patient? _patient;
  bool _loading = true;
  bool _biometrieActive = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final patient = await _service.getPatient();
    if (!mounted) { return; }
    setState(() {
      _patient = patient;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final patient = _patient!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
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
                'Compte & sécurité',
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          patient.initiales,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${patient.prenom} ${patient.nom}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            patient.telephone,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMedium,
                            ),
                          ),
                          Text(
                            'ID ${patient.id.substring(0, 12)}···${patient.id.substring(patient.id.length - 6)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Modifier',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section Sécurité
              const Text(
                'Sécurité',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _SettingRow(
                  icon: Icons.fingerprint,
                  label: 'Verrouillage biométrique',
                  trailing: Switch(
                    value: _biometrieActive,
                    onChanged: (v) =>
                        setState(() => _biometrieActive = v),
                    activeTrackColor: AppColors.primary,
                  ),
                ),
                _SettingRow(
                  icon: Icons.lock_outline,
                  label: 'Code PIN secours',
                  value: 'Configuré',
                  onTap: () {},
                ),
                _SettingRow(
                  icon: Icons.key_outlined,
                  label: 'Changer mot de passe',
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 24),

              // Section Préférences
              const Text(
                'Préférences',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _SettingRow(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  value: '3 actives',
                  onTap: () {},
                ),
                _SettingRow(
                  icon: Icons.language_outlined,
                  label: 'Langue',
                  value: 'Français',
                  onTap: () {},
                ),
                _SettingRow(
                  icon: Icons.brightness_6_outlined,
                  label: 'Thème',
                  value: 'Système',
                  onTap: () {},
                ),
                _SettingRow(
                  icon: Icons.local_hospital_outlined,
                  label: 'Hôpitaux autorisés',
                  value: '3 connectés',
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 24),

              // Section Données
              const Text(
                'Données & confidentialité',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _SettingRow(
                  icon: Icons.history_outlined,
                  label: 'Mes accès récents',
                  onTap: () {},
                ),
                _SettingRow(
                  icon: Icons.download_outlined,
                  label: 'Exporter mes données',
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 24),

              // Déconnexion
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text('Se déconnecter'),
                ),
              ),

              const SizedBox(height: 16),

              // Version
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

  Widget _buildSettingsCard(List<_SettingRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final i = entry.key;
          final row = entry.value;
          return Column(
            children: [
              if (i > 0)
                const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: row,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textLight,
                ),
              ),
          ],
        ),
      ),
    );
  }
}