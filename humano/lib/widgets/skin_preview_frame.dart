import 'package:flutter/material.dart';

/// Marco decorativo simple para preview de skins
class SkinPreviewFrame extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final bool isSelected;

  const SkinPreviewFrame({
    super.key,
    required this.child,
    this.width = 200,
    this.height = 280,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FramePainter(isSelected: isSelected),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  final bool isSelected;

  _FramePainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final wineRed = const Color(0xFF8B0000);
    final lightRed = const Color(0xFFE57373);
    final glowColor = isSelected ? lightRed : wineRed;

    // Borde exterior
    final outerPaint = Paint()
      ..color = glowColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    canvas.drawRRect(outerRect, outerPaint);

    // Borde interior
    final innerPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
      const Radius.circular(10),
    );
    canvas.drawRRect(innerRect, innerPaint);

    // Esquinas decorativas
    _drawCornerDecoration(canvas, 8, 8, glowColor, true, true);
    _drawCornerDecoration(canvas, size.width - 8, 8, glowColor, false, true);
    _drawCornerDecoration(canvas, 8, size.height - 8, glowColor, true, false);
    _drawCornerDecoration(canvas, size.width - 8, size.height - 8, glowColor, false, false);

    // Efecto de brillo si está seleccionado
    if (isSelected) {
      final glowPaint = Paint()
        ..color = lightRed.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawRRect(outerRect, glowPaint);
    }
  }

  void _drawCornerDecoration(Canvas canvas, double x, double y, Color color, bool isLeft, bool isTop) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final length = 12.0;
    
    // Línea horizontal
    final hStart = isLeft ? x : x - length;
    final hEnd = isLeft ? x + length : x;
    canvas.drawLine(Offset(hStart, y), Offset(hEnd, y), paint);

    // Línea vertical
    final vStart = isTop ? y : y - length;
    final vEnd = isTop ? y + length : y;
    canvas.drawLine(Offset(x, vStart), Offset(x, vEnd), paint);
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) {
    return oldDelegate.isSelected != isSelected;
  }
}
