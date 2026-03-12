import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Hiding spot component mejorado con diseño realista
/// Representa cajas, barriles, o contenedores donde el jugador puede esconderse
class HidingSpotComponent extends PositionComponent with CollisionCallbacks {
  static const Color primaryColor = Color(0xFF6B4423); // Marrón oscuro
  static const Color secondaryColor = Color(0xFF8B5A3C); // Marrón medio
  static const Color highlightColor = Color(0xFFA67C52); // Marrón claro
  static const Color shadowColor = Color(0xFF3D2817); // Marrón muy oscuro

  HidingSpotComponent({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Fondo principal (caja/barril)
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            secondaryColor,
            primaryColor,
            shadowColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
    ));
    
    // Sombra interior (profundidad)
    add(RectangleComponent(
      position: Vector2(4, 4),
      size: size - Vector2(8, 8),
      paint: Paint()..color = shadowColor.withOpacity(0.4),
    ));
    
    // Highlight (luz)
    add(RectangleComponent(
      position: Vector2(8, 8),
      size: Vector2(size.x * 0.3, size.y * 0.3),
      paint: Paint()..color = highlightColor.withOpacity(0.3),
    ));
    
    // Líneas de textura (madera/metal)
    _addTextureLines();
    
    // Borde exterior (definición)
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = shadowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    ));
    
    // Borde interior (detalle)
    add(RectangleComponent(
      position: Vector2(3, 3),
      size: size - Vector2(6, 6),
      paint: Paint()
        ..color = highlightColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    ));
    
    // Icono de escondite (opcional - pequeño)
    _addHideIcon();
    
    add(RectangleHitbox());
  }
  
  /// Agregar líneas de textura para simular madera o metal
  void _addTextureLines() {
    final lineCount = (size.y / 20).floor();
    
    for (int i = 0; i < lineCount; i++) {
      final y = 15.0 + i * 20.0;
      
      // Línea oscura
      add(RectangleComponent(
        position: Vector2(8, y),
        size: Vector2(size.x - 16, 1.5),
        paint: Paint()..color = shadowColor.withOpacity(0.3),
      ));
      
      // Línea clara (highlight)
      add(RectangleComponent(
        position: Vector2(8, y + 2),
        size: Vector2(size.x - 16, 0.8),
        paint: Paint()..color = highlightColor.withOpacity(0.2),
      ));
    }
  }
  
  /// Agregar icono pequeño de escondite
  void _addHideIcon() {
    final iconSize = math.min(size.x, size.y) * 0.25;
    final iconPos = Vector2(
      (size.x - iconSize) / 2,
      (size.y - iconSize) / 2,
    );
    
    // Círculo de fondo
    add(CircleComponent(
      radius: iconSize / 2,
      position: iconPos + Vector2(iconSize / 2, iconSize / 2),
      paint: Paint()..color = shadowColor.withOpacity(0.6),
      anchor: Anchor.center,
    ));
    
    // Símbolo de "ojo cerrado" simplificado
    // Línea horizontal (ojo cerrado)
    add(RectangleComponent(
      position: iconPos + Vector2(iconSize * 0.2, iconSize * 0.5),
      size: Vector2(iconSize * 0.6, 2.0),
      paint: Paint()..color = highlightColor.withOpacity(0.8),
    ));
  }
}
