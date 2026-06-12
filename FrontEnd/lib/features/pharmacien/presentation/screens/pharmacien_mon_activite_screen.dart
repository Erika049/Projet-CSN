import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/pharmacien_mock_data.dart';
import '../../data/pharmacien_repository.dart';
import '../widgets/pharmacien_widgets.dart';

/// Page 43 — "Mon activité" du pharmacien.
class PharmacienMonActiviteScreen extends StatefulWidget {
  const PharmacienMonActiviteScreen({super.key});

  @override
  State<PharmacienMonActiviteScreen> createState() => _PharmacienMonActiviteScreenState();
}

class _PharmacienMonActiviteScreenState extends State<PharmacienMonActiviteScreen> {
  final PharmacienRepository _repository = PharmacienRepository();
  List<PharmacienActivity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivites();
  }

  Future<void> _loadActivites() async {
    try {
      final ords = await _repository.getHistorique();
      if (!mounted) return;
      setState(() {
        _activities = ords.map((o) => PharmacienActivity(
          heure: 'Historique', 
          kind: o.dateOrdonnance.contains('refusee') ? PharmacienActivityKind.refus : PharmacienActivityKind.delivrance,
          titre: o.dateOrdonnance.contains('refusee') ? 'Délivrance refusée' : 'Délivrance',
          patient: o.patient,
          details: o.diagnostic,
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const pharm = mockPharmacien;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                            const Text('Mon activité',
                                style: AppTextStyles.bodyMedium),
                            Text(pharm.displayName, style: AppTextStyles.h1),
                            const SizedBox(height: 2),
                            Text(
                              'Pharmacien · ${pharm.service}',
                              style: AppTextStyles.bodyMedium,
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
                  const SizedBox(height: 16),

                  // Barre de recherche
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: AppColors.textLight, size: 20),
                        border: InputBorder.none,
                        hintText: 'Rechercher un patient par nom...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const _TimeFilterBar(),
                  const SizedBox(height: 16),

                  // Stat cards
                  const Row(
                    children: [
                      Expanded(
                        child: PharmStatCard(
                          value: '4', // À rendre dynamique si nécessaire
                          label: 'MES ACTIONS',
                          valueColor: AppColors.primary,
                          background: AppColors.primaryLight,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: PharmStatCard(
                          value: '3',
                          label: 'DÉLIVRANCE',
                          valueColor: AppColors.success,
                          background: AppColors.successLight,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: PharmStatCard(
                          value: '1',
                          label: 'REFUS',
                          valueColor: AppColors.error,
                          background: AppColors.errorLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  for (final entry in _activities) ...[
                    _ActivityRow(entry: entry),
                    const SizedBox(height: 10),
                  ],

                  const SizedBox(height: 16),
                  
                  // Notice traçabilité
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: RichText(
                      text: const TextSpan(
                        style: AppTextStyles.bodySmall,
                        children: [
                          TextSpan(text: 'Toutes ces actions sont enregistrées dans logs_tracabilite.', style: TextStyle(color: AppColors.textMedium)),
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

// ---------------------------------------------------------------------------
// Barre de filtres temporels
// ---------------------------------------------------------------------------

class _TimeFilterBar extends StatefulWidget {
  const _TimeFilterBar();

  @override
  State<_TimeFilterBar> createState() => _TimeFilterBarState();
}

class _TimeFilterBarState extends State<_TimeFilterBar> {
  static const _filtres = [
    "Aujourd'hui",
    '7 jours',
    '30 jours',
    '2 mois',
    '3 mois',
  ];
  String _actif = "Aujourd'hui";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filtres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = _filtres[i] == _actif;
          return GestureDetector(
            onTap: () => setState(() => _actif = _filtres[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.textDark
                    : AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.textDark : AppColors.border,
                ),
              ),
              child: Text(
                _filtres[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ligne d'activité
// ---------------------------------------------------------------------------

class _ActivityRow extends StatelessWidget {
  final PharmacienActivity entry;

  const _ActivityRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final v = pharmActivityVisual(entry.kind);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              entry.heure,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: AppColors.textLight,
              ),
            ),
          ),
        ),
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: v.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(v.icon, color: v.fg, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.titre,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          StatusChip(
                            label: v.badge,
                            foreground: v.fg,
                            background: v.bg,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.patient,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textDark),
                      ),
                      if (entry.details.isNotEmpty)
                        Text(entry.details, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
