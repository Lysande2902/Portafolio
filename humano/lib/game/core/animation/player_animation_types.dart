import 'package:flame/components.dart';

/// Animation states for the player character
enum PlayerAnimationState {
  idle,
  walk,
  run, // For future use
}

/// Directions the player can face
/// Maps to rows in LPC spritesheets
enum PlayerDirection {
  up,    // Row 0 in spritesheet
  left,  // Row 1 in spritesheet
  down,  // Row 2 in spritesheet
  right, // Row 3 in spritesheet
}

/// Configuration for a specific animation
class AnimationConfig {
  final String assetPath;
  final int frameCount;
  final double stepTime;
  final Vector2 frameSize;

  const AnimationConfig({
    required this.assetPath,
    required this.frameCount,
    required this.stepTime,
    required this.frameSize,
  });

  /// Walk animation configuration
  static AnimationConfig walk(String basePath) => AnimationConfig(
        assetPath: '$basePath/walk.png',
        frameCount: 9,
        stepTime: 0.125, // 8 FPS
        frameSize: Vector2(64, 64),
      );

  /// Idle animation configuration
  static AnimationConfig idle(String basePath) => AnimationConfig(
        assetPath: '$basePath/idle.png',
        frameCount: 1,
        stepTime: 1.0,
        frameSize: Vector2(64, 64),
      );

  /// Run animation configuration (for future use)
  static AnimationConfig run(String basePath) => AnimationConfig(
        assetPath: '$basePath/run.png',
        frameCount: 8,
        stepTime: 0.1, // 10 FPS
        frameSize: Vector2(64, 64),
      );
}

/// Manages asset paths for player animations
class PlayerAssets {
  // Default path (relative to assets/images/)
  static const String defaultBasePath = 'store/skins/animations/player_skin_anonymous_lpc/standard';

  /// Get the base path for a specific skin
  /// Returns path relative to assets/images/ for Flame.images.load()
  static String getBasePath(String? skinId) {
    if (skinId == null) {
      return defaultBasePath;
    }
    
    // Map skin IDs to their paths (relative to assets/images/)
    switch (skinId) {
      case 'skin_anonymous':
      case 'player_skin_anonymous_lpc':
        return 'store/skins/animations/player_skin_anonymous_lpc/standard';
      case 'skin_ghost_user':
      case 'player_skin_ghost_user_lpc':
        return 'store/skins/animations/player_skin_ghost_user_lpc/standard';
      case 'skin_influencer':
      case 'player_skin_influencer_lpc':
        return 'store/skins/animations/player_skin_influencer_lpc/standard';
      case 'skin_moderator':
      case 'player_skin_moderator_lpc':
        return 'store/skins/animations/player_skin_moderator_lpc/standard';
      case 'skin_troll':
      case 'player_skin_troll_lpc':
        return 'store/skins/animations/player_skin_troll_lpc/standard';
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
  static AnimationConfig walkConfig({String? skinId}) {
    final basePath = getBasePath(skinId);
    return AnimationConfig.walk(basePath);
  }

  /// Get animation configuration for idle
  static AnimationConfig idleConfig({String? skinId}) {
    final basePath = getBasePath(skinId);
    return AnimationConfig.idle(basePath);
  }

  /// Get animation configuration for run
  static AnimationConfig runConfig({String? skinId}) {
    final basePath = getBasePath(skinId);
    return AnimationConfig.run(basePath);
  }
}

/// Manages asset paths for Greed enemy animations
class GreedEnemyAssets {
  static const String defaultBasePath = 'animations/lpc_female_rat/standard';

  /// Get the base path for a specific enemy skin
  static String getBasePath(String? skinId) {
    if (skinId == null) {
      return defaultBasePath;
    }

    switch (skinId) {
      case 'skin_greed_porcelain':
      case 'sin_greed_porcelain_lpc':
        return '../store/skins/animations/sin_greed_porcelain_lpc/standard';
      case 'skin_greed_glitch':
      case 'sin_greed_glitch_lpc':
        return '../store/skins/animations/sin_greed_glitch_lpc/standard';
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
  static AnimationConfig walkConfig({String? skinId}) {
    final basePath = getBasePath(skinId);
    return AnimationConfig(
      assetPath: '$basePath/walk.png',
      frameCount: 9,
      stepTime: 0.15, // Slightly faster than normal
      frameSize: Vector2(64, 64),
    );
  }

  /// Get animation configuration for idle
  static AnimationConfig idleConfig({String? skinId}) {
    final basePath = getBasePath(skinId);
    return AnimationConfig(
      assetPath: '$basePath/idle.png',
      frameCount: 1,
      stepTime: 1.0,
      frameSize: Vector2(64, 64),
    );
  }
}

/// Manages asset paths for Gluttony enemy animations
class GluttonyEnemyAssets {
  static const String defaultBasePath = 'animations/lpc_muscular_animations_enemigo_gula/standard';

  /// Get the base path for a specific enemy skin
  static String getBasePath(String? skinId) {
    if (skinId == null) {
      return defaultBasePath;
    }

    switch (skinId) {
      case 'skin_gluttony_porcelain':
      case 'sin_gluttony_porcelain_lpc':
        return '../store/skins/animations/sin_gluttony_porcelain_lpc/standard';
      case 'skin_gluttony_glitch':
      case 'sin_gluttony_glitch_lpc':
        return '../store/skins/animations/sin_gluttony_glitch_lpc/standard';
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
  static AnimationConfig walkConfig({String? skinId}) {
    final basePath = getBasePath(skinId);
    return AnimationConfig(
      assetPath: '$basePath/walk.png',
      frameCount: 9,
      stepTime: 0.15,
      frameSize: Vector2(64, 64),
    );
  }

  /// Get animation configuration for idle
  static AnimationConfig idleConfig({String? skinId}) {
    final basePath = getBasePath(skinId);
    return AnimationConfig(
      assetPath: '$basePath/idle.png',
      frameCount: 1,
      stepTime: 1.0,
      frameSize: Vector2(64, 64),
    );
  }
}

/// Manages asset paths for Sloth enemy (Caracol) animations
class SlothEnemyAssets {
  static const String basePath = 'animations/lpc_enemigo_caracol/standard';

  /// Get the full asset path for a specific animation
  static String getAssetPath(String animationName) {
    return '$basePath/$animationName.png';
  }

  /// Get animation configuration for walk (very slow)
  static AnimationConfig get walkConfig => AnimationConfig(
        assetPath: '$basePath/walk.png',
        frameCount: 9,
        stepTime: 0.25, // 4 FPS - Very slow for sloth
        frameSize: Vector2(64, 64),
      );

  /// Get animation configuration for idle
  static AnimationConfig get idleConfig => AnimationConfig(
        assetPath: '$basePath/idle.png',
        frameCount: 1,
        stepTime: 1.0,
        frameSize: Vector2(64, 64),
      );
}

/// Combines animation state and direction into a single key
class AnimationKey {
  final PlayerAnimationState state;
  final PlayerDirection direction;

  const AnimationKey(this.state, this.direction);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimationKey &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          direction == other.direction;

  @override
  int get hashCode => state.hashCode ^ direction.hashCode;

  @override
  String toString() => '${state.name}_${direction.name}';
}
