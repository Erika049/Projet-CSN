import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../data/laborantin_api_service.dart';
import '../data/laborantin_models.dart';
import 'laborantin_publier_screen.dart';

class LaborantinDashboardScreen extends StatefulWidget {
  const LaborantinDashboardScreen({super.key});

  @override
  State<LaborantinDashboardScreen> createState() =>
      _LaborantinDashboardScreenState();
}

class _LaborantinDashboardScreenState
    extends State<LaborantinDashboardScreen> {
  final _service     = LaborantinApiService();
  final _authService = AuthLocalService();

  String?                _nom;
  StatsLabo?             _stats;
  List<PassageEnAttente> _passages = [];
  bool    _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final nom = await _authService.getUserName();
      final results = await Future.wait([
        _service.getStats(),
        _service.getPassagesEnAttente(),
      ]);
      if (!mounted) { return; }
      setState(() {
        _nom      = nom;
        _stats    = results[0] as StatsLabo;
        _passages =
        results[1] as List<PassageEnAttente>;
        _loading  = false;
      });
    } catch (e) {
      if (!mounted) { return; }
      setState(() {
        _loading = false;
        _error   =
        'Impossible de charger les données.';
      });
    }
  }

  bool _isUrgent(PassageEnAttente p) =>
      p.motifVisite.toLowerCase().contains('urgence') ||
          p.motifVisite.toLowerCase().contains('urgent');

  int get _nbUrgents =>
      _passages.where(_isUrgent).length;

  String _initiales(String? nom) {
    if (nom == null || nom.isEmpty) { return 'PN'; }
    return nom
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();
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
              const Icon(Icons.cloud_off_rounded,
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

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFB45309),
          onRefresh: _loadData,
          child: CustomScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                      20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // ── Header ─────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                const Text(
                                  'Laboratoire · Hôpital Général',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors
                                        .textMedium,
                                  ),
                                ),
                                Text(
                                  'Bonjour ${_nom?.split(' ').first ?? 'Patrick'}',
                                  style:
                                  const TextStyle(
                                    fontSize: 24,
                                    fontWeight:
                                    FontWeight.w700,
                                    color: AppColors
                                        .textDark,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFFFEF3C7),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _initiales(_nom),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight.w700,
                                  color:
                                  Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── 3 Stats ────────────────
                      Row(
                        children: [
                          _StatPill(
                            value: _passages.length
                                .toString(),
                            label: 'EN ATTENTE',
                            color: AppColors.primary,
                            bg: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 10),
                          _StatPill(
                            value:
                            _nbUrgents.toString(),
                            label: 'URGENTS',
                            color: AppColors.error,
                            bg: AppColors.errorLight,
                          ),
                          const SizedBox(width: 10),
                          _StatPill(
                            value: (_stats?.total ?? 0)
                                .toString(),
                            label: 'PUBLIÉS',
                            color: AppColors.textMedium,
                            bg: const Color(0xFFF1F3F4),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Titre + Filtrer ────────
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          const Text(
                            'Demandes d\'examens',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Filtrer',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ── Liste ──────────────────────────
              _passages.isEmpty
                  ? SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration:
                          BoxDecoration(
                            color: AppColors
                                .successLight,
                            shape:
                            BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color:
                            AppColors.success,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Aucune demande\nen attente',
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w600,
                            color:
                            AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                    20, 0, 20, 100),
                sliver: SliverList(
                  delegate:
                  SliverChildBuilderDelegate(
                        (_, i) {
                      final p = _passages[i];
                      return _ExamenCard(
                        passage:  p,
                        isUrgent: _isUrgent(p),
                        onTap: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LaborantinPublierScreen(
                                        passage: p),
                              ),
                            ).then(
                                    (_) => _loadData()),
                      );
                    },
                    childCount: _passages.length,
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

// ── Widgets locaux ─────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final Color  color;
  final Color  bg;

  const _StatPill({
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
            horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
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

class _ExamenCard extends StatelessWidget {
  final PassageEnAttente passage;
  final bool             isUrgent;
  final VoidCallback?    onTap;

  const _ExamenCard({
    required this.passage,
    required this.isUrgent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUrgent
                ? AppColors.error
                .withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: isUrgent
                    ? AppColors.errorLight
                    : AppColors.primaryLight,
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.science_outlined,
                size: 20,
                color: isUrgent
                    ? AppColors.error
                    : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          passage.motifVisite,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      if (isUrgent)
                        Container(
                          padding: const EdgeInsets
                              .symmetric(
                              horizontal: 8,
                              vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius:
                            BorderRadius.circular(
                                999),
                          ),
                          child: const Text(
                            'Urgent',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    passage.nomComplet,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Demandé à ${passage.heure} · ${passage.hopital}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMedium,
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