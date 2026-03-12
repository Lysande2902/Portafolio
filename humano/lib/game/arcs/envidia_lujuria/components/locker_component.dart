import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

/// Professional locker component using Wall.jpg texture
class LockerComponent extends PositionComponent with CollisionCallbacks {
  final bool isOccupied;
  final bool hasFragment;
  bool _isFragmentCollected = false;
  bool isPlayerInside = false;
  
  bool isPlayerNear = false;
  
  Sprite? _wallSprite;
  bool _isLoaded = false;

  LockerComponent({
    required Vector2 position,
    required Vector2 size,
    this.isOccupied = false,
    this.hasFragment = false,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load Wall.jpg texture for locker body
    _wallSprite = await Sprite.load('Wall.jpg');
    _isLoaded = true;
    
    // Add collision hitbox
    add(RectangleHitbox());
  }

  bool get canHide => !isOccupied && !isPlayerInside;
  bool get hasUncollectedFragment => hasFragment && !_isFragmentCollected;

  void collectFragment() {
    _isFragmentCollected = true;
  }

  @override
  void render(Canvas canvas) {
    if (!_isLoaded || _wallSprite == null) return;
    
    // Draw locker body using Wall.jpg texture with metallic tint
    final paint = Paint()
      ..colorFilter = ColorFilter.mode(
        const Color(0xFF4A5568), // Dark gray-blue metallic tint
        BlendMode.modulate,
      );
    
    _wallSprite!.render(
      canvas,
      size: size,
      overridePaint: paint,
    );

    // Draw locker door frame
    final framePaint = Paint()
      ..color = const Color(0xFF2D3748)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), framePaint);

    // Draw ventilation slits (horizontal lines)
    final slitPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..strokeWidth = 2.0;
    
    final slitCount = 5;
    final slitSpacing = size.y / (slitCount + 1);
    for (int i = 1; i <= slitCount; i++) {
      final y = slitSpacing * i;
      canvas.drawLine(
        Offset(size.x * 0.15, y),
        Offset(size.x * 0.85, y),
        slitPaint,
      );
    }

    // Draw handle
    final handlePaint = Paint()
      ..color = const Color(0xFF718096)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.85, size.y * 0.45, 8, size.y * 0.1),
      handlePaint,
    );

    // Status indicator (top right corner)
    if (isOccupied) {
      // Red light for occupied
      final redLight = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.x * 0.85, size.y * 0.15), 4, redLight);
      
      // Red glow
      final glowPaint = Paint()
        ..color = Colors.red.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(size.x * 0.85, size.y * 0.15), 8, glowPaint);
    } else {
      // Green light for available
      final greenLight = Paint()
        ..color = Colors.green.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.x * 0.85, size.y * 0.15), 4, greenLight);
    }

    // Fragment indicator (subtle white glow if uncollected)
    if (hasUncollectedFragment) {
      final fragmentGlow = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), fragmentGlow);
    }
  }
}
