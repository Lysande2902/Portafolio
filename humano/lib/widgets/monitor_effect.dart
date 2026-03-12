import 'dart:math';
import 'package:flutter/material.dart';

class MonitorEffect extends StatefulWidget {
  final Widget child;
  final double noiseIntensity;
  final bool showScanlines;

  const MonitorEffect({
    super.key,
    required this.child,
    this.noiseIntensity = 0.05,
    this.showScanlines = true,
  });

  @override
  State<MonitorEffect> createState() => _MonitorEffectState();
}

class _MonitorEffectState extends State<MonitorEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _MonitorPainter(
            animationValue: _controller.value,
            noiseIntensity: widget.noiseIntensity,
            showScanlines: widget.showScanlines,
          ),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

class _MonitorPainter extends CustomPainter {
  final double animationValue;
  final double noiseIntensity;
  final bool showScanlines;

  _MonitorPainter({
    required this.animationValue,
    required this.noiseIntensity,
    required this.showScanlines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random((animationValue * 1000).toInt());
    final paint = Paint();

    // 1. Grano de película (Noise)
    for (int i = 0; i < 1500; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      paint.color = Colors.white.withOpacity(rand.nextDouble() * noiseIntensity);
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }

    // 2. Scanlines
    if (showScanlines) {
      paint.color = Colors.black.withOpacity(0.05);
      paint.strokeWidth = 1.0;
      for (double i = 0; i < size.height; i += 3) {
        canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
      }
    }

    // 3. Flicker sutil
    if (rand.nextDouble() < 0.02) {
      paint.color = Colors.white.withOpacity(0.01);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_MonitorPainter oldDelegate) => true;
}
