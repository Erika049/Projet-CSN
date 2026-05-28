import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/auth_local_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthLocalService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Remplacer par l'appel API reel (Dio)
      await Future.delayed(const Duration(seconds: 1));

      // Simulation : le backend retourne un token + role
      const fakeToken = 'jwt_token_placeholder';
      const fakeRole = 'patient'; // Viendra du backend
      const fakeName = 'Utilisateur';

      await _authService.saveSession(
        token: fakeToken,
        role: fakeRole,
        userName: fakeName,
      );

      if (!mounted) return;

      // Proposer l'activation de la biometrie
      _showBiometricDialog();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion : ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showBiometricDialog() {
    setState(() => _isLoading = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: AppColors.primary, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text('Activer la biometrie ?', style: AppTextStyles.h4),
            ),
          ],
        ),
        content: const Text(
          'La prochaine fois, vous pourrez vous connecter avec votre empreinte digitale ou Face ID.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToDashboard();
            },
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _authService.enableBiometric();
              if (ctx.mounted) Navigator.pop(ctx);
              _navigateToDashboard();
            },
            child: const Text('Activer'),
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard() {
    // TODO: Naviguer vers le dashboard selon le role
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion reussie ! (Dashboard a venir)'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              const Text('Connexion', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              const Text(
                'Entrez vos identifiants pour acceder a votre carnet de sante.',
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: 40),

              // Email
              const Text('Adresse email', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'exemple@email.com',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Mot de passe
              const Text('Mot de passe', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _login(),
                decoration: InputDecoration(
                  hintText: 'Votre mot de passe',
                  prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Mot de passe oublie
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: ecran mot de passe oublie
                  },
                  child: Text(
                    'Mot de passe oublie ?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Bouton Connexion
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Se connecter'),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
