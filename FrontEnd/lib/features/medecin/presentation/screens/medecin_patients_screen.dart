import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/medecin_mock_service.dart';
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
  final _service = MedecinMockService();
  List<PatientDuJour> _patients = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

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
    final p = await _service.getPatientsduJour();
    if (!mounted) { return; }
    setState(() { _patients = p; _loading = false; });
  }

  List<PatientDuJour> get _filtered {
    if (_searchQuery.isEmpty) { return _patients; }
    return _patients.where((p) =>
        p.nomComplet.toLowerCase()
            .contains(_searchQuery.toLowerCase())).toList();
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Icon(Icons.search_rounded,
                              size: 18,
                              color: AppColors.textLight),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) =>
                                setState(() => _searchQuery = v),
                            decoration: const InputDecoration(
                              hintText:
                              'Rechercher par nom, ID ou QR code',
                              hintStyle: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(Icons.qr_code_scanner_rounded,
                              size: 18, color: AppColors.primary),
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
                      color: AppColors.primary, strokeWidth: 2))
                  : ListView.separated(
                padding:
                const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final p = _filtered[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MedecinDossierPatientScreen(
                                patient: p),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius:
                        BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                p.initiales,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                  FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.nomComplet,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                    FontWeight.w600,
                                    color:
                                    AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.heure} · ${p.motif}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color:
                                    AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textLight),
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