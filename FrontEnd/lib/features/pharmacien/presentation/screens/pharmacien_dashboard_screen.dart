import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/pharmacien_mock_data.dart';
import '../widgets/pharmacien_widgets.dart';
import 'pharmacien_detail_ordonnance_screen.dart';

/// Page 40 — "Ordonnances en attente" (tableau de bord pharmacien).
class PharmacienDashboardScreen extends StatelessWidget {
  final VoidCallback onOpenScanner;

  const PharmacienDashboardScreen({super.key, required this.onOpenScanner});

  @override
  Widget build(BuildContext context) {
    const pharm = mockPharmacien;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // En-tête
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pharm.service, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Bonjour ${pharm.prenom}',
                        style: AppTextStyles.h1,
                      ),
                    ],
                  ),
                ),
                const InitialsAvatar(
                  initials: 'FA',
                  size: 44,
                  background: pharmAvatarBg,
                  foreground: pharmAvatarFg,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stat cards
            const Row(
              children: [
                Expanded(
                  child: PharmStatCard(
                    value: '12',
                    label: 'À DISPENSER',
                    valueColor: AppColors.primary,
                    background: AppColors.primaryLight,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: PharmStatCard(
                    value: '3',
                    label: 'URGENTES',
                    valueColor: AppColors.error,
                    background: AppColors.errorLight,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: PharmStatCard(
                    value: '48',
                    label: 'DÉLIVRÉES',
                    valueColor: AppColors.textMedium,
                    background: AppColors.surfaceLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SectionHeader(
              title: 'Ordonnances en attente',
              actionLabel: 'Filtrer',
              onAction: () {},
            ),
            const SizedBox(height: 12),

            for (final o in mockOrdonnances) ...[
              _OrdonnanceRow(item: o),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 16),

            // Bouton scanner
            _ScannerButton(onTap: onOpenScanner),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ligne ordonnance
// ---------------------------------------------------------------------------

class _OrdonnanceRow extends StatelessWidget {
  final OrdonnanceItem item;

  const _OrdonnanceRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PharmacienDetailOrdonnanceScreen(item: item),
          ),
        );
      },
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          InitialsAvatar(initials: item.initials, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.patient,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.diagnostic} · ${item.nbMedicaments} médicament${item.nbMedicaments > 1 ? 's' : ''}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (item.isUrgent)
            const StatusChip(
              label: 'Urgent',
              foreground: AppColors.error,
              background: AppColors.errorLight,
            )
          else
            Text(
              item.tempsEcoule,
              style: AppTextStyles.bodySmall,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bouton Scanner une ordonnance
// ---------------------------------------------------------------------------

class _ScannerButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ScannerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanner une ordonnance',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'QR sur le mobile du patient',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
