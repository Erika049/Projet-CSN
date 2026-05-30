import 'package:flutter/material.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/auth_local_service.dart';
import 'loader_screen.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import '../../../patient/presentation/screens/patient_shell.dart';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  // ════════════════════════════════════════════
  // Vérification réseau hospitalier au démarrage.
  // Mettre à `true` pour réactiver le blocage réseau.
  // (Le code de vérification est conservé, juste désactivé.)
  // ════════════════════════════════════════════
  static const bool _networkCheckEnabled = false;

  final AuthLocalService _authService = AuthLocalService();
  _AppEntryStep _step = _AppEntryStep.loading;
  NetworkStatus _networkStatus = NetworkStatus.unreachable;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _step = _AppEntryStep.loading);

    // Vérification réseau désactivée → flux normal direct
    if (!_networkCheckEnabled) {
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted) { return; }
      AppMode().setOnline();
      await _navigateBySession();
      return;
    }

    // 1) Vérification réseau + délai minimum loader
    late NetworkStatus networkStatus;
    try {
      final results = await Future.wait([
        NetworkChecker.checkHospitalNetwork(),
        Future.delayed(const Duration(milliseconds: 2200)),
      ]);
      networkStatus = results[0] as NetworkStatus;
    } catch (_) {
      networkStatus = NetworkStatus.unreachable;
    }

    if (!mounted) { return; }

    // 2) Réseau hospitalier → mode normal
    if (networkStatus == NetworkStatus.authorized) {
      AppMode().setOnline();
      await _navigateBySession();
      return;
    }

    // 3) Pas sur le réseau hospitalier → afficher l'écran de blocage
    _networkStatus = networkStatus;
    setState(() => _step = _AppEntryStep.networkBlocked);
  }

  Future<void> _navigateBySession() async {
    final isLoggedIn = await _authService.isLoggedIn();
    final role = await _authService.getRole();

    if (!mounted) { return; }

    if (isLoggedIn && role == 'patient') {
      _goTo(const PatientShell());
    } else {
      _goTo(const SplashScreen());
    }
  }

  void _onRetry() {
    _init();
  }

  void _onOfflineMode() {
    AppMode().setOffline();
    // Toujours passer par le login en mode hors-réseau
    _goTo(const LoginScreen());
  }

  void _goTo(Widget destination) {
    if (!mounted) { return; }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _AppEntryStep.loading:
        return const LoaderScreen();
      case _AppEntryStep.networkBlocked:
        return _NetworkBlockScreen(
          status: _networkStatus,
          onRetry: _onRetry,
          onOfflineMode: _onOfflineMode,
        );
    }
  }
}

enum _AppEntryStep { loading, networkBlocked }

// ==================== ÉCRAN BLOCAGE RÉSEAU ====================
class _NetworkBlockScreen extends StatelessWidget {
  final NetworkStatus status;
  final VoidCallback onRetry;
  final VoidCallback onOfflineMode;

  const _NetworkBlockScreen({
    required this.status,
    required this.onRetry,
    required this.onOfflineMode,
  });

  @override
  Widget build(BuildContext context) {
    final isUnreachable = status == NetworkStatus.unreachable;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07112A), Color(0xFF0B1A3D)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(),

                // Icône
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Center(
                    child: isUnreachable
                        ? const CsnMarkPulseFlat(
                      size: 44,
                      c1: Color(0xFFB45309),
                      c2: Colors.white,
                    )
                        : const CsnMarkPulseLock(
                      size: 44,
                      c1: Color(0xFFB3261E),
                      c2: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  isUnreachable
                      ? 'Serveur inaccessible'
                      : 'Réseau non autorisé',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  isUnreachable
                      ? 'Impossible de joindre le serveur CSN.\n'
                      'Vérifiez votre connexion Wi-Fi et\n'
                      'assurez-vous d\'être dans un\n'
                      'établissement partenaire.'
                      : 'Cette application est réservée aux\n'
                      'réseaux des hôpitaux partenaires.\n'
                      'Connectez-vous au Wi-Fi de\n'
                      'l\'établissement.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xBFFFFFFF),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: const Text(
                    'Hôpital Général · Clinique Pasteur · Hôpital Central',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0x8CFFFFFF),
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(),

                // Réessayer
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Réessayer'),
                  ),
                ),

                const SizedBox(height: 12),

                // Mode hors-réseau
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: onOfflineMode,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Mode hors-réseau',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Accès limité : ordonnances uniquement',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0x73FFFFFF),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}