import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

/// An obstacle component that uses a specific image texture.
class ImageObstacleComponent extends PositionComponent with CollisionCallbacks {
  final String imagePath;
  final Color? blendColor;
  
  late Sprite _sprite;
  bool _isLoaded = false;

  ImageObstacleComponent({
    required Vector2 position,
    required Vector2 size,
    required this.imagePath,
    this.blendColor,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // We use the Flame images cache for efficiency
    _sprite = await Sprite.load(imagePath);
    _isLoaded = true;
    
    // Add collision box
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    if (!_isLoaded) {
      // Fallback while loading
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Colors.grey[900]!,
      );
      return;
    }

    final paint = Paint();
    if (blendColor != null) {
      paint.colorFilter = ColorFilter.mode(blendColor!, BlendMode.srcATop);
    }

    _sprite.render(
      canvas,
      size: size,
      overridePaint: paint,
    );
  }
}
