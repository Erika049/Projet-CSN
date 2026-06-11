import 'package:flutter/material.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/biometric_helper.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../../../features/auth/presentation/screens/splash_screen.dart';
import '../../data/agent_accueil_api_service.dart';

class ProfilAgentScreen extends StatefulWidget {
  const ProfilAgentScreen({super.key});

  @override
  State<ProfilAgentScreen> createState() => _ProfilAgentScreenState();
}

class _ProfilAgentScreenState extends State<ProfilAgentScreen> {
  final _api   = AgentAccueilApiService();
  final _local = AuthLocalService();

  AgentProfilApi? _profil;
  bool _loading          = true;
  bool _isOffline        = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([_loadProfil(), _loadBiometric()]);
  }

  Future<void> _loadProfil() async {
    setState(() { _loading = true; _isOffline = false; });
    try {
      final id = await _local.getUserId();
      if (id == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final profil = await _api.getProfil(id);
      if (mounted) setState(() { _profil = profil; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() {
        _loading   = false;
        _isOffline = (e.statusCode == 0);
      });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _isOffline = _profil == null; });
    }
  }

  Future<void> _loadBiometric() async {
    final available = await BiometricHelper.isAvailable();
    final enabled   = await _local.isBiometricEnabled();
    if (mounted) setState(() {
      _biometricAvailable = available;
      _biometricEnabled   = enabled;
    });
  }

  Future<void> _toggleBiometric() async {
    if (_biometricEnabled) {
      // Désactiver
      await _local.disableBiometric();
      if (mounted) setState(() => _biometricEnabled = false);
      _showSnack('Connexion biométrique désactivée.', AppColors.textDark);
    } else {
      // Activer → demander confirmation biométrique
      if (!_biometricAvailable) {
        _showSnack('Biométrie non disponible sur cet appareil.', AppColors.warning);
        return;
      }
      final ok = await BiometricHelper.authenticate(
        reason: 'Confirmez votre identité pour activer la connexion biométrique',
      );
      if (!ok) {
        _showSnack('Authentification annulée.', AppColors.error);
        return;
      }
      await _local.enableBiometric();
      if (mounted) setState(() => _biometricEnabled = true);
      _showSnack('Connexion biométrique activée.', AppColors.success);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  void _confirmerDeconnexion() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 28),
            ),
            const SizedBox(height: 16),
            const Text('Se déconnecter ?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text(
              'Votre session sera fermée. Vos données locales seront effacées.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _local.logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Annuler', style: TextStyle(color: AppColors.textMedium)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
      );
    }

    final prenom    = _profil?.prenom     ?? '';
    final nom       = _profil?.nom        ?? '—';
    final poste     = _profil?.posteLabel ?? 'Personnel médical';
    final lieu      = _profil?.lieuLabel  ?? 'Établissement';
    final initiales = _profil?.initials   ?? '?';
    final identifiant = _profil?.identifiantPro ?? '';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfil,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [

              // ── Titre ────────────────────────────────────────────────────
              const Text('Profil', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: -0.6)),
              const SizedBox(height: 4),
              Text(
                _isOffline ? 'Hors ligne · dernières données' : 'Compte professionnel',
                style: const TextStyle(fontSize: 14, color: AppColors.textMedium),
              ),

              // ── Bannière offline ─────────────────────────────────────────
              if (_isOffline) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 15, color: AppColors.warning),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Données hors ligne — rafraîchissez dès que possible.', style: TextStyle(fontSize: 12, color: AppColors.warning))),
                      GestureDetector(onTap: _loadProfil, child: const Icon(Icons.refresh, size: 16, color: AppColors.warning)),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Carte identité ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: Center(
                        child: Text(initiales, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$prenom $nom'.trim(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(poste, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
                          Text(lieu,  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65))),
                          if (identifiant.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                identifiant,
                                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.9), fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Établissement ────────────────────────────────────────────
              if (_profil?.nomHopital != null) ...[
                const SizedBox(height: 24),
                _SectionTitle('Établissement'),
                const SizedBox(height: 10),
                _InfoCard(rows: [
                  _InfoRow(icon: Icons.local_hospital_outlined, label: _profil!.nomHopital!),
                  if (_profil!.adresseHopital != null)
                    _InfoRow(icon: Icons.location_on_outlined, label: _profil!.adresseHopital!),
                ]),
              ],

              const SizedBox(height: 24),

              // ── Sécurité ─────────────────────────────────────────────────
              _SectionTitle('Sécurité'),
              const SizedBox(height: 10),
              _ActionCard(rows: [
                _ActionRow(
                  icon: Icons.fingerprint,
                  label: 'Connexion biométrique',
                  trailing: Switch(
                    value: _biometricEnabled,
                    onChanged: _biometricAvailable ? (_) => _toggleBiometric() : null,
                    activeColor: AppColors.primary,
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              // ── Session ──────────────────────────────────────────────────
              _SectionTitle('Session'),
              const SizedBox(height: 10),
              _InfoCard(rows: [
                _InfoRow(icon: Icons.badge_outlined,        label: 'Rôle',       value: poste),
                _InfoRow(icon: Icons.business_outlined,     label: 'Hôpital',    value: _profil?.nomHopital ?? '—'),
                _InfoRow(icon: Icons.verified_user_outlined, label: 'Compte',    value: 'Actif'),
              ]),

              const SizedBox(height: 32),

              // ── Déconnexion ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton.icon(
                  onPressed: _confirmerDeconnexion,
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Se déconnecter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Center(
                child: Text('Carnet Santé Numérique · v1.0.0', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets helpers ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
  );
}

class _InfoRow {
  final IconData icon;
  final String   label;
  final String?  value;
  const _InfoRow({required this.icon, required this.label, this.value});
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          return Column(
            children: [
              if (e.key > 0) const Divider(height: 1, indent: 48, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(e.value.icon, size: 18, color: AppColors.textMedium),
                    const SizedBox(width: 14),
                    Expanded(child: Text(e.value.label, style: const TextStyle(fontSize: 14, color: AppColors.textDark))),
                    if (e.value.value != null)
                      Text(e.value.value!, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ActionRow {
  final IconData icon;
  final String   label;
  final Widget?  trailing;
  final VoidCallback? onTap;
  const _ActionRow({required this.icon, required this.label, this.trailing, this.onTap});
}

class _ActionCard extends StatelessWidget {
  final List<_ActionRow> rows;
  const _ActionCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          return Column(
            children: [
              if (e.key > 0) const Divider(height: 1, indent: 48, color: AppColors.border),
              GestureDetector(
                onTap: e.value.onTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Icon(e.value.icon, size: 18, color: AppColors.textMedium),
                      const SizedBox(width: 14),
                      Expanded(child: Text(e.value.label, style: const TextStyle(fontSize: 14, color: AppColors.textDark))),
                      if (e.value.trailing != null) e.value.trailing!,
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
