import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/auth_local_service.dart';
import 'loader_screen.dart';
import 'splash_screen.dart';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  final AuthLocalService _authService = AuthLocalService();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Délai minimum pour que le loader soit visible
    await Future.wait([
      _authService.isLoggedIn(),
      Future.delayed(const Duration(milliseconds: 2200)),
    ]);

    if (!mounted) { return; }

    final isLoggedIn = await _authService.isLoggedIn();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => isLoggedIn
        // TODO: remplacer par le vrai dashboard selon le rôle
            ? const SplashScreen()
            : const SplashScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const LoaderScreen();
  }
}