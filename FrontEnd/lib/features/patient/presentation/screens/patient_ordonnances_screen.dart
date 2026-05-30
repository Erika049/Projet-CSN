import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../data/patient_api_service.dart';
import '../../data/patient_models.dart';
import 'patient_detail_ordonnance_screen.dart';

class PatientOrdonnancesScreen extends StatefulWidget {
  const PatientOrdonnancesScreen({super.key});

  @override
  State<PatientOrdonnancesScreen> createState() =>
      _PatientOrdonnancesScreenState();
}

class _PatientOrdonnancesScreenState extends State<PatientOrdonnancesScreen> {
  final _service = PatientApiService();
  final _authService = AuthLocalService();
  List<Ordonnance> _ordonnances = [];
  bool _loading = true;
  String? _error;
  int _filterIndex = 0;

  final _filters = ['En cours', 'Toutes', 'Archives'];

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
      final userId = await _authService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('Session introuvable');
      }
      final ordonnances = await _service.getOrdonnances(userId);
      if (!mounted) { return; }
      setState(() {
        _ordonnances = ordonnances;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) { return; }
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Ordonnance> get _filtered {
    if (_filterIndex == 0) {
      return _ordonnances.where((o) => o.estActive).toList();
    }
    if (_filterIndex == 2) {
      return _ordonnances.where((o) => !o.estActive).toList();
    }
    return _ordonnances;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final actives = _ordonnances.where((o) => o.estActive).length;
    final archives = _ordonnances.length - actives;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes ordonnances',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$actives en cours · $archives archivées',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),

            // Filtres
            const SizedBox(height: 14),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final active = i == _filterIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _filterIndex = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.textDark
                            : AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: active
                              ? AppColors.textDark
                              : AppColors.borderDark,
                        ),
                      ),
                      child: Text(
                        _filters[i],
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

            const SizedBox(height: 16),

            // Liste
            Expanded(
              child: _error != null
                  ? CsnEmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: 'Impossible de charger',
                      message: 'Vérifiez votre connexion puis réessayez.',
                      onRetry: _loadData,
                    )
                  : _filtered.isEmpty
                      ? const CsnEmptyState(
                          icon: Icons.medication_outlined,
                          title: 'Aucune ordonnance',
                          message:
                              'Vos ordonnances délivrées par les médecins '
                              'apparaîtront ici.',
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _loadData,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final o = _filtered[i];
                              return _OrdonnanceCard(
                                ordonnance: o,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PatientDetailOrdonnanceScreen(
                                            ordonnance: o),
                                  ),
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

class _OrdonnanceCard extends StatelessWidget {
  final Ordonnance ordonnance;
  final VoidCallback onTap;

  const _OrdonnanceCard({
    required this.ordonnance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = ordonnance.estActive;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryLight
                        : const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication_outlined,
                    size: 16,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ordonnance.titre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ordonnance.dateDelivrance} · ${ordonnance.medicaments.length} médicaments',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? ordonnance.joursRestants <= 5
                        ? AppColors.warningLight
                        : AppColors.successLight
                        : const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isActive
                        ? 'Expire dans ${ordonnance.joursRestants} j'
                        : 'Terminée',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? ordonnance.joursRestants <= 5
                          ? const Color(0xFFB45309)
                          : const Color(0xFF1E7E34)
                          : AppColors.textMedium,
                    ),
                  ),
                ),
              ],
            ),
            // Médecin
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 13,
                    color: AppColors.textMedium,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${ordonnance.medecin} · ${ordonnance.specialite}',
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
      ),
    );
  }
}