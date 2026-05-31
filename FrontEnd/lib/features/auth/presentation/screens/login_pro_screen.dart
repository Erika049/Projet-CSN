import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../agent_accueil/presentation/screens/agent_accueil_shell.dart';
import '../../data/auth_api_service.dart';

/// Connexion du personnel d'accueil.
///
/// Les endpoints agent (`/admission/scan-carte`, `/admission/creer-passage`)
/// sont protégés par JWT côté backend : on doit donc authentifier l'agent
/// avant d'ouvrir son espace. Le token stocké est ensuite ajouté
/// automatiquement à chaque requête par l'intercepteur d'`ApiClient`.
class LoginProScreen extends StatefulWidget {
  const LoginProScreen({super.key});

  @override
  State<LoginProScreen> createState() => _LoginProScreenState();
}

class _LoginProScreenState extends State<LoginProScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifiantController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authApiService = AuthApiService();

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _identifiantController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _authApiService.loginProfessionnel(
        identifiantPro: _identifiantController.text.trim(),
        motDePasse: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AgentAccueilShell()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
        title: const Text("Connexion · Agent d'accueil"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text('Espace professionnel', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous avec votre identifiant professionnel pour '
                  'accéder au poste d’accueil.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 32),
                const Text(
                  'IDENTIFIANT PRO',
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
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'ex. dr_mballa',
                    prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Veuillez entrer votre identifiant'
                      : null,
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
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
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
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (v.length < 6) return 'Min. 6 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Se connecter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
