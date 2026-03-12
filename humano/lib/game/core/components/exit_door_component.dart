import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

/// Exit door component - shared across arcs
class ExitDoorComponent extends PositionComponent with CollisionCallbacks {
  static const Color doorColor = Color(0xFF00FF00);
  static const double doorWidth = 80.0;
  static const double doorHeight = 120.0;

  ExitDoorComponent({
    required Vector2 position,
  }) : super(position: position, size: Vector2(doorWidth, doorHeight));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = doorColor.withOpacity(0.5),
    ));
    
    add(RectangleHitbox());
  }
}
