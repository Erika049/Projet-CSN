import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/theme/theme.dart';
import '../../data/auth_local_service.dart';
import 'splash_screen.dart';

class BiometricScreen extends StatefulWidget {
  final String userName;

  const BiometricScreen({super.key, required this.userName});

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
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
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
      setState(() => _biometricAvailable = available);
    } catch (_) {
      setState(() => _biometricAvailable = false);
    }
  }

  Future<void> _authenticate() async {
    setState(() => _isLoading = true);
    try {
      final result = await _localAuth.authenticate(
        localizedReason: 'Authentifiez-vous pour acceder a votre carnet sante',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      setState(() {
        _authenticated = result;
        _isLoading = false;
      });
      if (result && mounted) {
        _navigateToDashboard();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _navigateToDashboard() {
    // TODO: Naviguer vers le dashboard selon le role stocke
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Authentification reussie ! (Dashboard a venir)'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _logout() async {
    await _authService.clearSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (_) => false,
      );
    }
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
                    // Badge utilisateur
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withAlpha(51),
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

                // Label bienvenue
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

                // Cercle anime avec icone empreinte
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
                            color: AppColors.primary.withAlpha(51),
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
                            color: AppColors.primary.withAlpha(77),
                            width: 1,
                          ),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withAlpha(38),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(128),
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
                  'Authentification biometrique',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Touchez le capteur d'empreintes ou utilisez\nFace ID pour vous connecter.",
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
                        ? AppColors.success.withAlpha(38)
                        : AppColors.primary.withAlpha(38),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _authenticated
                          ? AppColors.success.withAlpha(102)
                          : AppColors.primary.withAlpha(102),
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
                            ? 'IDENTITE CONFIRMEE'
                            : _biometricAvailable
                                ? 'EN ATTENTE D\'AUTHENTIFICATION'
                                : 'BIOMETRIE NON DISPONIBLE',
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

                // Bouton Authentifier
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

                // Changer de compte
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
