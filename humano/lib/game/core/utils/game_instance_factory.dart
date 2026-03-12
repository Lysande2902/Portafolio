import 'package:flutter/foundation.dart';
import 'package:humano/game/core/base/base_arc_game.dart';

/// Factory for creating game instances with guaranteed uniqueness
/// 
/// This factory ensures that each game instance has a unique identifier
/// to prevent reuse of disposed instances, which would violate Flame's
/// constraint that a game can only be attached to one widget at a time.
class GameInstanceFactory {
  static int _instanceCounter = 0;
  
  /// Creates a new game instance with a unique identifier
  /// 
  /// The factory increments a counter for each instance created,
  /// ensuring that every game has a unique ID throughout the app's lifetime.
  /// 
  /// Example:
  /// ```dart
  /// final game = GameInstanceFactory.createGame(() => GluttonyArcGame());
  /// ```
  static T createGame<T extends BaseArcGame>(T Function() constructor) {
    _instanceCounter++;
    final game = constructor();
    
    // Assign unique instance ID
    game.instanceId = _instanceCounter;
    
    debugPrint('🏭 [FACTORY] Created game instance #$_instanceCounter (hashCode: ${game.hashCode})');
    
    return game;
  }
  
  /// Gets the current instance counter value (for testing/debugging)
  static int get currentInstanceCount => _instanceCounter;
  
  /// Resets the instance counter (for testing only)
  @visibleForTesting
  static void resetCounter() {
    _instanceCounter = 0;
    debugPrint('🔄 [FACTORY] Instance counter reset');
  }
}
