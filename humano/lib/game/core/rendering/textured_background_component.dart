import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;

/// Background component with improved procedural texture
class TexturedBackgroundComponent extends PositionComponent {
  final String textureType;
  final Color baseColor;
  final int seed;
  
  TexturedBackgroundComponent({
    required Vector2 position,
    required Vector2 size,
    required this.textureType,
    required this.baseColor,
    required this.seed,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw base color
    paint.color = baseColor;
    canvas.drawRect(rect, paint);
    
    // Add texture based on type
    switch (textureType) {
      case 'concrete':
        _drawConcreteTexture(canvas, rect);
        break;
      case 'metal':
        _drawMetalTexture(canvas, rect);
        break;
      case 'wood':
        _drawWoodTexture(canvas, rect);
        break;
      case 'brick':
        _drawBrickTexture(canvas, rect);
        break;
      default:
        _drawGenericTexture(canvas, rect);
    }
  }
  
  /// Draw concrete floor texture with cracks and stains
  void _drawConcreteTexture(Canvas canvas, Rect rect) {
    final random = Random(seed);
    final paint = Paint();
    
    // Concrete cracks
    paint.color = _darken(baseColor, 0.2).withOpacity(0.6);
    paint.strokeWidth = 1.5;
    paint.style = PaintingStyle.stroke;
    
    for (int i = 0; i < 30; i++) {
      final startX = rect.left + random.nextDouble() * rect.width;
      final startY = rect.top + random.nextDouble() * rect.height;
      final length = 20 + random.nextDouble() * 80;
      final angle = random.nextDouble() * 2 * pi;
      
      final endX = startX + cos(angle) * length;
      final endY = startY + sin(angle) * length;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
    
    // Concrete stains/dirt
    paint.style = PaintingStyle.fill;
    paint.color = _darken(baseColor, 0.15).withOpacity(0.3);
    
    for (int i = 0; i < 100; i++) {
      final x = rect.left + random.nextDouble() * rect.width;
      final y = rect.top + random.nextDouble() * rect.height;
      final radius = 5 + random.nextDouble() * 20;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
    
    // Tile lines (subtle grid)
    paint.color = _darken(baseColor, 0.1).withOpacity(0.4);
    paint.strokeWidth = 1.0;
    paint.style = PaintingStyle.stroke;
    
    final tileSize = 200.0;
    
    // Vertical lines
    for (double x = rect.left; x < rect.right; x += tileSize) {
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x, rect.bottom),
        paint,
      );
    }
    
    // Horizontal lines
    for (double y = rect.top; y < rect.bottom; y += tileSize) {
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        paint,
      );
    }
  }
  
  /// Draw metal floor texture with panels and rivets
  void _drawMetalTexture(Canvas canvas, Rect rect) {
    final random = Random(seed);
    final paint = Paint();
    
    // Metal panels with rivets
    final panelWidth = 300.0;
    final panelHeight = 300.0;
    
    paint.color = _darken(baseColor, 0.1);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    
    // Draw panel grid
    for (double x = rect.left; x < rect.right; x += panelWidth) {
      for (double y = rect.top; y < rect.bottom; y += panelHeight) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, panelWidth, panelHeight),
          paint,
        );
      }
    }
    
    // Rivets at panel corners
    paint.style = PaintingStyle.fill;
    paint.color = _darken(baseColor, 0.3);
    
    for (double x = rect.left; x < rect.right; x += panelWidth) {
      for (double y = rect.top; y < rect.bottom; y += panelHeight) {
        canvas.drawCircle(Offset(x + 10, y + 10), 3, paint);
        canvas.drawCircle(Offset(x + panelWidth - 10, y + 10), 3, paint);
        canvas.drawCircle(Offset(x + 10, y + panelHeight - 10), 3, paint);
        canvas.drawCircle(Offset(x + panelWidth - 10, y + panelHeight - 10), 3, paint);
      }
    }
    
    // Metallic shine streaks
    paint.color = _lighten(baseColor, 0.1).withOpacity(0.2);
    paint.strokeWidth = 1.0;
    paint.style = PaintingStyle.stroke;
    
    for (int i = 0; i < 50; i++) {
      final x = rect.left + random.nextDouble() * rect.width;
      final y = rect.top + random.nextDouble() * rect.height;
      final length = 30 + random.nextDouble() * 50;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + length, y),
        paint,
      );
    }
    
    // Scratches and wear
    paint.color = _darken(baseColor, 0.2).withOpacity(0.4);
    for (int i = 0; i < 40; i++) {
      final x1 = rect.left + random.nextDouble() * rect.width;
      final y1 = rect.top + random.nextDouble() * rect.height;
      final x2 = x1 + random.nextDouble() * 40 - 20;
      final y2 = y1 + random.nextDouble() * 40 - 20;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }
  
  /// Draw wood floor texture with planks and grain
  void _drawWoodTexture(Canvas canvas, Rect rect) {
    final random = Random(seed);
    final paint = Paint();
    
    // Wood planks (horizontal)
    final plankHeight = 80.0;
    
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    
    for (double y = rect.top; y < rect.bottom; y += plankHeight) {
      // Plank separator
      paint.color = _darken(baseColor, 0.3);
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        paint,
      );
      
      // Wood grain lines
      paint.color = _darken(baseColor, 0.15).withOpacity(0.6);
      paint.strokeWidth = 1.0;
      
      for (int i = 0; i < 5; i++) {
        final grainY = y + random.nextDouble() * plankHeight;
        canvas.drawLine(
          Offset(rect.left, grainY),
          Offset(rect.right, grainY),
          paint,
        );
      }
    }
    
    // Knots and imperfections
    paint.style = PaintingStyle.fill;
    paint.color = _darken(baseColor, 0.25).withOpacity(0.5);
    
    for (int i = 0; i < 30; i++) {
      final x = rect.left + random.nextDouble() * rect.width;
      final y = rect.top + random.nextDouble() * rect.height;
      final radius = 3 + random.nextDouble() * 8;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  /// Draw brick wall texture
  void _drawBrickTexture(Canvas canvas, Rect rect) {
    final paint = Paint();
    
    final brickWidth = 120.0;
    final brickHeight = 60.0;
    final mortarThickness = 4.0;
    
    paint.style = PaintingStyle.fill;
    
    int rowIndex = 0;
    for (double y = rect.top; y < rect.bottom; y += brickHeight + mortarThickness) {
      final offset = (rowIndex % 2 == 0) ? 0.0 : brickWidth / 2;
      
      for (double x = rect.left - brickWidth; x < rect.right + brickWidth; x += brickWidth + mortarThickness) {
        final brickX = x + offset;
        
        // Draw brick
        paint.color = baseColor;
        canvas.drawRect(
          Rect.fromLTWH(brickX, y, brickWidth, brickHeight),
          paint,
        );
        
        // Brick border
        paint.color = _darken(baseColor, 0.2);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.0;
        canvas.drawRect(
          Rect.fromLTWH(brickX, y, brickWidth, brickHeight),
          paint,
        );
        paint.style = PaintingStyle.fill;
      }
      
      rowIndex++;
    }
  }
  
  /// Draw generic noise texture
  void _drawGenericTexture(Canvas canvas, Rect rect) {
    final random = Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Random noise
    for (int i = 0; i < 200; i++) {
      final x = rect.left + random.nextDouble() * rect.width;
      final y = rect.top + random.nextDouble() * rect.height;
      final brightness = random.nextDouble() * 0.2 - 0.1;
      
      paint.color = brightness > 0 
          ? _lighten(baseColor, brightness)
          : _darken(baseColor, -brightness);
      
      canvas.drawCircle(Offset(x, y), 2, paint);
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
