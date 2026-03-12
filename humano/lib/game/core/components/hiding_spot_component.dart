import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

/// Hiding spot component - shared across arcs
class HidingSpotComponent extends PositionComponent with CollisionCallbacks {
  static const Color hidingSpotColor = Color(0xFF4444AA);

  HidingSpotComponent({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = hidingSpotColor.withOpacity(0.3),
    ));
    
    add(RectangleHitbox());
  }
}
