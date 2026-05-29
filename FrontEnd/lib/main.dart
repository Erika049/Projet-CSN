import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
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
      home: const AppEntry(),
    );
  }
}