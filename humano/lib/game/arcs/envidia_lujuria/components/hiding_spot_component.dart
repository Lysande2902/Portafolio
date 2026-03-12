import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

/// Hiding spot component for Envidia y Lujuria Arc
/// NOTE: Only available in Phase 2 (Club area)!
class HidingSpotComponent extends PositionComponent with CollisionCallbacks {
  static const Color hidingSpotColor = Color(0xFF8B008B); // Purple for this arc

  HidingSpotComponent({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = hidingSpotColor.withOpacity(0.4),
    ));
    
    // Add border
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = hidingSpotColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    ));
    
    add(RectangleHitbox());
  }
}
