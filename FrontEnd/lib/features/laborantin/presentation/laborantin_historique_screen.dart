import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../data/laborantin_api_service.dart';
import '../data/laborantin_models.dart';

class LaborantinHistoriqueScreen extends StatefulWidget {
  const LaborantinHistoriqueScreen({super.key});

  @override
  State<LaborantinHistoriqueScreen> createState() =>
      _LaborantinHistoriqueScreenState();
}

class _LaborantinHistoriqueScreenState
    extends State<LaborantinHistoriqueScreen> {
  final _service = LaborantinApiService();
  List<ExamenPublie> _examens = [];
  bool    _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final e = await _service.getHistorique();
      if (!mounted) { return; }
      setState(() { _examens = e; _loading = false; });
    } catch (e) {
      if (!mounted) { return; }
      setState(() {
        _loading = false;
        _error   =
        'Impossible de charger l\'historique.';
      });
    }
  }

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const mois = [
        '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai',
        'Juin', 'Juil', 'Août', 'Sep', 'Oct',
        'Nov', 'Déc'
      ];
      final heure =
          '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
      final now = DateTime.now();
      if (d.day == now.day &&
          d.month == now.month &&
          d.year == now.year) {
        return 'Aujourd\'hui · $heure';
      }
      return '${d.day} ${mois[d.month]} · $heure';
    } catch (_) {
      return dateStr;
    }
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
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, 16),
              child: Text(
                'Mes publications',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                  child:
                  CircularProgressIndicator(
                      color: AppColors.warning,
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
                    Text(_error!,
                        style:
                        const TextStyle(
                            color: AppColors
                                .textMedium)),
                    const SizedBox(
                        height: 16),
                    ElevatedButton(
                        onPressed: _load,
                        child: const Text(
                            'Réessayer')),
                  ],
                ),
              )
                  : _examens.isEmpty
                  ? const Center(
                child: Text(
                  'Aucune publication',
                  style: TextStyle(
                      color: AppColors
                          .textMedium),
                ),
              )
                  : RefreshIndicator(
                color: AppColors.warning,
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets
                      .fromLTRB(
                      20, 0, 20, 24),
                  itemCount:
                  _examens.length,
                  separatorBuilder:
                      (_, __) =>
                  const SizedBox(
                      height: 10),
                  itemBuilder: (_, i) {
                    final e =
                    _examens[i];
                    return Container(
                      padding:
                      const EdgeInsets
                          .all(14),
                      decoration:
                      BoxDecoration(
                        color: AppColors
                            .backgroundWhite,
                        borderRadius:
                        BorderRadius
                            .circular(
                            14),
                        border: Border.all(
                            color: AppColors
                                .border),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height:
                                36,
                                decoration:
                                BoxDecoration(
                                  color: const Color(
                                      0xFFFEF3C7),
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      10),
                                ),
                                child:
                                const Icon(
                                  Icons
                                      .science_outlined,
                                  size:
                                  18,
                                  color: AppColors
                                      .warning,
                                ),
                              ),
                              const SizedBox(
                                  width:
                                  12),
                              Expanded(
                                child:
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      e.typeExamen,
                                      style: const TextStyle(
                                          fontSize:
                                          14,
                                          fontWeight:
                                          FontWeight
                                              .w700,
                                          color:
                                          AppColors
                                              .textDark),
                                    ),
                                    Text(
                                      e.nomComplet,
                                      style: const TextStyle(
                                          fontSize:
                                          12,
                                          color:
                                          AppColors
                                              .textMedium),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatDate(
                                    e.dateResultat),
                                style: const TextStyle(
                                    fontSize:
                                    11,
                                    color: AppColors
                                        .textLight),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height: 10),
                          Container(
                            width: double
                                .infinity,
                            padding:
                            const EdgeInsets
                                .all(
                                10),
                            decoration:
                            BoxDecoration(
                              color: const Color(
                                  0xFFFAFBFC),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                  8),
                              border: Border.all(
                                  color: AppColors
                                      .border),
                            ),
                            child: Text(
                              e.resultats,
                              style: const TextStyle(
                                  fontSize:
                                  12,
                                  color: AppColors
                                      .textDark,
                                  height:
                                  1.5),
                            ),
                          ),
                          const SizedBox(
                              height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons
                                    .local_hospital_outlined,
                                size: 12,
                                color: AppColors
                                    .textLight,
                              ),
                              const SizedBox(
                                  width:
                                  4),
                              Text(
                                '${e.hopital} · ${e.age} ans · ${e.groupeSanguin}',
                                style: const TextStyle(
                                    fontSize:
                                    11,
                                    color: AppColors
                                        .textLight),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}