import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// A component that renders an image tiled across a rectangular area.
/// Useful for floors and walls using a single repetitive texture.
class TiledImageBackgroundComponent extends PositionComponent {
  final String imagePath;
  final double tileWidth;
  final double tileHeight;
  final Color? blendColor;
  
  late Sprite _sprite;
  bool _isLoaded = false;

  TiledImageBackgroundComponent({
    required Vector2 position,
    required Vector2 size,
    required this.imagePath,
    this.tileWidth = 256,
    this.tileHeight = 256,
    this.blendColor,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    _sprite = await Sprite.load(imagePath);
    _isLoaded = true;
  }

  @override
  void render(Canvas canvas) {
    if (!_isLoaded) return;

    final paint = Paint();
    if (blendColor != null) {
      paint.colorFilter = ColorFilter.mode(blendColor!, BlendMode.multiply);
    }

    // Tile the image across the size
    for (double x = 0; x < size.x; x += tileWidth) {
      for (double y = 0; y < size.y; y += tileHeight) {
        final drawWidth = (x + tileWidth > size.x) ? size.x - x : tileWidth;
        final drawHeight = (y + tileHeight > size.y) ? size.y - y : tileHeight;
        
        _sprite.render(
          canvas,
          position: Vector2(x, y),
          size: Vector2(drawWidth, drawHeight),
          overridePaint: paint,
        );
      }
    }
  }
}
