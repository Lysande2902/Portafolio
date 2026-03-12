import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Fog particle component - shared across arcs
class FogParticleComponent extends PositionComponent {
  final Color fogColor;
  final double opacity;
  final int particleCount;

  FogParticleComponent({
    super.position,
    Vector2? size,
    Vector2? areaSize,
    this.fogColor = const Color(0xFFAAAAAA),
    this.opacity = 0.3,
    this.particleCount = 10,
  }) : super(size: areaSize ?? size ?? Vector2.zero());

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()..color = fogColor.withOpacity(opacity);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
  }
}
