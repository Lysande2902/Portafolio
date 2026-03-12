import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Broken mirror shard component with realistic glass effect
class BrokenMirrorComponent extends PositionComponent {
  final bool isOnWall;
  Sprite? _floorSprite;
  bool _isLoaded = false;
  
  BrokenMirrorComponent({
    required Vector2 position,
    required Vector2 size,
    this.isOnWall = false,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load floor texture to create reflection effect
    _floorSprite = await Sprite.load('Floor_gym.jpg');
    _isLoaded = true;
  }

  @override
  void render(Canvas canvas) {
    if (!_isLoaded || _floorSprite == null) return;
    
    // Draw reflected floor texture (lighter, with cyan tint)
    final reflectionPaint = Paint()
      ..colorFilter = ColorFilter.mode(
        const Color(0xFF88CCDD).withOpacity(0.4),
        BlendMode.modulate,
      );
    
    _floorSprite!.render(
      canvas,
      size: size,
      overridePaint: reflectionPaint,
    );

    // Draw glass shard shape (irregular polygon)
    final shardPath = Path();
    shardPath.moveTo(size.x * 0.1, size.y * 0.2);
    shardPath.lineTo(size.x * 0.7, size.y * 0.1);
    shardPath.lineTo(size.x * 0.9, size.y * 0.6);
    shardPath.lineTo(size.x * 0.4, size.y * 0.9);
    shardPath.lineTo(size.x * 0.05, size.y * 0.5);
    shardPath.close();
    
    // Glass fill (semi-transparent white)
    final glassPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shardPath, glassPaint);
    
    // Glass edge (cyan glow)
    final edgePaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(shardPath, edgePaint);
    
    // Add some glimmer points
    final glimmerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.3), 1.5, glimmerPaint);
    canvas.drawCircle(Offset(size.x * 0.6, size.y * 0.5), 1.0, glimmerPaint);
    canvas.drawCircle(Offset(size.x * 0.4, size.y * 0.7), 1.2, glimmerPaint);
  }
}
