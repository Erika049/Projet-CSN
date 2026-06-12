import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../../../features/auth/presentation/screens/app_entry.dart';

class AdminProfilScreen extends StatefulWidget {
  const AdminProfilScreen({super.key});

  @override
  State<AdminProfilScreen> createState() =>
      _AdminProfilScreenState();
}

class _AdminProfilScreenState
    extends State<AdminProfilScreen> {
  final _authService = AuthLocalService();
  String _nom = '';

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final nom = await _authService.getUserName();
    if (!mounted) { return; }
    setState(() => _nom = nom ?? 'Administrateur');
  }

  Future<void> _logout() async {
    await _authService.logout();
    AppMode().reset();
    if (!mounted) { return; }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) => const AppEntry()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final initiales = _nom.isNotEmpty
        ? _nom
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase()
        : 'AD';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              20, 20, 20, 32),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
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
                'Compte administrateur',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),

              const SizedBox(height: 20),

              // ── Carte profil ──────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius:
                  BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initiales,
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
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nom,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                                horizontal: 8,
                                vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFFEDE9FE),
                              borderRadius:
                              BorderRadius.circular(
                                  999),
                            ),
                            child: const Text(
                              'Administrateur',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w600,
                                color:
                                Color(0xFF7C3AED),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Informations ──────────────────────
              const Text('Informations',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius:
                  BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    _InfoRow(
                      icon: Icons
                          .admin_panel_settings_outlined,
                      label: 'Rôle',
                      value: 'Administrateur système',
                    ),
                    Divider(
                        height: 1,
                        color: AppColors.border),
                    _InfoRow(
                      icon: Icons.verified_outlined,
                      label: 'Statut',
                      value: 'Actif',
                      valueColor: AppColors.success,
                    ),
                    Divider(
                        height: 1,
                        color: AppColors.border),
                    _InfoRow(
                      icon: Icons.security_outlined,
                      label: 'Niveau d\'accès',
                      value: 'Total',
                      valueColor: Color(0xFF7C3AED),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Déconnexion ───────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(
                        color: AppColors.error),
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
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color?   valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: AppColors.textMedium),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark)),
          ),
          Text(value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ??
                    AppColors.textMedium,
              )),
        ],
      ),
    );
  }
}