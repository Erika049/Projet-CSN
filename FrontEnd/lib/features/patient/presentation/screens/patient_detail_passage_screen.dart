import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/patient_models.dart';

class PatientDetailPassageScreen extends StatelessWidget {
  final PassageMedical passage;
  const PatientDetailPassageScreen({super.key, required this.passage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 54, 20, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0B57D0), Color(0xFF1A73E8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: passage.estEnCours
                            ? const Color(0xFFFEF3C7)
                            : AppColors.successLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        passage.estEnCours ? 'En cours' : 'Terminé',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: passage.estEnCours
                              ? const Color(0xFFB45309)
                              : const Color(0xFF1E7E34),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${passage.hopital} · ${passage.service}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  passage.motifVisite,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${passage.dateAdmission} · ${passage.heureAdmission}'
                      '${passage.medecin != null ? ' · ${passage.medecin}' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              child: Column(
                children: [
                  // Constantes
                  if (passage.constantes != null)
                    _SectionCard(
                      icon: Icons.monitor_heart_outlined,
                      iconColor: AppColors.primary,
                      title: 'Constantes vitales',
                      subtitle: 'Infirmière · 09:42',
                      child: _ConstantesGrid(
                        constantes: passage.constantes!,
                      ),
                    ),

                  const SizedBox(height: 14),

                  // Diagnostic
                  if (passage.diagnostic != null)
                    _SectionCard(
                      icon: Icons.person_outline,
                      iconColor: AppColors.primary,
                      title: 'Diagnostic',
                      subtitle: passage.medecin != null
                          ? '${passage.medecin} · Cardiologie'
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          passage.diagnostic!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),

                  // Prescription
                  if (passage.prescription != null)
                    _SectionCard(
                      icon: Icons.medication_outlined,
                      iconColor: AppColors.primary,
                      title: 'Prescription',
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          children: passage.prescription!
                              .split(' · ')
                              .map((med) => _RxLine(name: med))
                              .toList(),
                        ),
                      ),
                    ),

                  if (passage.examens.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _SectionCard(
                      icon: Icons.science_outlined,
                      iconColor: AppColors.primary,
                      title: 'Examens laboratoire',
                      subtitle: '${passage.examens.length} publiés',
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          children: passage.examens
                              .map((e) => _ExamLine(examen: e))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMedium,
                      ),
                    ),
                ],
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _ConstantesGrid extends StatelessWidget {
  final ConstantesVitales constantes;
  const _ConstantesGrid({required this.constantes});

  @override
  Widget build(BuildContext context) {
    final items = <_MetricData>[];
    if (constantes.tension != null) {
      items.add(_MetricData('Tension', constantes.tension!, 'cmHg',
          AppColors.primary, AppColors.primaryLight));
    }
    if (constantes.temperature != null) {
      items.add(_MetricData('Température', constantes.temperature!, '°C',
          const Color(0xFFB45309), const Color(0xFFFEF3C7)));
    }
    if (constantes.poids != null) {
      items.add(_MetricData('Poids', constantes.poids!, '',
          AppColors.textDark, const Color(0xFFF1F3F4)));
    }
    if (constantes.pouls != null) {
      items.add(_MetricData('Fréq. cardiaque', constantes.pouls!, 'bpm',
          const Color(0xFF1E7E34), AppColors.successLight));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
        children: items
            .map((m) => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: m.bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                m.label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMedium,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    m.value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: m.fg,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (m.unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      m.unit,
                      style: TextStyle(
                        fontSize: 11,
                        color: m.fg.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ))
            .toList(),
      ),
    );
  }
}

class _MetricData {
  final String label, value, unit;
  final Color fg, bg;
  const _MetricData(this.label, this.value, this.unit, this.fg, this.bg);
}

class _RxLine extends StatelessWidget {
  final String name;
  const _RxLine({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.medication_outlined,
              size: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamLine extends StatelessWidget {
  final ExamenLabo examen;
  const _ExamLine({required this.examen});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.science_outlined,
              size: 15,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  examen.type,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${examen.dateResultat} · ${examen.resultats}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}