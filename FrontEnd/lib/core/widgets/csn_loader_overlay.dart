import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Affiche un overlay de chargement par-dessus n'importe quel écran.
///
/// Usage :
/// ```dart
/// CsnLoaderOverlay.show(context, message: 'Connexion...');
/// await monAppelApi();
/// CsnLoaderOverlay.hide(context);
/// ```
class CsnLoaderOverlay {
  static OverlayEntry? _entry;

  static void show(
      BuildContext context, {
        String message = 'Chargement…',
      }) {
    hide(context); // sécurité : évite les doublons

    _entry = OverlayEntry(
      builder: (_) => _LoaderOverlayWidget(message: message),
    );

    Overlay.of(context).insert(_entry!);
  }

  static void hide(BuildContext context) {
    _entry?.remove();
    _entry = null;
  }
}

class _LoaderOverlayWidget extends StatefulWidget {
  final String message;
  const _LoaderOverlayWidget({required this.message});

  @override
  State<_LoaderOverlayWidget> createState() => _LoaderOverlayWidgetState();
}

class _LoaderOverlayWidgetState extends State<_LoaderOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B3E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spinner animé avec la croix Pulse
                _PulseSpinner(),
                const SizedBox(height: 20),
                Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseSpinner extends StatefulWidget {
  @override
  State<_PulseSpinner> createState() => _PulseSpinnerState();
}

class _PulseSpinnerState extends State<_PulseSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anneau rotatif
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Transform.rotate(
              angle: _controller.value * 2 * 3.14159,
              child: CustomPaint(
                size: const Size(64, 64),
                painter: _SpinnerRingPainter(),
              ),
            ),
          ),
          // Croix Pulse fixe au centre
          CustomPaint(
            size: const Size(36, 36),
            painter: _MiniPulsePainter(),
          ),
        ],
      ),
    );
  }
}

class _SpinnerRingPainter extends CustomPainter {
  const _SpinnerRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Arc de fond
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * 3.14159,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Arc animé bleu
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      3.14159 * 1.2,
      false,
      Paint()
        ..color = const Color(0xFF1A73E8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpinnerRingPainter old) => false;
}

class _MiniPulsePainter extends CustomPainter {
  const _MiniPulsePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    final paint = Paint()..color = Colors.white;

    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(39*s, 6*s, 22*s, 88*s),
        Radius.circular(5*s)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(6*s, 39*s, 88*s, 22*s),
        Radius.circular(5*s)), paint);

    const pts = [[11,50],[27,50],[33,50],[39,38],[47,64],[55,36],[63,50],[89,50]];
    final path = Path();
    path.moveTo(pts[0][0]*s, pts[0][1]*s);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i][0]*s, pts[i][1]*s);
    }
    canvas.drawPath(path, Paint()
      ..color = const Color(0xFF1A73E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6*s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(_MiniPulsePainter old) => false;
}