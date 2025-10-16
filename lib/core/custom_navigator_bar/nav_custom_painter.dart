
import 'package:flutter/material.dart';

class NavCustomPainter extends CustomPainter {
  late double loc;
  late double s;
  Color color;
  TextDirection textDirection;
  final double curveDepth;

  NavCustomPainter(
      double startingLoc,
      int itemsLength,
      this.color,
      this.textDirection,
      {this.curveDepth = 0.40}) {
    final span = 1.0 / itemsLength;
    s = 0.15;  // ✅ AJUSTE: Reduce de 0.2 a 0.15 para curva más estrecha (prueba 0.1 si quieres aún más delgada)
    double l = startingLoc + (span - s) / 2;
    loc = textDirection == TextDirection.rtl ? 0.8 - l : l;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;  // ✅ Mantiene suavizado

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo((loc - 0.1) * size.width, 0)
      ..cubicTo(
        (loc + s * 0.20) * size.width,  // ✅ AJUSTE: Escala con el nuevo 's' para mantener proporción
        size.height * 0.05,
        loc * size.width,
        size.height * curveDepth,
        (loc + s * 0.50) * size.width,
        size.height * curveDepth,
      )
      ..cubicTo(
        (loc + s) * size.width,  // ✅ AJUSTE: Escala con el nuevo 's'
        size.height * curveDepth,
        (loc + s - s * 0.20) * size.width,
        size.height * 0.05,
        (loc + s + 0.1) * size.width,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}

