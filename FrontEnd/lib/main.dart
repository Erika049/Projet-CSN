import 'package:flutter/material.dart';
import 'core/theme/theme.dart';

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
      home: const Scaffold(
        body: Center(
          child: Text('Carnet Santé Numérique'),
        ),
      ),
    );
  }
}