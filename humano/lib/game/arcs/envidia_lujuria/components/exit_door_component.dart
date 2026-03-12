import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

/// Exit door component for Envidia y Lujuria Arc
class ExitDoorComponent extends PositionComponent with CollisionCallbacks {
  static const double doorWidth = 80.0;
  static const double doorHeight = 120.0;
  
  bool isLocked = true;
  int requiredFragments = 10; // 10 fragments for fused arc
  int currentFragments = 0;

  ExitDoorComponent({
    required Vector2 position,
  }) : super(position: position, size: Vector2(doorWidth, doorHeight));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    _buildDoor();
    add(RectangleHitbox());
  }
  
  void _buildDoor() {
    removeAll(children.whereType<RectangleComponent>());
    removeAll(children.whereType<TextComponent>());
    
    if (isLocked) {
      // Locked door - purple/dark
      add(RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF2A102A), // Dark purple
      ));
      
      add(RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFF8B008B) // Purple border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0,
      ));
      
      add(RectangleComponent(
        position: Vector2(10, 10),
        size: Vector2(doorWidth - 20, doorHeight / 2 - 15),
        paint: Paint()
          ..color = const Color(0xFF6B006B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      ));
      
      add(RectangleComponent(
        position: Vector2(10, doorHeight / 2 + 5),
        size: Vector2(doorWidth - 20, doorHeight / 2 - 15),
        paint: Paint()
          ..color = const Color(0xFF6B006B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      ));
      
      // Lock icon (X shape)
      add(RectangleComponent(
        position: Vector2(doorWidth / 2 - 15, doorHeight / 2 - 2),
        size: Vector2(30, 4),
        angle: 0.785,
        paint: Paint()..color = const Color(0xFFFF00FF),
      ));
      
      add(RectangleComponent(
        position: Vector2(doorWidth / 2 - 15, doorHeight / 2 - 2),
        size: Vector2(30, 4),
        angle: -0.785,
        paint: Paint()..color = const Color(0xFFFF00FF),
      ));
      
      // Text showing required fragments
      add(TextComponent(
        text: '$currentFragments/$requiredFragments',
        position: Vector2(doorWidth / 2, doorHeight - 20),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFF00FF),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
    } else {
      // Unlocked door - green/open
      add(RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF104A10),
      ));
      
      add(RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFF00FF00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0,
      ));
      
      add(RectangleComponent(
        position: Vector2(10, 10),
        size: Vector2(doorWidth - 20, doorHeight / 2 - 15),
        paint: Paint()
          ..color = const Color(0xFF00AA00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      ));
      
      add(RectangleComponent(
        position: Vector2(10, doorHeight / 2 + 5),
        size: Vector2(doorWidth - 20, doorHeight / 2 - 15),
        paint: Paint()
          ..color = const Color(0xFF00AA00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      ));
      
      // Checkmark icon
      add(RectangleComponent(
        position: Vector2(doorWidth / 2 - 10, doorHeight / 2),
        size: Vector2(15, 4),
        angle: -0.785,
        paint: Paint()..color = Colors.green,
      ));
      
      add(RectangleComponent(
        position: Vector2(doorWidth / 2 - 10, doorHeight / 2),
        size: Vector2(25, 4),
        angle: 0.785,
        paint: Paint()..color = Colors.green,
      ));
      
      add(TextComponent(
        text: 'ABIERTA',
        position: Vector2(doorWidth / 2, doorHeight - 20),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
    }
  }
  
  void updateFragments(int fragments) {
    currentFragments = fragments;
    if (currentFragments >= requiredFragments && isLocked) {
      unlock();
    } else if (currentFragments < requiredFragments && !isLocked) {
      lock();
    } else {
      _buildDoor();
    }
  }
  
  void unlock() {
    if (!isLocked) return;
    isLocked = false;
    _buildDoor();
    debugPrint('🚪 Door unlocked!');
  }
  
  void lock() {
    if (isLocked) return;
    isLocked = true;
    _buildDoor();
    debugPrint('🔒 Door locked!');
  }
}
