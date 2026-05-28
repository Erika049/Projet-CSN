import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'features/auth/data/auth_local_service.dart';
import 'features/auth/presentation/screens/biometric_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CarnetSanteApp()));
}

class CarnetSanteApp extends StatelessWidget {
  const CarnetSanteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carnet Sante',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthLocalService();
  bool _loading = true;
  bool _hasBiometricSession = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final hasSession = await _authService.hasSession();
    final biometricEnabled = await _authService.isBiometricEnabled();
    final userName = await _authService.getUserName() ?? '';

    setState(() {
      _hasBiometricSession = hasSession && biometricEnabled;
      _userName = userName;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasBiometricSession) {
      return BiometricScreen(userName: _userName);
    }

    return const SplashScreen();
  }
}
