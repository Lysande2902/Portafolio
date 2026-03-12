import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Black flash overlay that triggers when enemy is near
/// Creates tension and disorientation
class DangerFlashOverlay extends PositionComponent {
  double flashTimer = 0.0;
  double flashInterval = 2.0; // Base interval between flashes
  double flashDuration = 0.15; // How long each flash lasts
  bool isFlashing = false;
  double flashProgress = 0.0;
  
  // Proximity settings
  double enemyDistance = 1000.0;
  double dangerThreshold = 200.0; // Distance at which flashes start
  
  final Random _random = Random();

  DangerFlashOverlay({
    required Vector2 size,
  }) : super(
          size: size,
          position: Vector2.zero(),
          priority: 2000, // Render on top of everything
        );

  @override
  void update(double dt) {
    super.update(dt);

    // Calculate flash frequency based on proximity
    final proximityFactor = _calculateProximityFactor();
    
    if (proximityFactor > 0) {
      flashTimer += dt;
      
      // Adjust interval based on proximity (closer = more frequent)
      final adjustedInterval = flashInterval * (1.0 - proximityFactor * 0.7);
      
      if (!isFlashing && flashTimer >= adjustedInterval) {
        _triggerFlash();
        flashTimer = 0.0;
      }
    }

    // Update flash animation
    if (isFlashing) {
      flashProgress += dt / flashDuration;
      
      if (flashProgress >= 1.0) {
        isFlashing = false;
        flashProgress = 0.0;
      }
    }
  }

  double _calculateProximityFactor() {
    if (enemyDistance > dangerThreshold) return 0.0;
    return 1.0 - (enemyDistance / dangerThreshold);
  }

  void _triggerFlash() {
    isFlashing = true;
    flashProgress = 0.0;
    
    // Add slight randomness to flash duration for unpredictability
    flashDuration = 0.1 + (_random.nextDouble() * 0.1);
  }

  /// Update enemy distance to adjust flash frequency
  void updateEnemyDistance(double distance) {
    enemyDistance = distance;
  }

  @override
  void render(Canvas canvas) {
    if (!isFlashing) return;

    // Calculate flash opacity (fade in and out quickly)
    double opacity;
    if (flashProgress < 0.3) {
      // Fade in quickly
      opacity = flashProgress / 0.3;
    } else if (flashProgress > 0.7) {
      // Fade out quickly
      opacity = (1.0 - flashProgress) / 0.3;
    } else {
      // Full opacity in middle
      opacity = 1.0;
    }

    // Calculate intensity based on proximity
    final proximityFactor = _calculateProximityFactor();
    final maxOpacity = 0.4 + (proximityFactor * 0.4); // 40% to 80% opacity
    
    final paint = Paint()
      ..color = Colors.black.withOpacity(opacity * maxOpacity);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );

    super.render(canvas);
  }
}
