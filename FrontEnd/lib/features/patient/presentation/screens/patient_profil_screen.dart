import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/utils.dart';
import '../../data/patient_api_service.dart';
import '../../data/patient_models.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../../../features/auth/presentation/screens/app_entry.dart';
import 'patient_notifications_screen.dart';

class PatientProfilScreen extends StatefulWidget {
  const PatientProfilScreen({super.key});

  @override
  State<PatientProfilScreen> createState() => _PatientProfilScreenState();
}

class _PatientProfilScreenState extends State<PatientProfilScreen> {
  final _service = PatientApiService();
  final _authService = AuthLocalService();
  Patient? _patient;
  bool _loading = true;
  bool _biometrieActive = true;
  String _langue = 'Français';
  String _theme = 'Système';
  String _fallbackName = '';
  String _fallbackId = '';

  bool get _isOffline => AppMode().isOffline;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Charger les données locales en premier (pour fallback)
    final userName = await _authService.getUserName();
    final userId = await _authService.getUserId();
    _biometrieActive = await _authService.isBiometricEnabled();
    _fallbackName = userName ?? 'Patient';
    _fallbackId = userId ?? '';

    // Tenter de charger depuis l'API
    try {
      if (userId != null && userId.isNotEmpty) {
        final patient = await _service.getProfil(userId);
        if (!mounted) { return; }
        setState(() {
          _patient = patient;
          _loading = false;
        });
        return;
      }
    } catch (_) {
      // API échouée — on utilise les données locales
    }

    if (!mounted) { return; }
    setState(() => _loading = false);
  }

  Future<void> _logout() async {
    await _authService.logout();
    AppMode().reset();
    if (!mounted) { return; }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AppEntry()),
          (route) => false,
    );
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
              Text(
                _isOffline
                    ? 'Mode hors-réseau · Accès limité'
                    : 'Compte & sécurité',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),

              if (_isOffline) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFB45309)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          size: 18, color: Color(0xFFB45309)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Paramètres indisponibles hors du réseau '
                              'hospitalier. Seule la déconnexion est active.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB45309),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Carte profil
              Opacity(
                opacity: _isOffline ? 0.5 : 1.0,
                child: _buildProfilCard(),
              ),

              const SizedBox(height: 24),

              // Sécurité
              Opacity(
                opacity: _isOffline ? 0.35 : 1.0,
                child: IgnorePointer(
                  ignoring: _isOffline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sécurité',
                          style: TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
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
                            value: 'Configuré', onTap: () {}),
                        _SettingRow(
                            icon: Icons.key_outlined,
                            label: 'Changer mot de passe',
                            onTap: () {}),
                      ]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Préférences
              Opacity(
                opacity: _isOffline ? 0.35 : 1.0,
                child: IgnorePointer(
                  ignoring: _isOffline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Préférences',
                          style: TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      const SizedBox(height: 12),
                      _buildSettingsCard([
                        _SettingRow(icon: Icons.notifications_outlined,
                            label: 'Notifications', value: '3 actives',
                            onTap: () {}),
                        _SettingRow(icon: Icons.language_outlined,
                            label: 'Langue', value: 'Français',
                            onTap: () {}),
                        _SettingRow(icon: Icons.brightness_6_outlined,
                            label: 'Thème', value: 'Système',
                            onTap: () {}),
                        _SettingRow(icon: Icons.local_hospital_outlined,
                            label: 'Hôpitaux autorisés',
                            value: '3 connectés', onTap: () {}),
                      ]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Données
              Opacity(
                opacity: _isOffline ? 0.35 : 1.0,
                child: IgnorePointer(
                  ignoring: _isOffline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Données & confidentialité',
                          style: TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      const SizedBox(height: 12),
                      _buildSettingsCard([
                        _SettingRow(icon: Icons.history_outlined,
                            label: 'Mes accès récents', onTap: () {}),
                        _SettingRow(icon: Icons.download_outlined,
                            label: 'Exporter mes données', onTap: () {}),
                      ]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // DÉCONNEXION — TOUJOURS ACTIF
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _logout,
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

  Widget _buildProfilCard() {
    // Utiliser les données API si disponibles, sinon fallback local
    final nom = _patient?.nomComplet ?? _fallbackName;
    final tel = _patient?.telephone ?? '';
    final id = _patient?.id ?? _fallbackId;
    final initiales = _patient?.initiales ??
        (nom.isNotEmpty
            ? nom.split(' ').map((w) => w.isNotEmpty ? w[0] : '')
            .take(2).join().toUpperCase()
            : '?');

    return Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                if (tel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tel,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
                if (id.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'ID ${id.length > 18 ? '${id.substring(0, 12)}···${id.substring(id.length - 6)}' : id}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!_isOffline)
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
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textDark)),
            ),
            if (value != null)
              Text(value!,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMedium)),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
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