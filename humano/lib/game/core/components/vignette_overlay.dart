import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Vignette overlay component - shared across arcs
class VignetteOverlay extends PositionComponent {
  final double intensity;

  VignetteOverlay({
    required Vector2 size,
    this.intensity = 0.5,
  }) : super(size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(intensity),
      ],
    );
    
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }
}
