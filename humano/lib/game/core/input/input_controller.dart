import 'package:flame/components.dart';
import 'package:flutter/services.dart';

/// Handles input from keyboard and virtual joystick
/// Provides unified input interface for player movement
class InputController {
  // Current movement direction (normalized)
  Vector2 movementDirection = Vector2.zero();

  // Action button state
  bool actionPressed = false;
  
  // Input responsiveness tracking
  DateTime? _lastInputTime;
  final List<double> _inputResponseTimes = [];
  static const int _maxResponseHistory = 30;

  /// Update movement from keyboard input
  void updateFromKeyboard(Set<LogicalKeyboardKey> keys) {
    // Track input time
    _lastInputTime = DateTime.now();
    
    double x = 0.0;
    double y = 0.0;

    // Horizontal movement
    if (keys.contains(LogicalKeyboardKey.keyA) ||
        keys.contains(LogicalKeyboardKey.arrowLeft)) {
      x -= 1.0;
    }
    if (keys.contains(LogicalKeyboardKey.keyD) ||
        keys.contains(LogicalKeyboardKey.arrowRight)) {
      x += 1.0;
    }

    // Vertical movement
    if (keys.contains(LogicalKeyboardKey.keyW) ||
        keys.contains(LogicalKeyboardKey.arrowUp)) {
      y -= 1.0;
    }
    if (keys.contains(LogicalKeyboardKey.keyS) ||
        keys.contains(LogicalKeyboardKey.arrowDown)) {
      y += 1.0;
    }

    // Action button (Space)
    actionPressed = keys.contains(LogicalKeyboardKey.space);

    // Set movement direction (normalized for diagonal movement)
    if (x != 0 || y != 0) {
      movementDirection = Vector2(x, y).normalized();
    } else {
      movementDirection = Vector2.zero();
    }
  }

  /// Update movement from virtual joystick
  void updateFromJoystick(Vector2 direction) {
    // Track input time
    if (direction.length > 0.1) {
      _lastInputTime = DateTime.now();
    }
    movementDirection = direction;
  }
  
  /// Mark that input was processed (for responsiveness tracking)
  void markInputProcessed() {
    if (_lastInputTime != null) {
      final responseTime = DateTime.now().difference(_lastInputTime!).inMilliseconds.toDouble();
      _inputResponseTimes.add(responseTime);
      
      // Keep only last N responses
      if (_inputResponseTimes.length > _maxResponseHistory) {
        _inputResponseTimes.removeAt(0);
      }
      
      // Warn if response time is slow
      if (responseTime > 100) {
        print('⚠️ [INPUT] Slow input response: ${responseTime.toStringAsFixed(1)}ms');
      }
      
      _lastInputTime = null;
    }
  }
  
  /// Get average input response time
  double get averageResponseTime {
    if (_inputResponseTimes.isEmpty) return 0.0;
    return _inputResponseTimes.reduce((a, b) => a + b) / _inputResponseTimes.length;
  }

  /// Trigger action button press
  void pressAction() {
    actionPressed = true;
  }

  /// Reset action button state
  void resetAction() {
    actionPressed = false;
  }

  /// Reset all input
  void reset() {
    movementDirection = Vector2.zero();
    actionPressed = false;
  }
}
