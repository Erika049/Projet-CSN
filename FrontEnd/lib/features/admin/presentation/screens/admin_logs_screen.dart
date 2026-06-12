import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/admin_api_service.dart';
import '../../data/admin_models.dart';

class AdminLogsScreen extends StatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  State<AdminLogsScreen> createState() =>
      _AdminLogsScreenState();
}

class _AdminLogsScreenState
    extends State<AdminLogsScreen> {
  final _service = AdminApiService();

  List<LogAdmin> _tous     = [];
  List<LogAdmin> _filtered = [];
  bool    _loading  = true;
  String? _error;
  String  _filter   = 'Tout';
  int     _page     = 0;

  static const int _perPage = 15;

  final List<String> _filters = [
    'Tout', 'Lecture', 'Modif',
    'Scan QR', 'Sécurité',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final l = await _service.getLogs(limit: 200);
      if (!mounted) { return; }
      setState(() { _tous = l; _loading = false; });
      _applyFilter();
    } catch (e) {
      if (!mounted) { return; }
      setState(() {
        _loading = false;
        _error   = 'Impossible de charger.';
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filtered = _tous.where((l) {
        if (_filter == 'Tout') { return true; }
        final a = l.actionEffectuee.toUpperCase();
        switch (_filter) {
          case 'Lecture':
            return a.contains('LECTURE') ||
                a.contains('DOSSIER');
          case 'Modif':
            return a.contains('MODIF') ||
                a.contains('MAJ') ||
                a.contains('DIAGNOSTIC') ||
                a.contains('CONSTANTES');
          case 'Scan QR':
            return a.contains('SCAN') ||
                a.contains('QR');
          case 'Sécurité':
            return a.contains('DESACTIVATION') ||
                a.contains('BRUTE') ||
                a.contains('SECURITE') ||
                a.contains('CONNEXION');
          default:
            return true;
        }
      }).toList();
      _page = 0;
    });
  }

  List<LogAdmin> get _pageData {
    final start = _page * _perPage;
    final end   =
    (start + _perPage).clamp(0, _filtered.length);
    return _filtered.sublist(start, end);
  }

  int get _totalPages {
    if (_filtered.isEmpty) { return 1; }
    return (_filtered.length / _perPage).ceil();
  }

  void _prevPage() {
    if (_page > 0) {
      setState(() { _page--; });
    }
  }

  void _nextPage() {
    if (_page < (_totalPages - 1)) {
      setState(() { _page++; });
    }
  }

  // Couleur du badge action
  Color _badgeColor(String action) {
    final a = action.toUpperCase();
    if (a.contains('CREATION') ||
        a.contains('PASSAGE') ||
        a.contains('DELIVRANCE')) {
      return const Color(0xFF1B5E20);
    }
    if (a.contains('MODIF') ||
        a.contains('MAJ') ||
        a.contains('DIAGNOSTIC') ||
        a.contains('CONSTANTES')) {
      return const Color(0xFFE65100);
    }
    if (a.contains('SCAN') ||
        a.contains('QR') ||
        a.contains('LECTURE')) {
      return const Color(0xFF0D47A1);
    }
    if (a.contains('DESACTIVATION') ||
        a.contains('BRUTE') ||
        a.contains('SECURITE')) {
      return const Color(0xFFB71C1C);
    }
    return const Color(0xFF37474F);
  }

  Color _badgeBg(String action) {
    final a = action.toUpperCase();
    if (a.contains('CREATION') ||
        a.contains('PASSAGE') ||
        a.contains('DELIVRANCE')) {
      return const Color(0xFFE8F5E9);
    }
    if (a.contains('MODIF') ||
        a.contains('MAJ') ||
        a.contains('DIAGNOSTIC') ||
        a.contains('CONSTANTES')) {
      return const Color(0xFFFFF3E0);
    }
    if (a.contains('SCAN') ||
        a.contains('QR') ||
        a.contains('LECTURE')) {
      return const Color(0xFFE3F2FD);
    }
    if (a.contains('DESACTIVATION') ||
        a.contains('BRUTE') ||
        a.contains('SECURITE')) {
      return const Color(0xFFFFEBEE);
    }
    return const Color(0xFFECEFF1);
  }

  String _formatHeure(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}:'
          '${d.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  String _today() {
    final now = DateTime.now();
    const mois = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai',
      'Juin', 'Juil', 'Août', 'Sep', 'Oct',
      'Nov', 'Déc'
    ];
    return '${now.day} ${mois[now.month]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
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
                          'Journal d\'audit',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                            FontWeight.w700,
                            color: AppColors.textDark,
                            letterSpacing: -0.4,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Table ',
                              ),
                              TextSpan(
                                text:
                                'logs_tracabilite',
                                style: const TextStyle(
                                  fontFamily:
                                  'monospace',
                                  fontSize: 11,
                                  color: AppColors
                                      .primary,
                                ),
                              ),
                              TextSpan(
                                text:
                                ' · ${_tous.length} entrées'
                                    ' · ${_today()}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _load,
                    icon: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Filtres ──────────────────────────
            SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (_, i) {
                  final f      = _filters[i];
                  final active = f == _filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _filter = f);
                      _applyFilter();
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
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        f,
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

            // ── Contenu ──────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                  child:
                  CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2))
                  : _error != null
                  ? Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    const Icon(
                        Icons
                            .cloud_off_rounded,
                        size: 40,
                        color: AppColors
                            .textLight),
                    const SizedBox(
                        height: 8),
                    Text(_error!),
                    const SizedBox(
                        height: 16),
                    ElevatedButton(
                        onPressed: _load,
                        child: const Text(
                            'Réessayer')),
                  ],
                ),
              )
                  : _filtered.isEmpty
                  ? const Center(
                child: Text(
                  'Aucune entrée',
                  style: TextStyle(
                    color: AppColors
                        .textMedium,
                  ),
                ),
              )
                  : Column(
                children: [
                  Expanded(
                    child:
                    ListView.builder(
                      padding:
                      const EdgeInsets
                          .fromLTRB(
                          20,
                          0,
                          20,
                          8),
                      itemCount:
                      _pageData
                          .length,
                      itemBuilder:
                          (_, i) {
                        final l =
                        _pageData[i];
                        return _LogItem(
                          log: l,
                          heure: _formatHeure(
                              l.horodatage),
                          badgeColor:
                          _badgeColor(
                              l.actionEffectuee),
                          badgeBg:
                          _badgeBg(
                              l.actionEffectuee),
                        );
                      },
                    ),
                  ),

                  // ── Pagination ────
                  if (_totalPages > 1)
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                          horizontal:
                          20,
                          vertical:
                          8),
                      decoration:
                      const BoxDecoration(
                        color: AppColors
                            .backgroundWhite,
                        border: Border(
                          top: BorderSide(
                            color: AppColors
                                .border,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          IconButton(
                            onPressed:
                            _page > 0
                                ? _prevPage
                                : null,
                            icon: const Icon(
                                Icons
                                    .chevron_left),
                            color: _page >
                                0
                                ? AppColors
                                .primary
                                : AppColors
                                .textLight,
                          ),
                          Text(
                            'Page '
                                '${_page + 1}'
                                ' / '
                                '$_totalPages'
                                '  ('
                                '${_filtered.length}'
                                ' entrées)',
                            style:
                            const TextStyle(
                              fontSize:
                              12,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets locaux ─────────────────────────────────────

class _LogItem extends StatelessWidget {
  final LogAdmin log;
  final String   heure;
  final Color    badgeColor;
  final Color    badgeBg;

  const _LogItem({
    required this.log,
    required this.heure,
    required this.badgeColor,
    required this.badgeBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // Heure
          SizedBox(
            width: 56,
            child: Text(
              heure,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
                fontFamily: 'monospace',
              ),
            ),
          ),
          // Barre colorée
          Container(
            width: 3,
            height: 52,
            margin: const EdgeInsets.symmetric(
                horizontal: 8),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius:
              BorderRadius.circular(2),
            ),
          ),
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // Badge action
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius:
                    BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.actionEffectuee,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                      fontFamily: 'monospace',
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Nom personnel
                Text(
                  log.nomPersonnel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                // Cible + IP
                Text(
                  [
                    if (log.idPatient != null)
                      'cible · ${log.idPatient!.length > 8 ? '${log.idPatient!.substring(0, 8)}···' : log.idPatient}',
                    if (log.adresseIp != null)
                      'ip ${log.adresseIp}',
                  ].join(' · '),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                    fontFamily: 'monospace',
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