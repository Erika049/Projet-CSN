import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../data/laborantin_api_service.dart';
import '../data/laborantin_models.dart';

class LaborantinActiviteScreen extends StatefulWidget {
  const LaborantinActiviteScreen({super.key});

  @override
  State<LaborantinActiviteScreen> createState() =>
      _LaborantinActiviteScreenState();
}

class _LaborantinActiviteScreenState
    extends State<LaborantinActiviteScreen> {
  final _service     = LaborantinApiService();
  final _authService = AuthLocalService();
  final _searchCtrl  = TextEditingController();

  String?            _nom;
  List<ExamenPublie> _all      = [];
  List<ExamenPublie> _filtered = [];
  bool    _loading     = true;
  String? _error;
  int     _periodIndex = 0;
  String  _searchQuery = '';
  int     _page        = 0;

  static const int _perPage = 10;

  final List<_Period> _periods = const [
    _Period("Aujourd'hui", 0),
    _Period('7 jours',    7),
    _Period('30 jours',  30),
    _Period('2 mois',    60),
    _Period('3 mois',    90),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final nom = await _authService.getUserName();
      final e   = await _service.getHistorique();
      if (!mounted) { return; }
      setState(() {
        _nom     = nom;
        _all     = e;
        _loading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) { return; }
      setState(() {
        _loading = false;
        _error   = 'Impossible de charger.';
      });
    }
  }

  void _applyFilters() {
    final jours = _periods[_periodIndex].jours;
    final now   = DateTime.now();
    final result = _all.where((e) {
      if (jours > 0) {
        try {
          final d = DateTime.parse(e.dateResultat);
          if (now.difference(d).inDays > jours) {
            return false;
          }
        } catch (_) {}
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return e.nomComplet
            .toLowerCase()
            .contains(q) ||
            e.typeExamen
                .toLowerCase()
                .contains(q);
      }
      return true;
    }).toList();

    setState(() {
      _filtered = result;
      _page     = 0;
    });
  }

  List<ExamenPublie> get _pageData {
    final start = _page * _perPage;
    final end   =
    (start + _perPage).clamp(0, _filtered.length);
    return _filtered.sublist(start, end);
  }

  int get _totalPages {
    if (_filtered.isEmpty) { return 1; }
    return (_filtered.length / _perPage).ceil();
  }

  String _initiales(String? nom) {
    if (nom == null || nom.isEmpty) { return 'PN'; }
    return nom
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  String _heureFromDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _dayLabel(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const mois = [
        '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai',
        'Juin', 'Juil', 'Août', 'Sep', 'Oct',
        'Nov', 'Déc'
      ];
      final now = DateTime.now();
      if (d.day == now.day &&
          d.month == now.month &&
          d.year == now.year) {
        return "AUJOURD'HUI · "
            '${d.day} '
            '${mois[d.month].toUpperCase()} '
            '${d.year}';
      }
      final yesterday =
      now.subtract(const Duration(days: 1));
      if (d.day == yesterday.day &&
          d.month == yesterday.month) {
        return 'HIER · '
            '${d.day} '
            '${mois[d.month].toUpperCase()}';
      }
      return '${d.day} '
          '${mois[d.month].toUpperCase()} '
          '${d.year}';
    } catch (_) {
      return dateStr.toUpperCase();
    }
  }

  Map<String, List<ExamenPublie>> _groupByDay(
      List<ExamenPublie> list) {
    final map = <String, List<ExamenPublie>>{};
    for (final e in list) {
      try {
        final d = DateTime.parse(e.dateResultat);
        final key = '${d.year}-'
            '${d.month.toString().padLeft(2, '0')}-'
            '${d.day.toString().padLeft(2, '0')}';
        map.putIfAbsent(key, () => []).add(e);
      } catch (_) {
        map.putIfAbsent('Inconnu', () => []).add(e);
      }
    }
    return map;
  }

  void _prevPage() {
    if (_page > 0) {
      setState(() { _page--; });
    }
  }

  void _nextPage() {
    if (_page < _totalPages - 1) {
      setState(() { _page++; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(
              color: Color(0xFFB45309),
              strokeWidth: 2),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              const Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: AppColors.textLight),
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.textMedium)),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }

    final groups = _groupByDay(_pageData);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
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
                        Text(
                          _nom ?? 'Patrick Njoh',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const Text(
                          'Laborantin · Laboratoire · Hôp. Général',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _initiales(_nom),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Barre recherche ──────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius:
                  BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 12),
                      child: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: AppColors.textLight),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) {
                          _searchQuery = v;
                          _applyFilters();
                        },
                        decoration:
                        const InputDecoration(
                          hintText:
                          'Rechercher un patient…',
                          hintStyle: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Filtres période ──────────────────
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20),
                itemCount: _periods.length,
                itemBuilder: (_, i) {
                  final active = i == _periodIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(
                              () => _periodIndex = i);
                      _applyFilters();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          right: 8),
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.textDark
                            : AppColors.backgroundWhite,
                        borderRadius:
                        BorderRadius.circular(
                            999),
                        border: Border.all(
                          color: active
                              ? AppColors.textDark
                              : AppColors.borderDark,
                        ),
                      ),
                      child: Text(
                        _periods[i].label,
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
                },
              ),
            ),

            const SizedBox(height: 10),

            // ── Stats mini ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              child: Row(
                children: [
                  _MiniStat(
                    value: _filtered.length
                        .toString(),
                    label: 'MES ACTIONS',
                    color: AppColors.primary,
                    bg: AppColors.primaryLight,
                  ),
                  const SizedBox(width: 8),
                  _MiniStat(
                    value: _filtered.length
                        .toString(),
                    label: 'PUBLICATION',
                    color: const Color(0xFFB45309),
                    bg: const Color(0xFFFEF3C7),
                  ),
                  const SizedBox(width: 8),
                  const _MiniStat(
                    value: '0',
                    label: 'REÇU',
                    color: AppColors.textMedium,
                    bg: Color(0xFFF1F3F4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Contenu ──────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                child: Text(
                  'Aucune activité\nsur cette période',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
              )
                  : Column(
                children: [
                  // Liste groupée
                  Expanded(
                    child: ListView.builder(
                      padding:
                      const EdgeInsets
                          .fromLTRB(
                          20, 0, 20, 8),
                      itemCount:
                      groups.length,
                      itemBuilder: (_, gi) {
                        final key =
                        groups.keys
                            .elementAt(gi);
                        final items =
                        groups[key]!;
                        return Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                  vertical:
                                  10),
                              child: Text(
                                _dayLabel(key),
                                style:
                                const TextStyle(
                                  fontSize: 10,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                  color: AppColors
                                      .textMedium,
                                  letterSpacing:
                                  0.5,
                                ),
                              ),
                            ),
                            ...items.map(
                                  (e) =>
                                  _ActivityItem(
                                    examen: e,
                                    heure: _heureFromDate(
                                        e.dateResultat),
                                  ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Pagination
                  if (_totalPages > 1)
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                          horizontal: 20,
                          vertical: 10),
                      decoration:
                      const BoxDecoration(
                        color: AppColors
                            .backgroundWhite,
                        border: Border(
                          top: BorderSide(
                            color:
                            AppColors.border,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _page > 0
                                ? _prevPage
                                : null,
                            icon: const Icon(
                                Icons
                                    .chevron_left),
                            color: _page > 0
                                ? AppColors
                                .primary
                                : AppColors
                                .textLight,
                          ),
                          Text(
                            'Page ${_page + 1}'
                                ' / $_totalPages',
                            style:
                            const TextStyle(
                              fontSize: 13,
                              color: AppColors
                                  .textMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: _page < (_totalPages - 1)
                                ? _nextPage
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            color: _page < (_totalPages - 1)
                                ? AppColors.primary
                                : AppColors.textLight,
                          ),
                        ],
                      ),
                    ),

                  // Note traçabilité
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(12),
                    color:
                    const Color(0xFFF8F9FA),
                    child: const Text(
                      'Toutes ces actions sont '
                          'enregistrées dans '
                          'logs_tracabilite et '
                          'auditables par '
                          "l'administrateur.",
                      style: TextStyle(
                        fontSize: 11,
                        color:
                        AppColors.textMedium,
                        height: 1.4,
                      ),
                      textAlign:
                      TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Classes locales ────────────────────────────────────

class _Period {
  final String label;
  final int    jours;
  const _Period(this.label, this.jours);
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color  color;
  final Color  bg;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ExamenPublie examen;
  final String       heure;

  const _ActivityItem({
    required this.examen,
    required this.heure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              heure,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius:
              BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.science_outlined,
              size: 16,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        examen.typeExamen,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFFE8F5E9),
                        borderRadius:
                        BorderRadius.circular(
                            999),
                      ),
                      child: const Text(
                        'Publication',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                          FontWeight.w600,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  examen.nomComplet,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}