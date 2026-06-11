import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/medecin_api_service.dart';
import '../../data/medecin_models.dart';
import 'medecin_dossier_patient_screen.dart';

class MedecinPatientsScreen extends StatefulWidget {
  const MedecinPatientsScreen({super.key});

  @override
  State<MedecinPatientsScreen> createState() =>
      _MedecinPatientsScreenState();
}

class _MedecinPatientsScreenState
    extends State<MedecinPatientsScreen> {
  final _service = MedecinApiService();
  List<PatientDuJour> _patients = [];
  bool    _loading = true;
  String? _error;
  final _searchController = TextEditingController();
  String  _searchQuery    = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final p = await _service.getPatientsDuJour();
      if (!mounted) { return; }
      setState(() { _patients = p; _loading = false; });
    } catch (e) {
      if (!mounted) { return; }
      setState(() {
        _loading = false;
        _error   = 'Impossible de charger les patients.';
      });
    }
  }

  List<PatientDuJour> get _filtered {
    if (_searchQuery.isEmpty) { return _patients; }
    return _patients
        .where((p) => p.nomComplet
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  20, 20, 20, 14),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes patients',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
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
                          padding:
                          EdgeInsets.only(left: 12),
                          child: Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: AppColors.textLight),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(
                                    () => _searchQuery = v),
                            decoration:
                            const InputDecoration(
                              hintText:
                              'Rechercher un patient',
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
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.success,
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
                        color:
                        AppColors.textLight),
                    const SizedBox(height: 8),
                    Text(_error!,
                        style: const TextStyle(
                            color: AppColors
                                .textMedium)),
                    const SizedBox(height: 16),
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
                  'Aucun patient trouvé',
                  style: TextStyle(
                      color: AppColors
                          .textMedium),
                ),
              )
                  : ListView.separated(
                padding:
                const EdgeInsets.fromLTRB(
                    20, 0, 20, 24),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final p = _filtered[i];
                  return GestureDetector(
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MedecinDossierPatientScreen(
                                    patient: p),
                          ),
                        ),
                    child: Container(
                      padding:
                      const EdgeInsets
                          .all(14),
                      decoration:
                      BoxDecoration(
                        color: AppColors
                            .backgroundWhite,
                        borderRadius:
                        BorderRadius
                            .circular(14),
                        border: Border.all(
                            color: AppColors
                                .border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration:
                            BoxDecoration(
                              color: AppColors
                                  .primary
                                  .withValues(
                                  alpha:
                                  0.1),
                              shape: BoxShape
                                  .circle,
                            ),
                            child: Center(
                              child: Text(
                                p.initiales,
                                style:
                                const TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                  color: AppColors
                                      .primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                              width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  p.nomComplet,
                                  style:
                                  const TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                    color: AppColors
                                        .textDark,
                                  ),
                                ),
                                const SizedBox(
                                    height: 2),
                                Text(
                                  '${p.heure} · ${p.motifVisite}',
                                  style:
                                  const TextStyle(
                                    fontSize: 11,
                                    color: AppColors
                                        .textMedium,
                                  ),
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                              Icons.chevron_right,
                              color: AppColors
                                  .textLight),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}