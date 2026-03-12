import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

/// Wall component that blocks movement
/// La colisión se adapta dinámicamente a rotación y escala
class WallComponent extends RectangleComponent with CollisionCallbacks {
  WallComponent({
    required super.position,
    required super.size,
    required Color color,
  }) : super(
    paint: Paint()..color = color,
    anchor: Anchor.topLeft, // CRITICAL for collision alignment
  ) {
    debugPrint('🧱 WallComponent created at $position with size $size');
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Add hitbox that adapts to size, rotation, and scale
    add(RectangleHitbox(
      size: size,
      position: Vector2.zero(),
      anchor: Anchor.topLeft, // CRITICAL for collision alignment
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update hitbox if size/scale/rotation changes
    // This ensures collision follows the block's transformation
    final hitbox = children.whereType<RectangleHitbox>().firstOrNull;
    if (hitbox != null) {
      hitbox.size = size;
      hitbox.angle = angle;
      hitbox.scale = scale;
    }
  }
}

/// Obstacle component that blocks movement
/// La colisión se adapta dinámicamente a rotación y escala
class ObstacleComponent extends RectangleComponent with CollisionCallbacks {
  ObstacleComponent({
    required super.position,
    required super.size,
    required Color color,
  }) : super(
    paint: Paint()..color = color,
    anchor: Anchor.topLeft, // CRITICAL for collision alignment
  ) {
    debugPrint('🚧 ObstacleComponent created at $position with size $size');
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Add hitbox that adapts to size, rotation, and scale
    add(RectangleHitbox(
      size: size,
      position: Vector2.zero(),
      anchor: Anchor.topLeft, // CRITICAL for collision alignment
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update hitbox if size/scale/rotation changes
    // This ensures collision follows the block's transformation
    final hitbox = children.whereType<RectangleHitbox>().firstOrNull;
    if (hitbox != null) {
      hitbox.size = size;
      hitbox.angle = angle;
      hitbox.scale = scale;
    }
  }
}
