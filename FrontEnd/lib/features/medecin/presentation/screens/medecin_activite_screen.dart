import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/medecin_api_service.dart';
import '../../data/medecin_models.dart';

class MedecinActiviteScreen extends StatefulWidget {
  const MedecinActiviteScreen({super.key});

  @override
  State<MedecinActiviteScreen> createState() =>
      _MedecinActiviteScreenState();
}

class _MedecinActiviteScreenState
    extends State<MedecinActiviteScreen> {
  final _service = MedecinApiService();
  List<ActivitePro> _activites = [];
  bool _loading = true;
  String? _error;
  int _periodIndex = 0;

  final List<_Period> _periods = [
    const _Period("Aujourd'hui", 0),
    const _Period('7 jours',     7),
    const _Period('30 jours',   30),
    const _Period('2 mois',     60),
    const _Period('3 mois',     90),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final a = await _service.getActivite(
          jours: _periods[_periodIndex].jours);
      if (!mounted) { return; }
      setState(() { _activites = a; _loading = false; });
    } catch (e) {
      if (!mounted) { return; }
      setState(() {
        _loading = false;
        _error   = 'Impossible de charger l\'activité.';
      });
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'consult':
      case 'diag':   return AppColors.primary;
      case 'ord':    return AppColors.success;
      case 'exam':   return const Color(0xFFB45309);
      default:       return AppColors.textMedium;
    }
  }

  Color _typeBg(String type) {
    switch (type) {
      case 'consult':
      case 'diag':   return AppColors.primaryLight;
      case 'ord':    return AppColors.successLight;
      case 'exam':   return const Color(0xFFFEF3C7);
      default:       return const Color(0xFFF1F3F4);
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'consult': return Icons.person_outline;
      case 'diag':    return Icons.description_outlined;
      case 'ord':     return Icons.medication_outlined;
      case 'exam':    return Icons.science_outlined;
      default:        return Icons.history_outlined;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      final now = DateTime.now();
      final heure =
          '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
      if (d.day == now.day && d.month == now.month) {
        return "Aujourd'hui · $heure";
      }
      final yesterday =
      now.subtract(const Duration(days: 1));
      if (d.day == yesterday.day &&
          d.month == yesterday.month) {
        return 'Hier · $heure';
      }
      const mois = [
        '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
        'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
      ];
      return '${d.day} ${mois[d.month]} · $heure';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────
          Container(
            color: AppColors.backgroundWhite,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mon activité',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const Text(
                      'Historique',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _MiniStat(
                          n:     _activites.length,
                          label: 'Actions',
                          color: AppColors.primary,
                          bg:    AppColors.primaryLight,
                        ),
                        const SizedBox(width: 10),
                        _MiniStat(
                          n: _activites
                              .where((a) =>
                          a.type == 'consult')
                              .length,
                          label: 'Consultations',
                          color: AppColors.primary,
                          bg:    AppColors.primaryLight,
                        ),
                        const SizedBox(width: 10),
                        _MiniStat(
                          n: _activites
                              .where((a) => a.type == 'ord')
                              .length,
                          label: 'Ordonnances',
                          color: AppColors.success,
                          bg:    AppColors.successLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Filtres période ──────────────────────────
          Container(
            color: AppColors.backgroundWhite,
            padding: const EdgeInsets.fromLTRB(
                18, 8, 18, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periods
                    .asMap()
                    .entries
                    .map((e) {
                  final active = e.key == _periodIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(
                              () => _periodIndex = e.key);
                      _load();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          right: 8),
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.textDark
                            : AppColors.backgroundWhite,
                        borderRadius:
                        BorderRadius.circular(999),
                        border: Border.all(
                          color: active
                              ? AppColors.textDark
                              : AppColors.borderDark,
                        ),
                      ),
                      child: Text(
                        e.value.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? Colors.white
                              : AppColors.textMedium,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Liste activités ──────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2))
                : _error != null
                ? Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Icon(
                      Icons.cloud_off_rounded,
                      size: 40,
                      color: AppColors.textLight),
                  const SizedBox(height: 8),
                  Text(_error!,
                      style: const TextStyle(
                          color:
                          AppColors.textMedium)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: _load,
                      child:
                      const Text('Réessayer')),
                ],
              ),
            )
                : _activites.isEmpty
                ? const Center(
              child: Text(
                'Aucune activité sur cette période',
                style: TextStyle(
                    color:
                    AppColors.textMedium),
              ),
            )
                : ListView.builder(
              padding:
              const EdgeInsets.fromLTRB(
                  18, 12, 18, 100),
              itemCount: _activites.length,
              itemBuilder: (_, i) {
                final a = _activites[i];
                return Container(
                  margin:
                  const EdgeInsets.only(
                      bottom: 8),
                  padding:
                  const EdgeInsets.all(
                      12),
                  decoration: BoxDecoration(
                    color: AppColors
                        .backgroundWhite,
                    borderRadius:
                    BorderRadius.circular(
                        12),
                    border: Border.all(
                        color:
                        AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration:
                        BoxDecoration(
                          color:
                          _typeBg(a.type),
                          borderRadius:
                          BorderRadius
                              .circular(8),
                        ),
                        child: Icon(
                          _typeIcon(a.type),
                          size: 15,
                          color: _typeColor(
                              a.type),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              a.label,
                              style:
                              const TextStyle(
                                fontSize: 13,
                                fontWeight:
                                FontWeight
                                    .w700,
                                color: AppColors
                                    .textDark,
                              ),
                            ),
                            Text(
                              a.patient,
                              style:
                              const TextStyle(
                                fontSize: 12,
                                color: AppColors
                                    .textMedium,
                              ),
                            ),
                            if (a.detail
                                .isNotEmpty)
                              Text(
                                a.detail,
                                style:
                                const TextStyle(
                                  fontSize: 11,
                                  color: AppColors
                                      .textLight,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(a.date),
                        style: const TextStyle(
                          fontSize: 10,
                          color:
                          AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Period {
  final String label;
  final int    jours;
  const _Period(this.label, this.jours);
}

class _MiniStat extends StatelessWidget {
  final int    n;
  final String label;
  final Color  color;
  final Color  bg;

  const _MiniStat({
    required this.n,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$n',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}