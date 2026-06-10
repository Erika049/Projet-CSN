import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/medecin_mock_service.dart';
import '../../data/medecin_models.dart';
import 'medecin_dossier_patient_screen.dart';

class MedecinDashboardScreen extends StatefulWidget {
  const MedecinDashboardScreen({super.key});

  @override
  State<MedecinDashboardScreen> createState() =>
      _MedecinDashboardScreenState();
}

class _MedecinDashboardScreenState extends State<MedecinDashboardScreen> {
  final _service = MedecinMockService();
  List<PatientDuJour> _patients = [];
  Map<String, int> _stats = {};
  bool _loading = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _service.getPatientsduJour(),
      _service.getStatsJour(),
    ]);
    if (!mounted) { return; }
    setState(() {
      _patients = results[0] as List<PatientDuJour>;
      _stats = results[1] as Map<String, int>;
      _loading = false;
    });
  }

  List<PatientDuJour> get _filtered {
    if (_searchQuery.isEmpty) { return _patients; }
    return _patients.where((p) =>
    p.nomComplet.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.motif.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'en_cours': return AppColors.primary;
      case 'urgence': return AppColors.error;
      case 'termine': return AppColors.success;
      case 'en_attente': return const Color(0xFFB45309);
      default: return AppColors.textMedium;
    }
  }

  Color _statutBg(String statut) {
    switch (statut) {
      case 'en_cours': return AppColors.primaryLight;
      case 'urgence': return AppColors.errorLight;
      case 'termine': return AppColors.successLight;
      case 'en_attente': return const Color(0xFFFEF3C7);
      default: return const Color(0xFFF1F3F4);
    }
  }

  String _statutLabel(String statut) {
    switch (statut) {
      case 'en_cours': return 'En cours';
      case 'urgence': return 'Urgence';
      case 'termine': return 'Terminé';
      case 'en_attente': return 'En attente';
      case 'a_venir': return 'À venir';
      default: return statut;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2),
        ),
      );
    }

    final info = _service.getMedecinInfo();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Header fixe
          Container(
            color: AppColors.backgroundWhite,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bonjour, Dr.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMedium,
                                ),
                              ),
                              Text(
                                '${info['prenom']} ${info['nom']}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              Text(
                                info['service'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.success
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              info['initiales'] ?? 'AM',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Stats
                    Row(
                      children: [
                        _StatChip(
                          n: _stats['total'] ?? 0,
                          label: 'Patients',
                          color: AppColors.primary,
                          bg: AppColors.primaryLight,
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          n: _stats['en_cours'] ?? 0,
                          label: 'En cours',
                          color: const Color(0xFFB45309),
                          bg: const Color(0xFFFEF3C7),
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          n: _stats['urgences'] ?? 0,
                          label: 'Urgences',
                          color: AppColors.error,
                          bg: AppColors.errorLight,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Recherche
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText:
                                'Rechercher par nom ou motif…',
                                hintStyle: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  size: 18, color: AppColors.textLight),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Liste patients
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadData,
              child: _filtered.isEmpty
                  ? const Center(
                child: Text(
                  'Aucun patient trouvé',
                  style: TextStyle(color: AppColors.textMedium),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                    18, 12, 18, 100),
                itemCount: _filtered.length + 1,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Padding(
                      padding:
                      const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Aujourd'hui · ${_filtered.length} patients",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMedium,
                              letterSpacing: 0.3,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 28),
                            ),
                            child: const Text(
                              'Filtrer',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final p = _filtered[i - 1];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MedecinDossierPatientScreen(
                              patient: p,
                            ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: p.statut == 'urgence'
                              ? AppColors.error
                              .withValues(alpha: 0.3)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _statutBg(p.statut),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                p.initiales,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _statutColor(
                                      p.statut),
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
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.heure} · ${p.motif}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tag statut
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statutBg(p.statut),
                              borderRadius:
                              BorderRadius.circular(999),
                            ),
                            child: Text(
                              _statutLabel(p.statut),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _statutColor(p.statut),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int n;
  final String label;
  final Color color;
  final Color bg;

  const _StatChip({
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
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}