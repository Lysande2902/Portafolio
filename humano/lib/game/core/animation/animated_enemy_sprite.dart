import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:humano/game/core/animation/enemy_animation_types.dart';

/// Animated sprite component for enemy characters
/// Handles loading and displaying LPC sprite animations for enemies
class AnimatedEnemySprite extends SpriteAnimationGroupComponent<EnemyAnimationKey>
    with HasGameReference {
  // Animation configuration
  static const int framesPerRow = 9; // LPC standard for walk
  static final Vector2 spriteSize = Vector2(64, 64);

  // Current state
  EnemyDirection currentDirection = EnemyDirection.down;
  EnemyAnimationState currentState = EnemyAnimationState.idle;

  // Fallback visual
  bool _useFallback = false;
  RectangleComponent? _fallbackRect;
  
  // Skin system
  final String? skinId;

  AnimatedEnemySprite({this.skinId}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await loadAnimations();
  }

  /// Load all enemy animations from spritesheets
  Future<void> loadAnimations() async {
    try {
      final animations = <EnemyAnimationKey, SpriteAnimation>{};

      // Load idle animations (1 frame per direction)
      await _loadIdleAnimations(animations);

      // Load walk animations (9 frames per direction)
      await _loadWalkAnimations(animations);

      // Load run animations (8 frames per direction)
      await _loadRunAnimations(animations);

      // Set animations
      this.animations = animations;

      // Set initial animation
      current = EnemyAnimationKey(EnemyAnimationState.idle, EnemyDirection.down);

      debugPrint('✅ Enemy animations loaded successfully (idle, walk, run)');
    } catch (e) {
      debugPrint('❌ ERROR: Failed to load enemy animations: $e');
      _useFallbackVisual();
    }
  }

  /// Load idle animations for all 4 directions
  Future<void> _loadIdleAnimations(
      Map<EnemyAnimationKey, SpriteAnimation> animations) async {
    final config = EnemyAssets.idleConfig(skinId: skinId);
    debugPrint('🔍 Loading enemy idle animation from: ${config.assetPath} (skin: ${skinId ?? "default"})');
    final image = await Flame.images.load(config.assetPath);

    for (var direction in EnemyDirection.values) {
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

      animations[EnemyAnimationKey(EnemyAnimationState.idle, direction)] =
          animation;
    }
  }

  /// Load walk animations for all 4 directions
  Future<void> _loadWalkAnimations(
      Map<EnemyAnimationKey, SpriteAnimation> animations) async {
    final config = EnemyAssets.walkConfig(skinId: skinId);
    debugPrint('🔍 Loading enemy walk animation from: ${config.assetPath} (skin: ${skinId ?? "default"})');
    final image = await Flame.images.load(config.assetPath);

    for (var direction in EnemyDirection.values) {
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

      animations[EnemyAnimationKey(EnemyAnimationState.walk, direction)] =
          animation;
    }
  }

  /// Load run animations for all 4 directions
  Future<void> _loadRunAnimations(
      Map<EnemyAnimationKey, SpriteAnimation> animations) async {
    final config = EnemyAssets.runConfig(skinId: skinId);
    debugPrint('🔍 Loading enemy run animation from: ${config.assetPath} (skin: ${skinId ?? "default"})');
    final image = await Flame.images.load(config.assetPath);

    for (var direction in EnemyDirection.values) {
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

      animations[EnemyAnimationKey(EnemyAnimationState.run, direction)] =
          animation;
    }
  }

  /// Update the animation state and direction
  void updateAnimationState(
      EnemyAnimationState state, EnemyDirection direction) {
    if (_useFallback) return;

    currentState = state;
    currentDirection = direction;

    final animationKey = EnemyAnimationKey(state, direction);

    if (animations?.containsKey(animationKey) ?? false) {
      current = animationKey;
    } else {
      debugPrint('⚠️ WARNING: Enemy animation not found: $animationKey');
    }
  }

  /// Get current animation info for debugging
  String getDebugInfo() {
    if (_useFallback) return 'Using fallback visual';
    return 'Enemy State: ${currentState.name}, Direction: ${currentDirection.name}';
  }

  /// Use a fallback visual if animations fail to load
  void _useFallbackVisual() {
    _useFallback = true;
    debugPrint('⚠️ Using advanced fallback visual for enemy (skin: $skinId)');
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
    // Determinar colores según skinId
    Color bodyColor = const Color(0xFFFF0000); // Default Rojo
    Color accentColor = const Color(0xFF8B0000); // Rojo oscuro
    
    if (skinId != null) {
      if (skinId!.contains('spider') || skinId!.contains('greed')) {
        bodyColor = const Color(0xFF1A1A1A); // Araña Negra
        accentColor = const Color(0xFFFF0000); // Detalles Rojos
      } else if (skinId!.contains('gluttony')) {
        bodyColor = const Color(0xFFFCA5A5); // Gula Rosa Palido
        accentColor = const Color(0xFFDC2626); // Sangre
      } else if (skinId!.contains('chameleon') || skinId!.contains('envy')) {
        bodyColor = const Color(0xFF10B981); // Camaleón Verde
        accentColor = const Color(0xFF34D399); // Verde claro glitch
      }
    }

    // Dimensiones
    final double w = size.x;
    final double h = size.y;
    
    final Paint paint = Paint()..color = bodyColor;
    
    // Forma base
    if (skinId != null && (skinId!.contains('spider') || skinId!.contains('greed'))) {
      // Araña: Cuerpo ovalado ancho
      canvas.drawOval(Rect.fromLTWH(0, h * 0.3, w, h * 0.5), paint);
      // Cabeza pequeña
      paint.color = bodyColor.withOpacity(0.8);
      canvas.drawCircle(Offset(w / 2, h * 0.3), w * 0.25, paint);
      
      // Patas (Lineas simples)
      paint.color = bodyColor;
      paint.strokeWidth = 3;
      paint.style = PaintingStyle.stroke;
      // Izquierda
      canvas.drawLine(Offset(w * 0.2, h * 0.5), Offset(0 - 10, h * 0.4), paint);
      canvas.drawLine(Offset(w * 0.2, h * 0.5), Offset(0 - 10, h * 0.6), paint);
      // Derecha
      canvas.drawLine(Offset(w * 0.8, h * 0.5), Offset(w + 10, h * 0.4), paint);
      canvas.drawLine(Offset(w * 0.8, h * 0.5), Offset(w + 10, h * 0.6), paint);
      
      // Restaurar estilo
      paint.style = PaintingStyle.fill;
    } else {
      // Humanoide (Gula, Camaleón, Default)
      canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.3, w * 0.8, h * 0.7), paint);
      paint.color = bodyColor.withOpacity(0.8);
      canvas.drawCircle(Offset(w / 2, h * 0.2), w * 0.3, paint);
    }
    
    // Ojos (Siempre rojos o brillantes para enemigos)
    paint.color = accentColor;
    double eyeX = w / 2;
    double eyeY = h * 0.2; // Altura de cabeza humanoide por defecto
    
    if (skinId != null && (skinId!.contains('spider') || skinId!.contains('greed'))) {
      eyeY = h * 0.3; // Altura cabeza araña
    }
    
    double eyeOffset = w * 0.15;
    double eyeSize = 3.0;

    switch (currentDirection) {
      case EnemyDirection.down:
        canvas.drawCircle(Offset(eyeX - 8, eyeY), eyeSize, paint);
        canvas.drawCircle(Offset(eyeX + 8, eyeY), eyeSize, paint);
        break;
      case EnemyDirection.up:
        // Sin ojos
        break;
      case EnemyDirection.left:
        canvas.drawCircle(Offset(eyeX - eyeOffset, eyeY), eyeSize, paint);
        break;
      case EnemyDirection.right:
        canvas.drawCircle(Offset(eyeX + eyeOffset, eyeY), eyeSize, paint);
        break;
    }
  }
}
