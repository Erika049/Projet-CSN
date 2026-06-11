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

  String?              _nom;
  StatsLabo?           _stats;
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
        _error   = e.toString().contains('timeout') ||
            e.toString().contains('longer than')
            ? 'Le serveur met du temps à répondre.\n'
            'Cliquez sur Réessayer.'
            : 'Impossible de charger les données.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(
              color: AppColors.warning,
              strokeWidth: 2),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 64,
                    color: AppColors.textLight),
                const SizedBox(height: 16),
                const Text(
                  'Impossible de charger\nles données',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMedium,
                        height: 1.5)),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Réessayer')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.warning,
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      if (_stats != null)
                        _buildStats(_stats!),
                      const SizedBox(height: 24),
                      _buildPassagesEnAttente(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.warning
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.science_outlined,
                  color: AppColors.warning,
                  size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text('Bonjour,',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMedium)),
                Text(
                  _nom ?? 'Laborantin',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(StatsLabo stats) {
    return Row(
      children: [
        _StatCard(
          label: 'En attente',
          value: stats.enAttente.toString(),
          color: AppColors.warning,
          bg:    const Color(0xFFFEF3C7),
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Publiés',
          value: stats.total.toString(),
          color: AppColors.success,
          bg:    AppColors.successLight,
        ),
      ],
    );
  }

  Widget _buildPassagesEnAttente() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            const Text('Patients en attente',
                style: AppTextStyles.h4),
            Text(
              '${_passages.length} patient'
                  '${_passages.length > 1 ? 's' : ''}',
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_passages.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(16),
              border:
              Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 40,
                      color: AppColors.success),
                  SizedBox(height: 8),
                  Text(
                    'Aucun examen en attente',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMedium),
                  ),
                ],
              ),
            ),
          )
        else
          ..._passages.map((p) => _PassageCard(
            passage: p,
            onTap:   () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    LaborantinPublierScreen(
                        passage: p),
              ),
            ).then((_) => _loadData()),
          )),
      ],
    );
  }
}

// ── Widgets locaux ─────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;
  final Color  bg;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium)),
          ],
        ),
      ),
    );
  }
}

class _PassageCard extends StatelessWidget {
  final PassageEnAttente passage;
  final VoidCallback?    onTap;

  const _PassageCard({
    required this.passage,
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
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  passage.initiales,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning),
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
                    passage.nomComplet,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${passage.age} ans · '
                        '${passage.groupeSanguin} · '
                        '${passage.motifVisite}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMedium),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  passage.heure,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius:
                    BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'En attente',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}