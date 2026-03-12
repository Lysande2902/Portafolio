import 'dart:async' as async;
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class ShadowCorridorPuzzle extends MindHackPuzzle {
  late TextComponent _statusText;
  late TextComponent _counterText;
  double _spawnTimer = 0;
  final double _spawnInterval = 0.8;
  int _shadowsDispelled = 0;
  final int _targetShadows = 12;
  bool _isFinished = false;
  
  // Background perspective lines
  final List<LineComponent> _perspectiveLines = [];

  ShadowCorridorPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "PASILLO DE SOMBRAS";

  @override
  String get instruction => "DISPERSA LAS SOMBRAS TOCÁNDOLAS ANTES DE QUE SE ACERQUEN DEMASIADO";

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _statusText = TextComponent(
      text: '[3] PASILLO DE SOMBRAS',
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFFFF3131), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
    add(_statusText);

    _counterText = TextComponent(
      text: 'AVANZANDO: 0%',
      position: Vector2(size.x / 2, size.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white70, fontSize: 13),
      ),
    );
    add(_counterText);

    // Create perspective effect
    _createCorridorUI();
  }

  void _createCorridorUI() {
    final center = size / 2;
    // Four corner lines to simulate a tunnel
    final corners = [
      Vector2(0, 0),
      Vector2(size.x, 0),
      Vector2(size.x, size.y),
      Vector2(0, size.y),
    ];

    for (var corner in corners) {
      add(LineComponent(
        start: center,
        end: corner,
        paint: Paint()..color = Colors.white.withOpacity(0.1)..strokeWidth = 1,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isFinished) return;

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnShadow();
    }

    // Effect of pulsing hospital light
    if (math.Random().nextDouble() < 0.05) {
      gameRef.camera.viewfinder.add(
        OpacityEffect.to(0.8, EffectController(duration: 0.05, reverseDuration: 0.05))
      );
    }
  }

  void _spawnShadow() {
    final random = math.Random();
    // Random direction from center
    final angle = random.nextDouble() * 2 * math.pi;
    final velocity = Vector2(math.cos(angle), math.sin(angle));
    
    add(ShadowObstacle(
      direction: velocity,
      onDispelled: () {
        _shadowsDispelled++;
        _counterText.text = 'AVANZANDO: ${((_shadowsDispelled / _targetShadows) * 100).toInt()}%';
        if (_shadowsDispelled >= _targetShadows) {
          _isFinished = true;
          _counterText.text = 'HABITACIÓN ALCANZADA';
          Future.delayed(const Duration(milliseconds: 1000), () => onComplete());
        }
      },
      onHit: () => onFail(),
    ));
  }

  @override
  void reset() {
    _shadowsDispelled = 0;
    _isFinished = false;
    children.whereType<ShadowObstacle>().forEach((s) => s.removeFromParent());
  }
}

class ShadowObstacle extends PositionComponent with TapCallbacks {
  final Vector2 direction;
  final VoidCallback onDispelled;
  final VoidCallback onHit;
  double _scale = 0.1;
  final double _growthSpeed = 1.3;
  bool _handled = false;

  ShadowObstacle({
    required this.direction,
    required this.onDispelled,
    required this.onHit,
  }) : super(anchor: Anchor.center);

  @override
  void onMount() {
    super.onMount();
    position = (parent as ShadowCorridorPuzzle).size / 2;
    size = Vector2.all(100);
  }

  @override
  void render(Canvas canvas) {
    // A dark silhouette with a "flash" icon (fan with camera)
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    
    // Draw "lens flare" or camera flash eyes
    final eyePaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.4), 8, eyePaint);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.4), 8, eyePaint);
    
    // Flash aura
    if (math.Random().nextDouble() < 0.1) {
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2), 
        size.x * 0.6, 
        Paint()..color = Colors.white.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_handled) return;

    _scale += _growthSpeed * dt;
    scale = Vector2.all(_scale);
    
    // Move away from center
    position += direction * (_scale * 200 * dt);

    if (_scale > 4.5) { // Too close to the screen
      _handled = true;
      onHit();
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_handled) return;
    _handled = true;
    
    // Dispel effect
    add(ScaleEffect.to(Vector2.all(0.0), EffectController(duration: 0.15))..onComplete = () {
      onDispelled();
      removeFromParent();
    });
  }
}

class LineComponent extends PositionComponent {
  final Vector2 start;
  final Vector2 end;
  final Paint paint;

  LineComponent({required this.start, required this.end, required this.paint});

  @override
  void render(Canvas canvas) {
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
  }
}
