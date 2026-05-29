import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

enum ErrorType {
  noNetwork,
  notFound,
  sessionExpired,
  scanFail,
  maintenance,
  accessDenied,
}

class ErrorScreen extends StatelessWidget {
  final ErrorType type;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  const ErrorScreen({
    super.key,
    required this.type,
    this.onPrimary,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(type);
    final isDark = config['dark'] as bool;
    final accent = config['accent'] as Color;
    final accentSoft = config['accentSoft'] as Color;
    final fg = isDark ? Colors.white : AppColors.textDark;
    final subFg = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : AppColors.textMedium;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const RadialGradient(
            center: Alignment(0, -0.4),
            radius: 0.8,
            colors: [Color(0xFF1a1f3a), Color(0xFF0B1220)],
          )
              : RadialGradient(
            center: const Alignment(0, -0.4),
            radius: 0.8,
            colors: [
              Color(accent.toARGB32()),
              AppColors.backgroundWhite,
            ],
            stops: const [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 54, 24, 32),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.chevron_left, color: fg, size: 28),
                    ),
                    if (config['code'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          config['code'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: subFg,
                            fontFamily: 'monospace',
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    const SizedBox(width: 28),
                  ],
                ),

                // Icône centrale
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Halo
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : accentSoft,
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.18)
                                      : accent.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                            // Anneau pointillé
                            CustomPaint(
                              size: const Size(164, 164),
                              painter: _DashedCirclePainter(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : accent.withValues(alpha: 0.2),
                              ),
                            ),
                            // Mark
                            config['mark'] as Widget,
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        config['title'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(
                          config['message'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: subFg,
                            height: 1.5,
                          ),
                        ),
                      ),

                      if (config['meta'] != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            config['meta'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: subFg,
                              fontFamily: 'monospace',
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Boutons
                Column(
                  children: [
                    if (config['primaryLabel'] != null)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: onPrimary ?? () => Navigator.pop(context),
                          child: Text(config['primaryLabel'] as String),
                        ),
                      ),
                    if (config['secondaryLabel'] != null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: isDark
                            ? TextButton(
                          onPressed: onSecondary,
                          child: Text(
                            config['secondaryLabel'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                            : OutlinedButton(
                          onPressed: onSecondary,
                          child: Text(
                              config['secondaryLabel'] as String),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getConfig(ErrorType type) {
    switch (type) {
      case ErrorType.noNetwork:
        return {
          'dark': false,
          'accent': const Color(0xFFB45309),
          'accentSoft': const Color(0xFFFEF3C7),
          'mark': const CsnMarkPulseFlat(
              size: 130, c1: Color(0xFFB45309), c2: Colors.white),
          'code': 'NETWORK_UNREACHABLE',
          'title': 'Connexion impossible',
          'message': "L'application ne parvient pas à joindre le serveur. "
              "Vérifiez votre connexion Wi-Fi ou contactez le service "
              "informatique de l'hôpital.",
          'meta': 'API · 192.168.1.10:5000 · timeout 10 s',
          'primaryLabel': 'Réessayer',
          'secondaryLabel': 'Mode hors-ligne',
        };

      case ErrorType.notFound:
        return {
          'dark': false,
          'accent': const Color(0xFF1A73E8),
          'accentSoft': const Color(0xFFE8F0FE),
          'mark': const CsnMarkPulseBroken(
              size: 130, c1: Color(0xFF1A73E8), c2: Colors.white),
          'code': '404 · NOT_FOUND',
          'title': 'Page introuvable',
          'message': "La page ou la ressource demandée n'existe plus, ou "
              "vous n'y avez plus accès. Vérifiez le lien ou retournez "
              "à l'accueil.",
          'meta': 'GET /api/v1/passages/9e2a··· → 404',
          'primaryLabel': "Retour à l'accueil",
          'secondaryLabel': 'Signaler le problème',
        };

      case ErrorType.sessionExpired:
        return {
          'dark': false,
          'accent': const Color(0xFFB45309),
          'accentSoft': const Color(0xFFFEF3C7),
          'mark': const CsnMarkPulse(
              size: 130, c1: Color(0xFFB45309), c2: Colors.white),
          'code': 'JWT_EXPIRED',
          'title': 'Session expirée',
          'message': 'Votre session sécurisée a expiré pour protéger vos '
              'données. Veuillez vous reconnecter pour continuer.',
          'meta': 'Dernière activité · il y a 8 h',
          'primaryLabel': 'Se reconnecter',
          'secondaryLabel': 'Fermer',
        };

      case ErrorType.scanFail:
        return {
          'dark': false,
          'accent': const Color(0xFFB3261E),
          'accentSoft': const Color(0xFFFCE8E6),
          'mark': const CsnMarkPulseScanFail(
              size: 140, c1: Color(0xFFB3261E), c2: Colors.white),
          'code': 'QR_INVALID',
          'title': 'Carte non reconnue',
          'message': 'Ce QR code est invalide, expiré ou ne correspond à '
              'aucun patient enregistré dans le système. Saisissez le nom '
              'du patient manuellement ou demandez une nouvelle carte.',
          'meta': 'Token QR · TKN-···K7-A2-INVALID',
          'primaryLabel': 'Recherche manuelle',
          'secondaryLabel': 'Créer un dossier',
        };

      case ErrorType.maintenance:
        return {
          'dark': true,
          'accent': const Color(0xFF1A73E8),
          'accentSoft': const Color(0xFFE8F0FE),
          'mark': const CsnMarkPulse(
              size: 130, c1: Color(0xFF1A73E8), c2: Colors.white),
          'code': 'SERVICE_UNAVAILABLE · 503',
          'title': 'Maintenance en cours',
          'message': "Le système est temporairement indisponible pour mise "
              "à jour. L'API sera rétablie d'ici quelques minutes. "
              "Merci pour votre patience.",
          'meta': 'ETA · 14:30 · suivi sur status.ucac.cm',
          'primaryLabel': 'Actualiser',
          'secondaryLabel': "Voir l'état des services",
        };

      case ErrorType.accessDenied:
        return {
          'dark': false,
          'accent': const Color(0xFFB3261E),
          'accentSoft': const Color(0xFFFCE8E6),
          'mark': const CsnMarkPulseLock(
              size: 130, c1: Color(0xFFB3261E), c2: Colors.white),
          'code': '403 · ACCESS_DENIED',
          'title': 'Accès refusé',
          'message': "Votre rôle ne dispose pas des permissions nécessaires "
              "pour consulter ou modifier cette ressource. Contactez votre "
              "administrateur si vous pensez qu'il s'agit d'une erreur.",
          'meta': 'Action · MODIF_DIAGNOSTIC · rôle infirmier',
          'primaryLabel': 'Retour',
          'secondaryLabel': "Demander l'accès",
        };
    }
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dashCount = 24;
    const gapRatio = 0.4;
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final circumference = 2 * 3.14159 * radius;
    final dashLen = circumference / dashCount * (1 - gapRatio);
    final gapLen = circumference / dashCount * gapRatio;

    double angle = 0;
    while (angle < 2 * 3.14159) {
      final sweepAngle = dashLen / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        sweepAngle,
        false,
        paint,
      );
      angle += sweepAngle + gapLen / radius;
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}