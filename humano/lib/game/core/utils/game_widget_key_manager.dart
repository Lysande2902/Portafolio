import 'package:flutter/material.dart';

/// Manages GlobalKeys for GameWidgets
/// Creates a NEW key for each screen instance to avoid conflicts
class GameWidgetKeyManager {
  static int _keyCounter = 0;

  /// Create a NEW GlobalKey for each screen instance
  /// This ensures no two screens share the same key
  static GlobalKey createKeyForArc(String arcId) {
    _keyCounter++;
    final newKey = GlobalKey(debugLabel: 'GameWidget_${arcId}_$_keyCounter');
    debugPrint('🔑 [KEY_MANAGER] Created NEW GlobalKey for $arcId: ${newKey.hashCode} (counter: $_keyCounter)');
    return newKey;
  }

  /// Clear all stored keys
  /// Useful for testing or app-wide cleanup
  static void clearAll() {
    _keyCounter = 0;
    debugPrint('🔑 [KEY_MANAGER] Reset key counter');
  }

  /// Get the current key counter
  /// Useful for debugging and testing
  static int get keyCount => _keyCounter;
}
