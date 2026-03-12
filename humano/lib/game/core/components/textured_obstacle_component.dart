import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Obstacle with procedural texture and WORKING collision
class TexturedObstacleComponent extends PositionComponent with CollisionCallbacks {
  final String textureType;
  final Color baseColor;
  final int seed;
  
  TexturedObstacleComponent({
    required Vector2 position,
    required Vector2 size,
    required this.textureType,
    required this.baseColor,
    required this.seed,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.topLeft, // CRITICAL: Anchor must be topLeft for correct positioning
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add visual component with texture
    add(_TexturedRectangle(
      size: size,
      textureType: textureType,
      baseColor: baseColor,
      seed: seed,
    ));
    
    // Add collision hitbox - CRITICAL for collisions to work
    // The hitbox MUST match the size exactly
    add(RectangleHitbox(
      size: size,
      position: Vector2.zero(),
      anchor: Anchor.topLeft,
    ));
    
    debugPrint('🔲 [OBSTACLE] Created $textureType at $position, size: $size, hitbox: $size');
  }
}

/// Internal component that renders the textured rectangle
class _TexturedRectangle extends PositionComponent {
  final String textureType;
  final Color baseColor;
  final int seed;
  
  _TexturedRectangle({
    required Vector2 size,
    required this.textureType,
    required this.baseColor,
    required this.seed,
  }) : super(size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    
    // Draw base color
    paint.color = baseColor;
    canvas.drawRect(rect, paint);
    
    // Add texture based on type
    switch (textureType) {
      case 'crate':
        _drawCrateTexture(canvas, rect);
        break;
      case 'vault':
        _drawVaultTexture(canvas, rect);
        break;
      default:
        _drawGenericTexture(canvas, rect);
    }
    
    // Add border for definition
    paint
      ..color = _darken(baseColor, 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(rect, paint);
  }
  
  /// Draw wooden crate texture
  void _drawCrateTexture(Canvas canvas, Rect rect) {
    final random = Random(seed);
    final paint = Paint();
    
    // Wood grain lines (horizontal)
    paint.color = _darken(baseColor, 0.15);
    paint.strokeWidth = 1.5;
    
    for (int i = 0; i < 8; i++) {
      final y = rect.top + (rect.height / 8) * i + random.nextDouble() * 5;
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        paint,
      );
    }
    
    // Vertical planks
    paint.color = _darken(baseColor, 0.2);
    paint.strokeWidth = 2.0;
    
    final plankWidth = rect.width / 3;
    for (int i = 1; i < 3; i++) {
      final x = rect.left + plankWidth * i;
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x, rect.bottom),
        paint,
      );
    }
    
    // Nails/screws at corners
    paint.color = const Color(0xFF1a1a1a);
    paint.style = PaintingStyle.fill;
    
    final nailSize = 4.0;
    final positions = [
      Offset(rect.left + 10, rect.top + 10),
      Offset(rect.right - 10, rect.top + 10),
      Offset(rect.left + 10, rect.bottom - 10),
      Offset(rect.right - 10, rect.bottom - 10),
    ];
    
    for (final pos in positions) {
      canvas.drawCircle(pos, nailSize, paint);
    }
    
    // Add some dirt/wear spots
    paint.color = _darken(baseColor, 0.25).withOpacity(0.3);
    for (int i = 0; i < 5; i++) {
      final x = rect.left + random.nextDouble() * rect.width;
      final y = rect.top + random.nextDouble() * rect.height;
      final radius = 3 + random.nextDouble() * 5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  /// Draw metal vault texture
  void _drawVaultTexture(Canvas canvas, Rect rect) {
    final random = Random(seed);
    final paint = Paint();
    
    // Metallic shine effect (diagonal lines)
    paint.color = _lighten(baseColor, 0.1).withOpacity(0.3);
    paint.strokeWidth = 1.0;
    
    for (int i = 0; i < 15; i++) {
      final offset = i * 10.0;
      canvas.drawLine(
        Offset(rect.left + offset, rect.top),
        Offset(rect.left, rect.top + offset),
        paint,
      );
    }
    
    // Rivets around the edges
    paint.color = _darken(baseColor, 0.3);
    paint.style = PaintingStyle.fill;
    
    final rivetSize = 3.0;
    final spacing = 20.0;
    
    // Top rivets
    for (double x = rect.left + spacing; x < rect.right; x += spacing) {
      canvas.drawCircle(Offset(x, rect.top + 8), rivetSize, paint);
    }
    
    // Bottom rivets
    for (double x = rect.left + spacing; x < rect.right; x += spacing) {
      canvas.drawCircle(Offset(x, rect.bottom - 8), rivetSize, paint);
    }
    
    // Left rivets
    for (double y = rect.top + spacing; y < rect.bottom; y += spacing) {
      canvas.drawCircle(Offset(rect.left + 8, y), rivetSize, paint);
    }
    
    // Right rivets
    for (double y = rect.top + spacing; y < rect.bottom; y += spacing) {
      canvas.drawCircle(Offset(rect.right - 8, y), rivetSize, paint);
    }
    
    // Central lock mechanism (if large enough)
    if (rect.width > 100 && rect.height > 100) {
      final centerX = rect.left + rect.width / 2;
      final centerY = rect.top + rect.height / 2;
      
      // Lock circle
      paint.color = _darken(baseColor, 0.4);
      canvas.drawCircle(Offset(centerX, centerY), 15, paint);
      
      // Lock highlight
      paint.color = _lighten(baseColor, 0.2);
      canvas.drawCircle(Offset(centerX - 3, centerY - 3), 12, paint);
      
      // Keyhole
      paint.color = const Color(0xFF000000);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: 4,
          height: 8,
        ),
        paint,
      );
    }
    
    // Scratches and wear
    paint.color = _darken(baseColor, 0.2).withOpacity(0.4);
    paint.strokeWidth = 1.0;
    for (int i = 0; i < 8; i++) {
      final x1 = rect.left + random.nextDouble() * rect.width;
      final y1 = rect.top + random.nextDouble() * rect.height;
      final x2 = x1 + random.nextDouble() * 20 - 10;
      final y2 = y1 + random.nextDouble() * 20 - 10;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }
  
  /// Draw generic texture (fallback)
  void _drawGenericTexture(Canvas canvas, Rect rect) {
    final random = Random(seed);
    final paint = Paint();
    
    // Simple noise pattern
    paint.color = _darken(baseColor, 0.1).withOpacity(0.5);
    for (int i = 0; i < 50; i++) {
      final x = rect.left + random.nextDouble() * rect.width;
      final y = rect.top + random.nextDouble() * rect.height;
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }
  
  /// Darken a color by a factor (0.0 to 1.0)
  Color _darken(Color color, double factor) {
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - factor)).round().clamp(0, 255),
      (color.green * (1 - factor)).round().clamp(0, 255),
      (color.blue * (1 - factor)).round().clamp(0, 255),
    );
  }
  
  /// Lighten a color by a factor (0.0 to 1.0)
  Color _lighten(Color color, double factor) {
    return Color.fromARGB(
      color.alpha,
      (color.red + (255 - color.red) * factor).round().clamp(0, 255),
      (color.green + (255 - color.green) * factor).round().clamp(0, 255),
      (color.blue + (255 - color.blue) * factor).round().clamp(0, 255),
    );
  }
}
