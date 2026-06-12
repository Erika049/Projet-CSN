import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/app_mode.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../data/auth_local_service.dart';
import 'loader_screen.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

class BiometricScreen extends StatefulWidget {
  final String userName;
  final String role;

  const BiometricScreen({
    super.key,
    required this.userName,
    required this.role,
  });

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final AuthLocalService _authService = AuthLocalService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _biometricAvailable = false;
  bool _authenticated = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _checkBiometrics();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    try {
      final available = await _localAuth.canCheckBiometrics;
      if (!mounted) { return; }
      setState(() => _biometricAvailable = available);
    } catch (_) {
      if (!mounted) { return; }
      setState(() => _biometricAvailable = false);
    }
  }

  Future<void> _authenticate() async {
    setState(() => _isLoading = true);
    try {
      final result = await _localAuth.authenticate(
        localizedReason:
        'Authentifiez-vous pour accéder à votre carnet santé',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (!mounted) { return; }
      setState(() {
        _authenticated = result;
        _isLoading = false;
      });
      if (result) {
        _navigateToDashboard();
      }
    } catch (e) {
      if (!mounted) { return; }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _navigateToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            _LoadingThenDashboard(role: widget.role),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
          (route) => false,
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    AppMode().reset();
    if (!mounted) { return; }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundDark,
              AppColors.backgroundDarkSecondary,
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    const SizedBox(width: 40),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),

                const Spacer(),

                const Text(
                  'BON RETOUR',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.userName,
                  style: AppTextStyles.h2White,
                ),
                const SizedBox(height: 32),

                // Cercle animé
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary
                                .withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary
                              .withValues(alpha: 0.15),
                          border: Border.all(
                            color: AppColors.primary
                                .withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.fingerprint,
                          size: 52,
                          color: _authenticated
                              ? AppColors.success
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Authentification biométrique',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Touchez le capteur d\'empreintes ou\n'
                      'utilisez Face ID pour vous connecter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),

                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _authenticated
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _authenticated
                          ? AppColors.success.withValues(alpha: 0.4)
                          : AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: _authenticated
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _authenticated
                            ? 'IDENTITÉ CONFIRMÉE'
                            : _biometricAvailable
                            ? 'EN ATTENTE D\'AUTHENTIFICATION'
                            : 'BIOMÉTRIE NON DISPONIBLE',
                        style: TextStyle(
                          color: _authenticated
                              ? AppColors.success
                              : AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _authenticate,
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Authentifier'),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: _logout,
                  child: const Text(
                    'Changer de compte',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
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

// ══════════════════════════════════════════════════════
// Loader post-biométrie
// Ping le backend pour le réveiller (cold start Render)
// puis navigue vers le dashboard
// ══════════════════════════════════════════════════════
class _LoadingThenDashboard extends StatefulWidget {
  final String role;
  const _LoadingThenDashboard({required this.role});

  @override
  State<_LoadingThenDashboard> createState() =>
      _LoadingThenDashboardState();
}

class _LoadingThenDashboardState
    extends State<_LoadingThenDashboard> {

  @override
  void initState() {
    super.initState();
    _warmupAndNavigate();
  }

  Future<void> _warmupAndNavigate() async {
    // Ping le backend en parallèle avec délai minimum
    await Future.wait([
      _pingBackend(),
      Future.delayed(const Duration(milliseconds: 2000)),
    ]);
    if (!mounted) { return; }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            LoginScreen.shellForRole(widget.role),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  Future<void> _pingBackend() async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      final healthUrl = ApiEndpoints.baseUrl
          .replaceAll('/api/v1', '/actuator/health');
      await dio.get(healthUrl);
    } catch (_) {
      // Silencieux — on navigue quand même
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoaderScreen();
  }
}