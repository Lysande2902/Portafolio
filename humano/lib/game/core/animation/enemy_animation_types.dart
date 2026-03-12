import 'package:flame/components.dart';

/// Animation states for enemy characters
enum EnemyAnimationState {
  idle,
  walk,
  run, // For future use
}

/// Directions the enemy can face
/// Maps to rows in LPC spritesheets
enum EnemyDirection {
  up,    // Row 0 in spritesheet
  left,  // Row 1 in spritesheet
  down,  // Row 2 in spritesheet
  right, // Row 3 in spritesheet
}

/// Configuration for enemy animations
class EnemyAnimationConfig {
  final String assetPath;
  final int frameCount;
  final double stepTime;
  final Vector2 frameSize;

  const EnemyAnimationConfig({
    required this.assetPath,
    required this.frameCount,
    required this.stepTime,
    required this.frameSize,
  });

  /// Walk animation configuration
  static EnemyAnimationConfig walk(String basePath) => EnemyAnimationConfig(
        assetPath: '$basePath/walk.png',
        frameCount: 9,
        stepTime: 0.125, // 8 FPS
        frameSize: Vector2(64, 64),
      );

  /// Idle animation configuration
  static EnemyAnimationConfig idle(String basePath) => EnemyAnimationConfig(
        assetPath: '$basePath/idle.png',
        frameCount: 1,
        stepTime: 1.0,
        frameSize: Vector2(64, 64),
      );

  /// Run animation configuration (for future use)
  static EnemyAnimationConfig run(String basePath) => EnemyAnimationConfig(
        assetPath: '$basePath/run.png',
        frameCount: 8,
        stepTime: 0.1, // 10 FPS
        frameSize: Vector2(64, 64),
      );
}

/// Manages asset paths for enemy animations
class EnemyAssets {
  // Flame.images.load() automatically prepends 'assets/images/'
  // So we only need the path relative to that
  static const String defaultBasePath =
      'animations/lpc_muscular_animations_enemigo_gula/standard';

  /// Get base path for a specific skin
  static String getBasePath(String? skinId) {
    if (skinId == null) return defaultBasePath;
    
    // Map skin IDs to their paths (relative to assets/images/)
    switch (skinId) {
      // Arco 1 - Gula (default)
      case 'skin_gluttony_porcelain':
      case 'sin_gluttony_porcelain_lpc':
        return 'store/skins/animations/sin_gluttony_porcelain_lpc/standard';
      case 'skin_gluttony_glitch':
      case 'sin_gluttony_glitch_lpc':
        return 'store/skins/animations/sin_gluttony_glitch_lpc/standard';
      
      // Arco 2 - Avaricia (Rata)
      case 'skin_greed_porcelain':
      case 'sin_greed_porcelain_lpc':
        return 'store/skins/animations/sin_greed_porcelain_lpc/standard';
      case 'skin_greed_glitch':
      case 'sin_greed_glitch_lpc':
        return 'store/skins/animations/sin_greed_glitch_lpc/standard';
      
      // Arco 3 - Envidia (Camaleón) - DEFAULT for Envy Arc
      case 'default_envy':
      case 'chameleon':
        return 'animations/lpc_male_envy/standard';
      
      default:
        return defaultBasePath;
    }
  }

  /// Get the full asset path for a specific animation
  static String getAssetPath(String animationName, {String? skinId}) {
    final basePath = getBasePath(skinId);
    return '$basePath/$animationName.png';
  }

  /// Get animation configuration for walk
  static EnemyAnimationConfig walkConfig({String? skinId}) =>
      EnemyAnimationConfig.walk(getBasePath(skinId));

  /// Get animation configuration for idle
  static EnemyAnimationConfig idleConfig({String? skinId}) =>
      EnemyAnimationConfig.idle(getBasePath(skinId));

  /// Get animation configuration for run
  static EnemyAnimationConfig runConfig({String? skinId}) =>
      EnemyAnimationConfig.run(getBasePath(skinId));
}

/// Combines animation state and direction into a single key for enemies
class EnemyAnimationKey {
  final EnemyAnimationState state;
  final EnemyDirection direction;

  const EnemyAnimationKey(this.state, this.direction);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnemyAnimationKey &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          direction == other.direction;

  @override
  int get hashCode => state.hashCode ^ direction.hashCode;

  @override
  String toString() => '${state.name}_${direction.name}';
}
