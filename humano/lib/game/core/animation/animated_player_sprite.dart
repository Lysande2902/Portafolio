import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:humano/game/core/animation/player_animation_types.dart';

/// Animated sprite component for the player character
/// Handles loading and displaying LPC sprite animations
class AnimatedPlayerSprite extends SpriteAnimationGroupComponent<AnimationKey>
    with HasGameReference {
  // Animation configuration
  static const int framesPerRow = 9; // LPC standard for walk
  static final Vector2 spriteSize = Vector2(64, 64);

  // Current state
  PlayerDirection currentDirection = PlayerDirection.down;
  PlayerAnimationState currentState = PlayerAnimationState.idle;

  // Skin system
  final String? skinId;

  // Fallback visual
  bool _useFallback = false;
  RectangleComponent? _fallbackRect;

  AnimatedPlayerSprite({this.skinId}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await loadAnimations();
  }

  /// Load all player animations from spritesheets
  Future<void> loadAnimations() async {
    try {
      final animations = <AnimationKey, SpriteAnimation>{};

      // Load idle animations (1 frame per direction)
      await _loadIdleAnimations(animations);

      // Load walk animations (9 frames per direction)
      await _loadWalkAnimations(animations);

      // Set animations
      this.animations = animations;

      // Set initial animation
      current = AnimationKey(PlayerAnimationState.idle, PlayerDirection.down);

      debugPrint('✅ Player animations loaded successfully (skin: ${skinId ?? "default"})');
    } catch (e) {
      debugPrint('❌ ERROR: Failed to load player animations: $e');
      _useFallbackVisual();
    }
  }

  /// Load idle animations for all 4 directions
  Future<void> _loadIdleAnimations(
      Map<AnimationKey, SpriteAnimation> animations) async {
    final config = PlayerAssets.idleConfig(skinId: skinId);
    final fullPath = 'assets/images/${config.assetPath}';
    debugPrint('🔍 [SKIN DEBUG] skinId: $skinId');
    debugPrint('🔍 [SKIN DEBUG] config.assetPath: ${config.assetPath}');
    debugPrint('🔍 [SKIN DEBUG] Full path will be: $fullPath');
    
    final image = await Flame.images.load(config.assetPath);
    debugPrint('✅ [SKIN DEBUG] Idle image loaded: ${image.width}x${image.height}');

    for (var direction in PlayerDirection.values) {
      final rowIndex = direction.index;
      final animation = SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: config.frameCount,
          stepTime: config.stepTime,
          textureSize: config.frameSize,
          texturePosition: Vector2(0, rowIndex * config.frameSize.y),
        ),
      );

      animations[AnimationKey(PlayerAnimationState.idle, direction)] =
          animation;
    }
  }

  /// Load walk animations for all 4 directions
  Future<void> _loadWalkAnimations(
      Map<AnimationKey, SpriteAnimation> animations) async {
    final config = PlayerAssets.walkConfig(skinId: skinId);
    final fullPath = 'assets/images/${config.assetPath}';
    debugPrint('🔍 Loading walk animation from: $fullPath');
    
    final image = await Flame.images.load(config.assetPath);

    for (var direction in PlayerDirection.values) {
      final rowIndex = direction.index;
      final animation = SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: config.frameCount,
          stepTime: config.stepTime,
          textureSize: config.frameSize,
          texturePosition: Vector2(0, rowIndex * config.frameSize.y),
        ),
      );

      animations[AnimationKey(PlayerAnimationState.walk, direction)] =
          animation;
    }
  }

  /// Update the animation state and direction
  void updateAnimationState(
      PlayerAnimationState state, PlayerDirection direction) {
    if (_useFallback) return;

    currentState = state;
    currentDirection = direction;

    final animationKey = AnimationKey(state, direction);

    if (animations?.containsKey(animationKey) ?? false) {
      current = animationKey;
    } else {
      debugPrint('⚠️ WARNING: Animation not found: $animationKey');
    }
  }

  /// Get current animation info for debugging
  String getDebugInfo() {
    if (_useFallback) return 'Using fallback visual';
    return 'State: ${currentState.name}, Direction: ${currentDirection.name}';
  }

  /// Use a fallback visual if animations fail to load
  void _useFallbackVisual() {
    _useFallback = true;
    debugPrint('⚠️ Using advanced fallback visual for player');
  }

  @override
  void render(Canvas canvas) {
    if (_useFallback) {
      _renderFallback(canvas);
    } else {
      super.render(canvas);
    }
  }

  void _renderFallback(Canvas canvas) {
    // Colores basados en skin o defecto (Alex)
    final Color bodyColor = const Color(0xFF3B82F6); // Azul Alex
    final Color headColor = const Color(0xFF1E40AF); // Azul oscuro
    
    // Dimensiones
    final double w = size.x;
    final double h = size.y;
    
    // Cuerpo
    final Paint paint = Paint()..color = bodyColor;
    canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.4, w * 0.6, h * 0.6), paint);
    
    // Cabeza
    paint.color = headColor;
    canvas.drawCircle(Offset(w / 2, h * 0.25), w * 0.35, paint);
    
    // Ojos para indicar dirección
    paint.color = Colors.white;
    double eyeX = w / 2;
    double eyeY = h * 0.25;
    double eyeOffset = w * 0.15;
    
    switch (currentDirection) {
      case PlayerDirection.down:
        canvas.drawCircle(Offset(eyeX - 8, eyeY), 3, paint);
        canvas.drawCircle(Offset(eyeX + 8, eyeY), 3, paint);
        break;
      case PlayerDirection.up:
        // Sin ojos (espalda)
        break;
      case PlayerDirection.left:
        canvas.drawCircle(Offset(eyeX - eyeOffset, eyeY), 3, paint);
        break;
      case PlayerDirection.right:
        canvas.drawCircle(Offset(eyeX + eyeOffset, eyeY), 3, paint);
        break;
    }
    
    // Indicador de "caminando" (pequeña oscilación si no es idle)
    if (currentState == PlayerAnimationState.walk) {
       // Visualmente static por ahora, pero podríamos añadir oscilación con el tiempo
    }
  }
}
