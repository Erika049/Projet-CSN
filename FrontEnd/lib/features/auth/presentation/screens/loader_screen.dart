import 'package:flutter/material.dart';

class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key});

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with TickerProviderStateMixin {
  late AnimationController _beatController;
  late AnimationController _traceController;
  late Animation<double> _beatAnimation;
  late Animation<double> _traceAnimation;

  @override
  void initState() {
    super.initState();

    _beatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _traceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _beatAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 0.98), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.98, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _beatController,
      curve: Curves.easeInOut,
    ));

    _traceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _traceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _beatController.dispose();
    _traceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07112A), Color(0xFF0B1A3D)],
          ),
        ),
        child: Stack(
          children: [
            // Radial bleu centré
            Positioned.fill(
              child: Align(
                alignment: const Alignment(0, -0.3),
                child: Container(
                  width: 400,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF1A73E8).withValues(alpha: 0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Radial bas
            Positioned(
              left: 0,
              right: 0,
              bottom: -100,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0B3D91).withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'UCAC · ICAM',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0x8CFFFFFF),
                      letterSpacing: 2,
                    ),
                  ),

                  const Spacer(),

                  // Logo animé
                  ScaleTransition(
                    scale: _beatAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF1A73E8).withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 152,
                          height: 152,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _traceAnimation,
                          builder: (context, _) => SizedBox(
                            width: 120,
                            height: 120,
                            child: CustomPaint(
                              painter: _AnimatedPulsePainter(
                                progress: _traceAnimation.value,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Carnet',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.8,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'DE SANTÉ NUMÉRIQUE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xB3FFFFFF),
                      letterSpacing: 2.4,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const _AnimatedDots(),

                  const Spacer(),

                  const Text(
                    'Synchronisation du dossier médical…',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0x73FFFFFF),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'v1.0.0 · API 192.168.1.10:5000',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0x73FFFFFF),
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      );
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) { c.repeat(); }
      });
      return c;
    });

    _animations = _controllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: c, curve: Curves.easeInOut),
    ))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, _) {
            final t = _animations[i].value;
            final y = t < 0.4
                ? -4.0 * (t / 0.4)
                : t < 0.8
                ? -4.0 + 4.0 * ((t - 0.4) / 0.4)
                : 0.0;
            final opacity = t < 0.4
                ? 0.35 + 0.65 * (t / 0.4)
                : t < 0.8
                ? 1.0 - 0.65 * ((t - 0.4) / 0.4)
                : 0.35;
            return Transform.translate(
              offset: Offset(0, y),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _AnimatedPulsePainter extends CustomPainter {
  final double progress;
  const _AnimatedPulsePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;

    // Croix blanche
    final paint = Paint()..color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(39*s, 6*s, 22*s, 88*s),
        Radius.circular(5*s)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(6*s, 39*s, 88*s, 22*s),
        Radius.circular(5*s)), paint);

    // ECG statique atténué
    const pts = [[11,50],[27,50],[33,50],[39,38],[47,64],[55,36],[63,50],[89,50]];
    final staticPath = Path();
    staticPath.moveTo(pts[0][0]*s, pts[0][1]*s);
    for (int i = 1; i < pts.length; i++) {
      staticPath.lineTo(pts[i][0]*s, pts[i][1]*s);
    }
    canvas.drawPath(staticPath, Paint()
      ..color = const Color(0xFF1A73E8).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6*s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // ECG animé vert — on dessine jusqu'à progress
    final totalLen = _totalLength(pts, s);
    final drawLen = totalLen * progress;
    final animPath = _subPath(pts, s, drawLen);
    canvas.drawPath(animPath, Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6*s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);
  }

  double _totalLength(List<List<int>> pts, double s) {
    double total = 0;
    for (int i = 1; i < pts.length; i++) {
      final dx = (pts[i][0] - pts[i-1][0]) * s;
      final dy = (pts[i][1] - pts[i-1][1]) * s;
      total += _sqrt(dx*dx + dy*dy);
    }
    return total;
  }

  Path _subPath(List<List<int>> pts, double s, double maxLen) {
    final path = Path();
    path.moveTo(pts[0][0]*s, pts[0][1]*s);
    double accumulated = 0;
    for (int i = 1; i < pts.length; i++) {
      final dx = (pts[i][0] - pts[i-1][0]) * s;
      final dy = (pts[i][1] - pts[i-1][1]) * s;
      final segLen = _sqrt(dx*dx + dy*dy);
      if (accumulated + segLen >= maxLen) {
        final ratio = (maxLen - accumulated) / segLen;
        path.lineTo(
          pts[i-1][0]*s + dx * ratio,
          pts[i-1][1]*s + dy * ratio,
        );
        break;
      }
      path.lineTo(pts[i][0]*s, pts[i][1]*s);
      accumulated += segLen;
    }
    return path;
  }

  double _sqrt(double x) {
    if (x <= 0) { return 0; }
    double r = x;
    for (int i = 0; i < 20; i++) { r = (r + x / r) / 2; }
    return r;
  }

  @override
  bool shouldRepaint(_AnimatedPulsePainter old) => old.progress != progress;
}