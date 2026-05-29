import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class PatientCarteScreen extends StatelessWidget {
  const PatientCarteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(child: Text('Carte — à venir')),
    );
  }
}