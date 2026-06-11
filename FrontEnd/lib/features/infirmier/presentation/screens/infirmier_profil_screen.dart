import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../../../features/auth/presentation/screens/splash_screen.dart';
import '../../data/infirmier_api_service.dart';
import '../../../agent_accueil/data/agent_accueil_api_service.dart';

class InfirmierProfilScreen extends StatefulWidget {
  const InfirmierProfilScreen({super.key});

  @override
  State<InfirmierProfilScreen> createState() => _InfirmierProfilScreenState();
}

class _InfirmierProfilScreenState extends State<InfirmierProfilScreen> {
  final _api   = AgentAccueilApiService();
  final _local = AuthLocalService();

  AgentProfilApi? _profil;
  bool _loading    = true;
  bool _isOffline  = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _isOffline = false; });
    try {
      final id = await _local.getUserId();
      if (id == null) throw Exception('Session expirée');
      final profil = await _api.getProfil(id);
      if (mounted) setState(() { _profil = profil; _loading = false; });
    } catch (_) {
      final localName = await _local.getUserName();
      final localRole = await _local.getRole();
      if (mounted) {
        setState(() {
          _loading   = false;
          _isOffline = true;
          if (localName != null && localName.isNotEmpty) {
            final parts = localName.split(' ');
            _profil = AgentProfilApi(
              idPersonnel:    0,
              nom:            parts.length > 1 ? parts.sublist(1).join(' ') : localName,
              prenom:         parts.isNotEmpty ? parts[0] : '',
              role:           localRole ?? 'infirmier',
              identifiantPro: '',
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: AppColors.roleInfirmier, strokeWidth: 2)),
      );
    }

    final nom       = _profil?.nom        ?? '—';
    final prenom    = _profil?.prenom     ?? '';
    final poste     = _profil?.posteLabel ?? 'Infirmier(e)';
    final lieu      = _profil?.lieuLabel  ?? 'Établissement';
    final initiales = _profil?.initials   ?? '?';
    final hasApi    = (_profil?.idPersonnel ?? 0) != 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profil', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: -0.6)),
              const SizedBox(height: 4),
              Text(_isOffline ? 'Mode hors-ligne · données locales' : 'Compte professionnel',
                  style: const TextStyle(fontSize: 14, color: AppColors.textMedium)),

              if (_isOffline) ...[
                const SizedBox(height: 14),
                _OfflineBanner(),
              ],

              const SizedBox(height: 20),

              // ── Carte identité ───────────────────────────────────────────
              _ProfilCard(initiales: initiales, nom: '$prenom $nom'.trim(), poste: poste, lieu: lieu,
                  identifiant: hasApi ? _profil!.identifiantPro : null),

              if (hasApi && _profil!.nomHopital != null) ...[
                const SizedBox(height: 24),
                const Text('Établissement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 12),
                _SettingsCard(rows: [
                  _SettingRow(icon: Icons.local_hospital_outlined, label: _profil!.nomHopital!, value: _profil!.adresseHopital),
                ]),
              ],

              const SizedBox(height: 24),
              const Text('Sécurité', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 12),
              _SettingsCard(rows: [
                const _SettingRow(icon: Icons.lock_outline,     label: 'Changer le mot de passe', hasArrow: true),
                const _SettingRow(icon: Icons.fingerprint,      label: 'Connexion biométrique',   value: 'Disponible', hasArrow: true),
                const _SettingRow(icon: Icons.history_outlined, label: 'Mes accès récents',        hasArrow: true),
              ]),

              const SizedBox(height: 24),
              const Text('Préférences', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 12),
              _SettingsCard(rows: [
                const _SettingRow(icon: Icons.notifications_outlined, label: 'Notifications', value: 'Activées',  hasArrow: true),
                const _SettingRow(icon: Icons.language_outlined,      label: 'Langue',        value: 'Français',  hasArrow: true),
                const _SettingRow(icon: Icons.brightness_6_outlined,  label: 'Thème',         value: 'Système',   hasArrow: true),
              ]),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton(
                  onPressed: () async {
                    await _local.logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SplashScreen()), (r) => false);
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                  child: const Text('Se déconnecter'),
                ),
              ),

              const SizedBox(height: 16),
              const Center(child: Text('Carnet Santé Numérique · v1.0.0', style: TextStyle(fontSize: 11, color: AppColors.textLight))),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB45309).withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 18, color: Color(0xFFB45309)),
          SizedBox(width: 10),
          Expanded(child: Text('Données réseau indisponibles. Informations depuis le cache local.', style: TextStyle(fontSize: 12, color: Color(0xFFB45309), height: 1.4))),
        ],
      ),
    );
  }
}

class _ProfilCard extends StatelessWidget {
  final String initiales, nom, poste, lieu;
  final String? identifiant;
  const _ProfilCard({required this.initiales, required this.nom, required this.poste, required this.lieu, this.identifiant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: AppColors.roleInfirmier.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Center(child: Text(initiales, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.roleInfirmier))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nom,  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(poste, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
                Text(lieu,  style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                if (identifiant != null && identifiant!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(identifiant!, style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontFamily: 'monospace')),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingRow> rows;
  const _SettingsCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        children: rows.asMap().entries.map((e) => Column(
          children: [
            if (e.key > 0) const Divider(height: 1, color: AppColors.border),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: e.value),
          ],
        )).toList(),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String?  value;
  final bool     hasArrow;
  const _SettingRow({required this.icon, required this.label, this.value, this.hasArrow = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMedium),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textDark))),
          if (value != null) Text(value!, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
          if (hasArrow) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.chevron_right, size: 18, color: AppColors.textLight)),
        ],
      ),
    );
  }
}
