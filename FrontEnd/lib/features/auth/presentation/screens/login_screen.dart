import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/utils.dart';
import '../../data/auth_api_service.dart';
import '../../data/auth_local_service.dart';
import '../../../patient/presentation/screens/patient_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifiantController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authApiService = AuthApiService();
  final _authLocalService = AuthLocalService();

  bool _obscurePassword = true;

  bool get _isOffline => AppMode().isOffline;

  @override
  void dispose() {
    _identifiantController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) { return; }

    CsnLoaderOverlay.show(context, message: 'Connexion en cours…');

    try {
      await _authApiService.loginPatient(
        identifiant: _identifiantController.text.trim(),
        motDePasse: _passwordController.text,
      );

      if (!mounted) { return; }
      CsnLoaderOverlay.hide(context);

      if (_isOffline) {
        _navigateToDashboard();
      } else {
        _showBiometricDialog();
      }
    } catch (e) {
      if (!mounted) { return; }
      CsnLoaderOverlay.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showBiometricDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Activer la biométrie ?',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 8),
              const Text(
                'La prochaine fois, connectez-vous avec votre '
                    'empreinte digitale ou Face ID.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    // Validation biométrique réelle (empreinte / Face ID)
                    final available = await BiometricHelper.isAvailable();
                    if (available) {
                      final ok = await BiometricHelper.authenticate(
                        reason: 'Confirmez votre identité pour activer '
                            'la connexion biométrique',
                      );
                      if (!ok) {
                        if (!ctx.mounted) { return; }
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Biométrie non confirmée.'),
                          ),
                        );
                        return;
                      }
                    }
                    if (!ctx.mounted) { return; }
                    CsnLoaderOverlay.show(ctx,
                        message: 'Activation de la biométrie…');
                    // Enregistrement de la clé biométrique côté backend
                    final userId = await _authLocalService.getUserId();
                    if (userId != null) {
                      try {
                        await _authApiService.enregistrerBiometrie(
                          idUtilisateur: userId,
                          typeUtilisateur: 'patient',
                          clePubliqueAppareil: 'device-key-$userId',
                        );
                      } catch (_) {
                        await _authLocalService.enableBiometric();
                      }
                    } else {
                      await _authLocalService.enableBiometric();
                    }
                    if (!ctx.mounted) { return; }
                    CsnLoaderOverlay.hide(ctx);
                    Navigator.pop(ctx);
                    _navigateToDashboard();
                  },
                  child: const Text('Activer'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _navigateToDashboard();
                  },
                  child: const Text('Plus tard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PatientShell()),
          (route) => false,
    );
  }

  void _showForgotPassword() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.lock_reset_rounded,
                    color: AppColors.primary, size: 30),
              ),
              const SizedBox(height: 16),
              const Text('Réinitialiser le mot de passe',
                  style: AppTextStyles.h3),
              const SizedBox(height: 8),
              const Text(
                "Pour des raisons de sécurité médicale, la "
                "réinitialisation se fait à l'accueil de votre "
                "établissement partenaire, sur présentation d'une "
                "pièce d'identité et de votre carte CSN.",
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("J'ai compris"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Retour (masqué en offline car c'est le 1er écran)
                        if (!_isOffline)
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),

                        SizedBox(height: _isOffline ? 48 : 32),

                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            border: Border.all(
                              color: const Color(0xFF1A73E8)
                                  .withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: CsnMarkPulse(
                              size: 28,
                              c1: Color(0xFF1A73E8),
                              c2: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text('Connexion', style: AppTextStyles.h1),
                        const SizedBox(height: 8),
                        Text(
                          _isOffline
                              ? 'Mode hors-réseau · Accès limité aux ordonnances.'
                              : 'Entrez vos identifiants pour accéder à votre carnet de santé.',
                          style: AppTextStyles.bodyMedium,
                        ),

                        // Bandeau hors-réseau
                        if (_isOffline) ...[
                          const SizedBox(height: 16),
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
                                Icon(
                                  Icons.wifi_off_rounded,
                                  size: 18,
                                  color: Color(0xFFB45309),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Vous êtes hors du réseau hospitalier. '
                                        'Seules les ordonnances sont accessibles.',
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

                        const SizedBox(height: 40),

                        const Text(
                          'IDENTIFIANT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMedium,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _identifiantController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'votre identifiant',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              size: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez entrer votre identifiant';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'MOT DE PASSE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMedium,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                          decoration: InputDecoration(
                            hintText: '••••••••••••',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Min. 6 caractères';
                            }
                            return null;
                          },
                        ),

                        if (!_isOffline) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPassword,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 36),
                              ),
                              child: Text(
                                'Mot de passe oublié ?',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const Spacer(),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _login,
                            child: const Text('Se connecter'),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}