import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../data/agent_accueil_mock_data.dart';
import '../../data/agent_accueil_service.dart';
import '../widgets/agent_accueil_widgets.dart';

/// Écran "Mon activité" (AGENT 17/41).
///
/// Journal des actions de l'agent (scans, créations, urgences), chargé via
/// [AgentAccueilService] : API en ligne, données fictives en hors-réseau.
class MonActiviteScreen extends StatefulWidget {
  const MonActiviteScreen({super.key});

  @override
  State<MonActiviteScreen> createState() => _MonActiviteScreenState();
}

class _MonActiviteScreenState extends State<MonActiviteScreen> {
  final AgentAccueilService _service = AgentAccueilService.create();

  AgentProfile? _agent;
  List<ActivityEntry> _activities = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final agent = await _service.getAgentProfile();
      final activities = await _service.getActivities();
      if (!mounted) return;
      setState(() {
        _agent = agent;
        _activities = activities;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  int _countKind(ActivityKind kind) =>
      _activities.where((a) => a.kind == kind).length;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 48, color: AppColors.textLight),
                const SizedBox(height: 12),
                const Text('Impossible de charger votre activité',
                    style: AppTextStyles.h4, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _loadData,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final agent = _agent!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mon activité',
                            style: AppTextStyles.bodyMedium),
                        Text(agent.fullName, style: AppTextStyles.h1),
                        const SizedBox(height: 2),
                        Text(
                          '${agent.poste} · ${agent.lieu}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  InitialsAvatar(
                    initials: agent.initials,
                    size: 44,
                    background: AppColors.primaryLight,
                    foreground: AppColors.primary,
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
                    icon:
                        Icon(Icons.search, color: AppColors.textLight, size: 20),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    filled: false,
                    hintText: 'Rechercher un patient par nom...',
                    hintStyle: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              const _TimeFilterBar(),
              const SizedBox(height: 16),

              // 4 cartes de stats (dérivées du journal chargé)
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: '${_activities.length}',
                      label: 'MES ACTIONS',
                      valueColor: AppColors.textDark,
                      background: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      value: '${_countKind(ActivityKind.scan)}',
                      label: 'SCAN',
                      valueColor: AppColors.success,
                      background: AppColors.successLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      value: '${_countKind(ActivityKind.creation)}',
                      label: 'CRÉATION',
                      valueColor: AppColors.primary,
                      background: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      value: '${_countKind(ActivityKind.urgence)}',
                      label: 'URGENCE',
                      valueColor: AppColors.error,
                      background: AppColors.errorLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                "AUJOURD'HUI",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 12),

              for (final entry in _activities) ...[
                _ActivityRow(entry: entry),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMedium,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(
                        text:
                            'Toutes ces actions sont aussi enregistrées dans ',
                      ),
                      TextSpan(
                        text: 'logs_tracabilite',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: " et auditables par l'administrateur.",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeFilterBar extends StatefulWidget {
  const _TimeFilterBar();

  @override
  State<_TimeFilterBar> createState() => _TimeFilterBarState();
}

class _TimeFilterBarState extends State<_TimeFilterBar> {
  static const _filtres = ["Aujourd'hui", '7 jours', '30 jours', '2 mois', '3 mois'];
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
                color: selected ? AppColors.textDark : AppColors.backgroundWhite,
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

class _ActivityRow extends StatelessWidget {
  final ActivityEntry entry;
  const _ActivityRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final v = activityVisual(entry.kind);

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
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark,
                        ),
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
