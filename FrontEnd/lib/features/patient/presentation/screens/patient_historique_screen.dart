import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class PatientHistoriqueScreen extends StatelessWidget {
  const PatientHistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(child: Text('Historique — à venir')),
    );
  }
}