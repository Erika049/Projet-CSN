import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<void> main() async {
  // Taille 1024x1024 pour l'icône
  const size = 1024.0;

  final recorder = ui.PictureRecorder();
  final canvas   = Canvas(recorder);

  // Fond bleu
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size, size),
    Paint()..color = const Color(0xFF0B3D91),
  );

  // Dessiner le logo CsnMarkPulse centré
  final s = size / 100;
  final paint = Paint()..color = Colors.white;

  // Bras vertical
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(39*s, 6*s, 22*s, 88*s),
      Radius.circular(5*s),
    ),
    paint,
  );

  // Bras horizontal
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(6*s, 39*s, 88*s, 22*s),
      Radius.circular(5*s),
    ),
    paint,
  );

  // Tracé ECG
  final ecgPaint = Paint()
    ..color = const Color(0xFF1A73E8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.6 * s
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final path = Path();
  final pts = [
    [11,50],[27,50],[33,50],[39,38],
    [47,64],[55,36],[63,50],[89,50],
  ];
  path.moveTo(pts[0][0]*s, pts[0][1].toDouble()*s);
  for (int i = 1; i < pts.length; i++) {
    path.lineTo(pts[i][0]*s, pts[i][1].toDouble()*s);
  }
  canvas.drawPath(path, ecgPaint);

  final picture = recorder.endRecording();
  final img = await picture.toImage(
      size.toInt(), size.toInt());
  final data = await img.toByteData(
      format: ui.ImageByteFormat.png);

  File('assets/icons/app_icon.png')
      .writeAsBytesSync(
      data!.buffer.asUint8List());

  print('✅ app_icon.png généré !');
}