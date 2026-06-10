import 'package:flutter/material.dart';

/// Marque Pulse — croix médicale + tracé ECG
/// Utilisée dans le splash, loader, et pages d'erreur
class CsnMarkPulse extends StatelessWidget {
  final double size;
  final Color c1;
  final Color c2;

  const CsnMarkPulse({
    super.key,
    this.size = 100,
    this.c1 = const Color(0xFF0B3D91),
    this.c2 = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PulsePainter(c1: c1, c2: c2)),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final Color c1;
  final Color c2;
  const _PulsePainter({required this.c1, required this.c2});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    final paint = Paint()..color = c1;

    // Bras vertical
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(39 * s, 6 * s, 22 * s, 88 * s),
        Radius.circular(5 * s),
      ),
      paint,
    );

    // Bras horizontal
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6 * s, 39 * s, 88 * s, 22 * s),
        Radius.circular(5 * s),
      ),
      paint,
    );

    // Tracé ECG
    final ecgPaint = Paint()
      ..color = c2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final pts = [
      [11, 50], [27, 50], [33, 50], [39, 38],
      [47, 64], [55, 36], [63, 50], [89, 50],
    ];
    path.moveTo(pts[0][0] * s, pts[0][1] * s);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i][0] * s, pts[i][1] * s);
    }
    canvas.drawPath(path, ecgPaint);
  }

  @override
  bool shouldRepaint(_PulsePainter old) =>
      old.c1 != c1 || old.c2 != c2;
}

/// Variante Flatline — battement plat (erreur réseau)
class CsnMarkPulseFlat extends StatelessWidget {
  final double size;
  final Color c1;
  final Color c2;

  const CsnMarkPulseFlat({
    super.key,
    this.size = 120,
    this.c1 = const Color(0xFFB45309),
    this.c2 = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _FlatPainter(c1: c1, c2: c2)),
    );
  }
}

class _FlatPainter extends CustomPainter {
  final Color c1;
  final Color c2;
  const _FlatPainter({required this.c1, required this.c2});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    final paint = Paint()..color = c1;

    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(39 * s, 6 * s, 22 * s, 88 * s),
        Radius.circular(5 * s)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(6 * s, 39 * s, 88 * s, 22 * s),
        Radius.circular(5 * s)), paint);

    canvas.drawLine(
      Offset(11 * s, 50 * s),
      Offset(89 * s, 50 * s),
      Paint()
        ..color = c2
        ..strokeWidth = 3.6 * s
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_FlatPainter old) => old.c1 != c1 || old.c2 != c2;
}

/// Variante Broken — battement interrompu (404)
class CsnMarkPulseBroken extends StatelessWidget {
  final double size;
  final Color c1;
  final Color c2;

  const CsnMarkPulseBroken({
    super.key,
    this.size = 120,
    this.c1 = const Color(0xFF1A73E8),
    this.c2 = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BrokenPainter(c1: c1, c2: c2)),
    );
  }
}

class _BrokenPainter extends CustomPainter {
  final Color c1;
  final Color c2;
  const _BrokenPainter({required this.c1, required this.c2});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    final paint = Paint()..color = c1;

    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(39 * s, 6 * s, 22 * s, 88 * s),
        Radius.circular(5 * s)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(6 * s, 39 * s, 88 * s, 22 * s),
        Radius.circular(5 * s)), paint);

    final ecg = Paint()
      ..color = c2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Segment gauche
    final left = Path();
    left.moveTo(11 * s, 50 * s);
    left.lineTo(27 * s, 50 * s);
    left.lineTo(33 * s, 50 * s);
    left.lineTo(39 * s, 38 * s);
    left.lineTo(44 * s, 52 * s);
    canvas.drawPath(left, ecg);

    // Segment droit
    final right = Path();
    right.moveTo(56 * s, 48 * s);
    right.lineTo(61 * s, 50 * s);
    right.lineTo(89 * s, 50 * s);
    canvas.drawPath(right, ecg);

    // "?"
    final tp = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: c2,
          fontSize: 11 * s,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset((50 - tp.width / 2) * s, (50 - tp.height / 2) * s));
  }

  @override
  bool shouldRepaint(_BrokenPainter old) => old.c1 != c1 || old.c2 != c2;
}

/// Variante Lock — cadenas (accès refusé 403)
class CsnMarkPulseLock extends StatelessWidget {
  final double size;
  final Color c1;
  final Color c2;

  const CsnMarkPulseLock({
    super.key,
    this.size = 120,
    this.c1 = const Color(0xFFB3261E),
    this.c2 = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LockPainter(c1: c1, c2: c2)),
    );
  }
}

class _LockPainter extends CustomPainter {
  final Color c1;
  final Color c2;
  const _LockPainter({required this.c1, required this.c2});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    final paint = Paint()..color = c1;

    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(39 * s, 6 * s, 22 * s, 88 * s),
        Radius.circular(5 * s)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(6 * s, 39 * s, 88 * s, 22 * s),
        Radius.circular(5 * s)), paint);

    // ECG atténué
    final ecgFaint = Paint()
      ..color = c2.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    final pts = [[11,50],[27,50],[33,50],[39,38],[47,64],[55,36],[63,50],[89,50]];
    path.moveTo(pts[0][0]*s, pts[0][1]*s);
    for (int i=1; i<pts.length; i++) { path.lineTo(pts[i][0]*s, pts[i][1]*s); }
    canvas.drawPath(path, ecgFaint);

    // Badge cadenas (cercle)
    canvas.drawCircle(
      Offset(74 * s, 74 * s),
      16 * s,
      Paint()..color = c1,
    );
    canvas.drawCircle(
      Offset(74 * s, 74 * s),
      16 * s,
      Paint()
        ..color = c2
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * s,
    );

    // Corps cadenas
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(68 * s, 73 * s, 12 * s, 9 * s),
        Radius.circular(1.5 * s),
      ),
      Paint()..color = c2,
    );

    // Arceau
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(74 * s, 69 * s),
        width: 8 * s,
        height: 8 * s,
      ),
      3.14159,
      3.14159,
      false,
      Paint()
        ..color = c2
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * s
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_LockPainter old) => old.c1 != c1 || old.c2 != c2;
}

/// Variante ScanFail — X sur la croix (QR invalide)
class CsnMarkPulseScanFail extends StatelessWidget {
  final double size;
  final Color c1;
  final Color c2;

  const CsnMarkPulseScanFail({
    super.key,
    this.size = 120,
    this.c1 = const Color(0xFFB3261E),
    this.c2 = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ScanFailPainter(c1: c1, c2: c2)),
    );
  }
}

class _ScanFailPainter extends CustomPainter {
  final Color c1;
  final Color c2;
  const _ScanFailPainter({required this.c1, required this.c2});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    final bracket = Paint()
      ..color = c1
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * s
      ..strokeCap = StrokeCap.round;

    // Coins QR
    final paths = [
      'M4 16 V6 H14', 'M86 6 H96 V16',
      'M4 84 V94 H14', 'M86 94 H96 V84',
    ];
    for (final d in paths) {
      final p = _parsePath(d, s);
      canvas.drawPath(p, bracket);
    }

    // Croix
    final paint = Paint()..color = c1;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(39 * s, 14 * s, 22 * s, 72 * s),
        Radius.circular(5 * s)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(14 * s, 39 * s, 72 * s, 22 * s),
        Radius.circular(5 * s)), paint);

    // ECG
    final ecg = Paint()
      ..color = c2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    final pts = [[18,50],[26,50],[32,50],[38,40],[46,60],[54,40],[62,50],[82,50]];
    path.moveTo(pts[0][0]*s, pts[0][1]*s);
    for (int i=1; i<pts.length; i++) { path.lineTo(pts[i][0]*s, pts[i][1]*s); }
    canvas.drawPath(path, ecg);

    // X
    final x = Paint()
      ..color = c2
      ..strokeWidth = 5 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(34*s, 34*s), Offset(66*s, 66*s), x);
    canvas.drawLine(Offset(66*s, 34*s), Offset(34*s, 66*s), x);
  }

  Path _parsePath(String d, double s) {
    final p = Path();
    if (d == 'M4 16 V6 H14') {
      p.moveTo(4*s, 16*s); p.lineTo(4*s, 6*s); p.lineTo(14*s, 6*s);
    } else if (d == 'M86 6 H96 V16') {
      p.moveTo(86*s, 6*s); p.lineTo(96*s, 6*s); p.lineTo(96*s, 16*s);
    } else if (d == 'M4 84 V94 H14') {
      p.moveTo(4*s, 84*s); p.lineTo(4*s, 94*s); p.lineTo(14*s, 94*s);
    } else if (d == 'M86 94 H96 V84') {
      p.moveTo(86*s, 94*s); p.lineTo(96*s, 94*s); p.lineTo(96*s, 84*s);
    }
    return p;
  }

  @override
  bool shouldRepaint(_ScanFailPainter old) => old.c1 != c1 || old.c2 != c2;
}