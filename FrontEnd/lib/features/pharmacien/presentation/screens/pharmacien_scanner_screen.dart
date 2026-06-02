import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Onglet Scanner du pharmacien (placeholder — caméra désactivée en démo).
class PharmacienScannerScreen extends StatelessWidget {
  const PharmacienScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scanner', style: AppTextStyles.bodyMedium),
                  Text('Ordonnance patient', style: AppTextStyles.h1),
                  SizedBox(height: 4),
                  Text(
                    'Scannez le QR code affiché sur le mobile du patient',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ScannerViewport(),
                    SizedBox(height: 32),
                    Text(
                      'Caméra désactivée en mode démo',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerViewport extends StatelessWidget {
  const _ScannerViewport();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: const Icon(
        Icons.qr_code_scanner,
        size: 80,
        color: AppColors.primary,
      ),
    );
  }
}
