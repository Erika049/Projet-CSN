import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'core/utils/app_navigator.dart';
import 'features/auth/presentation/screens/app_entry.dart';

void main() {
  runApp(const CarnetSanteApp());
}

class CarnetSanteApp extends StatelessWidget {
  const CarnetSanteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carnet Santé',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // ── Clé globale pour navigation
      // depuis intercepteurs Dio ──────
      navigatorKey: AppNavigator.key,
      home: const AppEntry(),
    );
  }
}