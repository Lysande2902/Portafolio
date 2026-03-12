import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Generador de texturas procedurales para mapas
/// Crea texturas con código sin necesidad de assets
class ProceduralTexture {
  /// Genera textura de piso con ruido y suciedad
  static ui.Image? generateFloorTexture({
    required int width,
    required int height,
    required Color baseColor,
    double noiseIntensity = 0.1,
    int seed = 42,
  }) {
    final random = Random(seed);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Color base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = baseColor,
    );
    
    // Añadir ruido (suciedad)
    for (int i = 0; i < (width * height * noiseIntensity).toInt(); i++) {
      final x = random.nextDouble() * width;
      final y = random.nextDouble() * height;
      final brightness = random.nextDouble() * 0.3 - 0.15; // -0.15 a +0.15
      
      canvas.drawCircle(
        Offset(x, y),
        random.nextDouble() * 2 + 0.5,
        Paint()..color = _adjustBrightness(baseColor, brightness),
      );
    }
    
    final picture = recorder.endRecording();
    // Note: En producción, necesitarías usar picture.toImage() de forma asíncrona
    return null; // Placeholder - ver implementación completa abajo
  }
  
  /// Genera textura de pared con ladrillos
  static void drawBrickWall(
    Canvas canvas,
    Rect rect,
    Color brickColor,
    Color mortarColor,
  ) {
    final brickWidth = 80.0;
    final brickHeight = 40.0;
    final mortarThickness = 4.0;
    
    // Fondo de mortero
    canvas.drawRect(rect, Paint()..color = mortarColor);
    
    // Dibujar ladrillos
    for (double y = rect.top; y < rect.bottom; y += brickHeight + mortarThickness) {
      final isOffsetRow = ((y - rect.top) / (brickHeight + mortarThickness)).toInt() % 2 == 1;
      final startX = isOffsetRow ? rect.left - brickWidth / 2 : rect.left;
      
      for (double x = startX; x < rect.right; x += brickWidth + mortarThickness) {
        final brickRect = Rect.fromLTWH(
          x,
          y,
          brickWidth,
          brickHeight,
        );
        
        // Ladrillo base
        canvas.drawRect(brickRect, Paint()..color = brickColor);
        
        // Sombra en ladrillo
        canvas.drawRect(
          Rect.fromLTWH(x, y + brickHeight - 5, brickWidth, 5),
          Paint()..color = brickColor.withOpacity(0.7),
        );
      }
    }
  }
  
  /// Genera textura de metal oxidado
  static void drawRustyMetal(
    Canvas canvas,
    Rect rect,
    Color metalColor,
    {int seed = 42}
  ) {
    final random = Random(seed);
    
    // Base metálica
    canvas.drawRect(rect, Paint()..color = metalColor);
    
    // Manchas de óxido
    final rustColor = const Color(0xFF8B4513); // Marrón óxido
    for (int i = 0; i < 50; i++) {
      final x = rect.left + random.nextDouble() * rect.width;
      final y = rect.top + random.nextDouble() * rect.height;
      final size = random.nextDouble() * 20 + 10;
      
      canvas.drawCircle(
        Offset(x, y),
        size,
        Paint()
          ..color = rustColor.withOpacity(random.nextDouble() * 0.5 + 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    
    // Rayones
    for (int i = 0; i < 20; i++) {
      final x1 = rect.left + random.nextDouble() * rect.width;
      final y1 = rect.top + random.nextDouble() * rect.height;
      final x2 = x1 + random.nextDouble() * 40 - 20;
      final y2 = y1 + random.nextDouble() * 40 - 20;
      
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..strokeWidth = 1,
      );
    }
  }
  
  /// Genera textura de madera
  static void drawWoodTexture(
    Canvas canvas,
    Rect rect,
    Color woodColor,
    {int seed = 42}
  ) {
    final random = Random(seed);
    
    // Base de madera
    canvas.drawRect(rect, Paint()..color = woodColor);
    
    // Vetas de madera (líneas horizontales onduladas)
    final grainCount = (rect.height / 20).toInt();
    for (int i = 0; i < grainCount; i++) {
      final y = rect.top + (i * rect.height / grainCount);
      final path = Path();
      path.moveTo(rect.left, y);
      
      // Crear línea ondulada
      for (double x = rect.left; x < rect.right; x += 10) {
        final offset = sin(x / 30 + random.nextDouble() * 2) * 3;
        path.lineTo(x, y + offset);
      }
      
      canvas.drawPath(
        path,
        Paint()
          ..color = _adjustBrightness(woodColor, -0.1)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
    
    // Nudos de madera
    for (int i = 0; i < 5; i++) {
      final x = rect.left + random.nextDouble() * rect.width;
      final y = rect.top + random.nextDouble() * rect.height;
      
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: random.nextDouble() * 30 + 20,
          height: random.nextDouble() * 20 + 10,
        ),
        Paint()
          ..color = _adjustBrightness(woodColor, -0.3)
          ..style = PaintingStyle.fill,
      );
    }
  }
  
  /// Genera textura de concreto agrietado
  static void drawCrackedConcrete(
    Canvas canvas,
    Rect rect,
    Color concreteColor,
    {int seed = 42}
  ) {
    final random = Random(seed);
    
    // Base de concreto
    canvas.drawRect(rect, Paint()..color = concreteColor);
    
    // Textura granulada
    for (int i = 0; i < 1000; i++) {
      final x = rect.left + random.nextDouble() * rect.width;
      final y = rect.top + random.nextDouble() * rect.height;
      
      canvas.drawCircle(
        Offset(x, y),
        0.5,
        Paint()..color = _adjustBrightness(concreteColor, random.nextDouble() * 0.2 - 0.1),
      );
    }
    
    // Grietas
    for (int i = 0; i < 8; i++) {
      final startX = rect.left + random.nextDouble() * rect.width;
      final startY = rect.top + random.nextDouble() * rect.height;
      
      final path = Path();
      path.moveTo(startX, startY);
      
      var currentX = startX;
      var currentY = startY;
      
      // Crear grieta ramificada
      for (int j = 0; j < 20; j++) {
        currentX += random.nextDouble() * 20 - 10;
        currentY += random.nextDouble() * 20 - 10;
        path.lineTo(currentX, currentY);
      }
      
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black.withOpacity(0.4)
          ..strokeWidth = random.nextDouble() * 2 + 1
          ..style = PaintingStyle.stroke,
      );
    }
  }
  
  /// Ajusta el brillo de un color
  static Color _adjustBrightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final newLightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(newLightness).toColor();
  }
}

/// Painter personalizado para texturas procedurales
class ProceduralTexturePainter extends CustomPainter {
  final String textureType;
  final Color baseColor;
  final int seed;
  
  ProceduralTexturePainter({
    required this.textureType,
    required this.baseColor,
    this.seed = 42,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    switch (textureType) {
      case 'brick':
        ProceduralTexture.drawBrickWall(
          canvas,
          rect,
          baseColor,
          const Color(0xFF2a2a2a), // Mortero oscuro
        );
        break;
      case 'metal':
        ProceduralTexture.drawRustyMetal(canvas, rect, baseColor, seed: seed);
        break;
      case 'wood':
        ProceduralTexture.drawWoodTexture(canvas, rect, baseColor, seed: seed);
        break;
      case 'concrete':
        ProceduralTexture.drawCrackedConcrete(canvas, rect, baseColor, seed: seed);
        break;
      default:
        // Textura simple con ruido
        canvas.drawRect(rect, Paint()..color = baseColor);
        final random = Random(seed);
        for (int i = 0; i < 500; i++) {
          final x = random.nextDouble() * size.width;
          final y = random.nextDouble() * size.height;
          canvas.drawCircle(
            Offset(x, y),
            1,
            Paint()..color = baseColor.withOpacity(random.nextDouble() * 0.3),
          );
        }
    }
  }
  
  @override
  bool shouldRepaint(ProceduralTexturePainter oldDelegate) {
    return textureType != oldDelegate.textureType ||
           baseColor != oldDelegate.baseColor ||
           seed != oldDelegate.seed;
  }
}
