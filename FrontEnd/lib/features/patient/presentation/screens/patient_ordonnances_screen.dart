import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class PatientOrdonnancesScreen extends StatelessWidget {
  const PatientOrdonnancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(child: Text('Ordonnances — à venir')),
    );
  }
}