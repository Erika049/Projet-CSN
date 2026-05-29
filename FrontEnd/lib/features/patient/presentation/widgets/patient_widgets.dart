import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../data/patient_mock_data.dart';

/// Carte blanche standard avec bordure (conteneur de base de l'app).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}

/// Titre de section avec action optionnelle alignée à droite ("Voir tout").
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Pastille de statut colorée (badge arrondi).
class StatusChip extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final bool dot;

  const StatusChip({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Petit avatar à initiales coloré.
class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color background;
  final Color foreground;

  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.background = AppColors.primaryLight,
    this.foreground = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

/// Cellule individuelle de constante vitale (libellé + valeur + unité).
class VitalCell extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color valueColor;
  final Color? background;

  const VitalCell({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.valueColor = AppColors.textDark,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: 3),
              Text(
                unit!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ],
        ),
      ],
    );

    if (background == null) return content;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: content,
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers couleur (mapping enum -> couleurs UI)
// ---------------------------------------------------------------------------

({Color fg, Color bg}) ordonnanceColors(OrdonnanceStatut s) {
  switch (s) {
    case OrdonnanceStatut.active:
      return (fg: AppColors.success, bg: AppColors.successLight);
    case OrdonnanceStatut.expireBientot:
      return (fg: AppColors.warning, bg: AppColors.warningLight);
    case OrdonnanceStatut.terminee:
      return (fg: AppColors.textMedium, bg: AppColors.surfaceLight);
  }
}

({Color fg, Color bg}) passageColors(PassageStatut s) {
  switch (s) {
    case PassageStatut.urgence:
      return (fg: AppColors.error, bg: AppColors.errorLight);
    case PassageStatut.consultation:
      return (fg: AppColors.primary, bg: AppColors.primaryLight);
    case PassageStatut.controle:
      return (fg: AppColors.success, bg: AppColors.successLight);
    case PassageStatut.examen:
      return (fg: AppColors.warning, bg: AppColors.warningLight);
    case PassageStatut.enCours:
      return (fg: AppColors.warning, bg: AppColors.warningLight);
    case PassageStatut.termine:
      return (fg: AppColors.textMedium, bg: AppColors.surfaceLight);
  }
}

({IconData icon, Color fg, Color bg}) notifVisual(NotifType t) {
  switch (t) {
    case NotifType.examen:
      return (
      icon: Icons.science_outlined,
      fg: AppColors.success,
      bg: AppColors.successLight,
      );
    case NotifType.ordonnance:
      return (
      icon: Icons.medication_outlined,
      fg: AppColors.warning,
      bg: AppColors.warningLight,
      );
    case NotifType.admission:
      return (
      icon: Icons.local_hospital_outlined,
      fg: AppColors.primary,
      bg: AppColors.primaryLight,
      );
    case NotifType.dossier:
      return (
      icon: Icons.person_outline,
      fg: AppColors.primary,
      bg: AppColors.primaryLight,
      );
    case NotifType.securite:
      return (
      icon: Icons.shield_outlined,
      fg: AppColors.textMedium,
      bg: AppColors.surfaceLight,
      );
  }
}