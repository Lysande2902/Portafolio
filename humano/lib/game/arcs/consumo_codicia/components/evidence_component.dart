import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

/// Evidence component for Gluttony Arc
class EvidenceComponent extends PositionComponent with CollisionCallbacks {
  final String evidenceId;
  bool isCollected = false;
  
  static const double evidenceSize = 40.0;
  double pulseTime = 0.0;

  EvidenceComponent({
    required Vector2 position,
    required this.evidenceId,
  }) : super(
    position: position, 
    size: Vector2.all(evidenceSize), 
    anchor: Anchor.center, // Center anchor for evidence is OK since we use CircleHitbox
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      // Load archi.png sprite
      final archiImage = await Flame.images.load('archi.png');
      final sprite = SpriteComponent(
        sprite: Sprite(archiImage),
        size: Vector2.all(evidenceSize),
        anchor: Anchor.center,
      );
      add(sprite);
    } catch (e) {
      // Fallback to colored rectangle
      debugPrint('⚠️ Failed to load archi.png: $e');
      add(RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFFFFAA00),
        anchor: Anchor.center,
      ));
    }
    
    // Add glow effect
    add(CircleComponent(
      radius: evidenceSize * 0.7,
      paint: Paint()
        ..color = const Color(0xFFFFAA00).withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      anchor: Anchor.center,
    ));
    
    // Add collision
    add(CircleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Pulse animation
    pulseTime += dt * 2;
    final scale = 1.0 + (0.1 * (pulseTime % 1.0));
    this.scale = Vector2.all(scale);
  }
  
  void collect() {
    if (isCollected) return;
    
    isCollected = true;
    print('📄 Evidence collected: $evidenceId');
    
    // Remove from parent
    removeFromParent();
  }
}
