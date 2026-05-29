import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/patient_mock_service.dart';
import '../../data/patient_models.dart';
import 'patient_detail_passage_screen.dart';

class PatientHistoriqueScreen extends StatefulWidget {
  const PatientHistoriqueScreen({super.key});

  @override
  State<PatientHistoriqueScreen> createState() =>
      _PatientHistoriqueScreenState();
}

class _PatientHistoriqueScreenState extends State<PatientHistoriqueScreen> {
  final _service = PatientMockService();
  List<PassageMedical> _passages = [];
  bool _loading = true;
  int _filterIndex = 0;

  final _filters = ['Tous', 'Consultations', 'Urgences', 'Examens'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final passages = await _service.getHistorique();
    if (!mounted) { return; }
    setState(() {
      _passages = passages;
      _loading = false;
    });
  }

  Color _dotColor(String motif) {
    final m = motif.toLowerCase();
    if (m.contains('urgence')) { return AppColors.error; }
    if (m.contains('consultation') || m.contains('cardio')) {
      return AppColors.primary;
    }
    if (m.contains('contrôle') || m.contains('annuel')) {
      return AppColors.success;
    }
    return AppColors.warning;
  }

  String _tagLabel(String motif) {
    final m = motif.toLowerCase();
    if (m.contains('urgence')) { return 'Urgence'; }
    if (m.contains('cardio')) { return 'Consultation Cardio'; }
    if (m.contains('contrôle')) { return 'Contrôle annuel'; }
    if (m.contains('examen') || m.contains('sanguin')) {
      return 'Examen sanguin';
    }
    return motif;
  }

  Color _tagBg(String motif) {
    final m = motif.toLowerCase();
    if (m.contains('urgence')) { return AppColors.errorLight; }
    if (m.contains('cardio')) { return AppColors.primaryLight; }
    if (m.contains('contrôle')) { return AppColors.successLight; }
    return AppColors.warningLight;
  }

  Color _tagFg(String motif) {
    final m = motif.toLowerCase();
    if (m.contains('urgence')) { return AppColors.error; }
    if (m.contains('cardio')) { return AppColors.primary; }
    if (m.contains('contrôle')) { return const Color(0xFF1E7E34); }
    return const Color(0xFFB45309);
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
                    'Historique médical',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_passages.length} passages · 3 hôpitaux',
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

            // Timeline
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: _passages.length,
                itemBuilder: (_, i) {
                  final p = _passages[i];
                  final isLast = i == _passages.length - 1;
                  return _TimelineItem(
                    passage: p,
                    isLast: isLast,
                    dotColor: _dotColor(p.motifVisite),
                    tagLabel: _tagLabel(p.motifVisite),
                    tagBg: _tagBg(p.motifVisite),
                    tagFg: _tagFg(p.motifVisite),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PatientDetailPassageScreen(passage: p),
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

class _TimelineItem extends StatelessWidget {
  final PassageMedical passage;
  final bool isLast;
  final Color dotColor;
  final String tagLabel;
  final Color tagBg;
  final Color tagFg;
  final VoidCallback onTap;

  const _TimelineItem({
    required this.passage,
    required this.isLast,
    required this.dotColor,
    required this.tagLabel,
    required this.tagBg,
    required this.tagFg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rail timeline
        SizedBox(
          width: 24,
          child: Column(
            children: [
              const SizedBox(height: 22),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80,
                  margin: const EdgeInsets.only(top: 4),
                  color: AppColors.border,
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Carte
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${passage.dateAdmission} · ${passage.heureAdmission}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tagLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: tagFg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    passage.diagnostic ?? passage.motifVisite,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_hospital_outlined,
                        size: 13,
                        color: AppColors.textMedium,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        passage.hopital,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}