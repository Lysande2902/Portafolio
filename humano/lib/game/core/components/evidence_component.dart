import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/flame.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:humano/game/core/collision/collision_layers.dart';

/// Fragment component - collectible pieces that form complete evidence
/// 5 fragments = 1 complete evidence
/// Shared across all arcs with collection animation
class EvidenceComponent extends PositionComponent with CollisionCallbacks, HasPaint implements OpacityProvider {
  final String evidenceId;
  final CollisionLayer collisionLayer = CollisionLayer.evidence;

  bool isCollected = false;
  bool _isCollecting = false;
  double glowIntensity = 0.0;
  double glowTimer = 0.0;
  double _opacity = 1.0;
  
  // Collection animation properties
  double _collectionTimer = 0.0;
  static const double _collectionDuration = 0.3; // Duration of collection animation
  double _initialScale = 1.0;
  
  Sprite? _archiSprite;
  bool _spriteLoaded = false;

  EvidenceComponent({
    required Vector2 position,
    required this.evidenceId,
  }) : super(
          position: position,
          size: Vector2(40, 40),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Try to load archi.png image
    try {
      final image = await Flame.images.load('archi.png');
      _archiSprite = Sprite(image);
      _spriteLoaded = true;
      print('✅ Evidence image loaded successfully');
    } catch (e) {
      print('⚠️ Could not load archi.png, using fallback: $e');
      _spriteLoaded = false;
      
      // Fallback: colored rectangle (will be rendered in render() method)
    }

    // Add collision hitbox
    await add(RectangleHitbox(
      size: size,
      position: Vector2.zero(),
      isSolid: false,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isCollected) {
      // Handle collection animation
      _collectionTimer += dt;
      
      // Calculate animation progress (0.0 to 1.0)
      final progress = (_collectionTimer / _collectionDuration).clamp(0.0, 1.0);
      
      // Scale up effect (1.0 to 1.5)
      scale = Vector2.all(_initialScale + (0.5 * progress));
      
      // Fade out effect
      _opacity = 1.0 - progress;
      
      // Remove component when animation completes
      if (_collectionTimer >= _collectionDuration) {
        removeFromParent();
      }
      return;
    }

    // Animate glow effect
    glowTimer += dt;
    glowIntensity = (sin(glowTimer * 3) + 1) / 2; // 0.0 to 1.0
  }

  @override
  void render(Canvas canvas) {
    if (isCollected && _opacity <= 0) return;

    // Apply opacity
    canvas.save();
    if (_opacity < 1.0) {
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(255, 255, 255, _opacity));
    }

    // Draw glow effect
    final glowPaint = Paint()
      ..color = const Color(0xFF00CED1).withOpacity(glowIntensity * 0.6 * _opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 + 10 * glowIntensity,
      glowPaint,
    );

    // Draw sprite if loaded, otherwise draw fallback
    if (_spriteLoaded && _archiSprite != null) {
      final spritePaint = Paint()..color = Color.fromRGBO(255, 255, 255, _opacity);
      _archiSprite!.render(
        canvas,
        position: Vector2.zero(),
        size: size,
        overridePaint: spritePaint,
      );
    } else {
      // Fallback rendering
      final bgPaint = Paint()..color = const Color(0xFF00CED1).withOpacity(_opacity);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);
      
      final fgPaint = Paint()..color = const Color(0xFF0F0F1E).withOpacity(_opacity);
      canvas.drawRect(
        Rect.fromLTWH(size.x * 0.2, size.y * 0.15, size.x * 0.6, size.y * 0.7),
        fgPaint,
      );
    }

    if (_opacity < 1.0) {
      canvas.restore();
    }
    canvas.restore();

    super.render(canvas);
  }

  /// Collect this evidence with animation
  void collect() {
    if (isCollected || _isCollecting) return;
    _isCollecting = true;
    isCollected = true;
    
    // Store initial scale for animation
    _initialScale = scale.x;
    
    // Reset collection timer to start animation
    _collectionTimer = 0.0;
    
    // Animation is handled manually in update() method
    // This is the correct approach for animations that start during gameplay
  }
  
  @override
  set opacity(double value) {
    _opacity = value.clamp(0.0, 1.0);
  }
  
  @override
  double get opacity => _opacity;


}

